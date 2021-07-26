#include "UnityCG.cginc"
#include "Lighting.cginc"
#include "AutoLight.cginc"

#define USE_LIGHTING
#define TAU 6.28318530718;

struct MeshData {
    float4 vertex : POSITION;
    float3 normal : NORMAL;
    float4 tangent : TANGENT; // xyz = tangent direction, w = tangent sign
    float2 uv : TEXCOORD0;
};

struct Interpolators {
    float4 vertex : SV_POSITION;
    float2 uv : TEXCOORD0;
    float3 normal : TEXCOORD1;
    float3 tangent : TEXCOORD2;
    float3 bitangent : TEXCOORD3;
    float3 worldPos : TEXCOORD4;
    LIGHTING_COORDS(5, 6)
};

sampler2D _RockAlbedo;
sampler2D _RockNormals;
sampler2D _RockHeight;
sampler2D _DiffuseIBL;
sampler2D _SpecularIBL;
float4 _RockAlbedo_ST;
float _Gloss;
float4 _Color;
float _SpecIBLIntensity;
float4 _AmbientLight;
float _NormalIntensity;
float _DisplacementStrength;

float2 Rotate(float2 v, float angRad) {
    float ca = cos(angRad);
    float sa = sin(angRad);

    return float2(ca * v.x - sa * v.y, sa * v.x + ca * v.y);
}

float2 DirToRectilinear(float3 dir) {
    float x = atan2(dir.z, dir.x) / TAU + 0.5; // 0-1
    float y = dir.y * 0.5 + 0.5; // 0-1
    return float2(x, y);

};

Interpolators vert(MeshData v) {
    Interpolators o;
    o.uv = TRANSFORM_TEX(v.uv, _RockAlbedo);

    //o.uv = Rotate(o.uv, _Time.y);

    float height = tex2Dlod(_RockHeight, float4(o.uv, 0, 0)).x * 2 - 1; // 0 - 1
    v.vertex.xyz += v.normal  * (height * _DisplacementStrength);

    o.vertex = UnityObjectToClipPos(v.vertex);
    o.normal = UnityObjectToWorldNormal(v.normal);
    o.tangent = UnityObjectToWorldDir(v.tangent.xyz);
    o.bitangent = cross(o.normal, o.tangent);
    o.bitangent *= v.tangent.w * unity_WorldTransformParams.w; // correctly handle flipping/mirring

    o.worldPos = mul(unity_ObjectToWorld, v.vertex);
    TRANSFER_VERTEX_TO_FRAGMENT(o); // lighting, actually 

    return o;
}

float4 frag(Interpolators i) : SV_Target{

    float3 rock = tex2D(_RockAlbedo, i.uv).rgb;
    float3 surfaceColor = rock * _Color.rgb;

    float3 tangentSpaceNormal = UnpackNormal(tex2D(_RockNormals, i.uv));
    tangentSpaceNormal = normalize(lerp(float3(0, 0, 1), tangentSpaceNormal, _NormalIntensity));

    float3x3 mtxTangToWorld = {
        i.tangent.x, i.bitangent.x, i.normal.x, 
        i.tangent.y, i.bitangent.y, i.normal.y,
        i.tangent.z, i.bitangent.z, i.normal.z,
    };
    float3 N = mul(mtxTangToWorld, tangentSpaceNormal); // world space normal  


    // if defined() ||
    #ifdef USE_LIGHTING // if define
        // difuse lighting
        //float3 N = normalize(i.normal);

        float L = normalize(UnityWorldSpaceLightDir(i.worldPos));
        float attenuation = LIGHT_ATTENUATION(i);
        float3 lambert = saturate(dot(N, L));
        float3 diffuseLight = (lambert * attenuation) * _LightColor0.xyz; // or use max(0, dot(N, L))

        // LEVEL 1
        //#ifdef IS_IN_BASE_PASS
        //    diffuseLight += _AmbientLight; // adds the indirect diffuse lighting
        //#endif

        // LEVEL 2
        #ifdef IS_IN_BASE_PASS
            float3 diffuseIBl = tex2D(_DiffuseIBL, DirToRectilinear(N)).xyz;
            diffuseLight += diffuseIBl; // adds the indirect diffuse lighting
        #endif

        // specular lighting
        float3 V = normalize(_WorldSpaceCameraPos - i.worldPos);
        float3 R = reflect(-L, N);
        float3 H = normalize(L + V);
        //float3 specularLight = saturate(dot(V, R)); // phong
        float3 specularLight = saturate(dot(H, N)) * (lambert > 0); // blinn-phong

        float specularExponent = exp2(_Gloss * 11) + 2;
        specularLight = pow(specularLight, specularExponent) * _Gloss * attenuation; // specular exponent 
        specularLight *= _LightColor0.xyz;

        // LEVEL 3
        #ifdef IS_IN_BASE_PASS
            float fresnel = pow(1-saturate(dot(V, N)), 5);

            float3 viewRefl = reflect(-V, N);
            float mip = (1 - _Gloss) * 6;
            float3 specularIbl = tex2Dlod(_SpecularIBL, float4(DirToRectilinear(viewRefl), mip, mip)).xyz;
            specularLight += specularIbl * _SpecIBLIntensity * fresnel;
        #endif
        //float fresnel = (1-dot(V, N))*((cos(_Time.y * 4))*0.5+0.5);
        //float fresnel = step(0.7, 1 - dot(V, N));

        return float4(diffuseLight * surfaceColor + specularLight, 1);
    #else
        #ifdef IS_IN_BASE_PASS
            return surfaceColor;
        #else
            return 0;
        #endif
    #endif



}