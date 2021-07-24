Shader "Unlit/LightingTest" {
    Properties {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader {
        Tags { "RenderType"="Opaque" }

        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            struct MeshData {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
    };

            struct Interpolators {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            Interpolators vert (MeshData v) {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            float4 frag(Interpolators i) : SV_Target{

                float3 N = i.normal;
                float L = _WorldSpaceLightPos0.xyz; // actually a direction

                float3 diffuseLight = saturate( dot(N, L) ) * _LightColor0.xyz; // or use max(0, dot(N, L))

                return float4(diffuseLight, 1);


                // sample the texture
                //float4 col = tex2D(_MainTex, i.uv);
                //return col;
            }
            ENDCG
        }
    }
}
