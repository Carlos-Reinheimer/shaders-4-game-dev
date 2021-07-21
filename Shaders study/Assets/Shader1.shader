Shader "Unlit/Shader1" {
    Properties{ // input data
        _ColorA("Color A", Color) = (1, 1, 1, 1)
        _ColorB("Color B", Color) = (1, 1, 1, 1)
        _ColorStart("ColorStart", Range(0, 1)) = 0
        _ColorEnd("ColorEnd", Range(0, 1)) = 1

        _Scale ("UV Scale", Float) = 1
        _Offset("UV Offset", Float) = 0
    }
        SubShader{
            Tags { "RenderType" = "Opaque" }

            Pass {
                CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag

                #include "UnityCG.cginc"

                #define TAU 6.28318530718

                float4 _ColorA;
                float4 _ColorB;
                float _ColorStart;
                float _ColorEnd;

                float _Scale;
                float _Offset;

            struct MeshData { // per-vertex mesh data
                float4 vertex : POSITION; // local space vextex position
                float3 normals : NORMAL; // local space normal direction
                // float4 tanget : TANGENT; // tangent direction (xyz) tangent sign (w)
                // float4 color :  COLOR; // vertex colors
                float2 uv0 : TEXCOORD0; // uv0 diffuse/normal map textures
                // float4 uv1 : TEXCOORD1; uv1 coordinates lightmap coords
            };
            
            // data passed from the vertex shader to the fragment shader
            // this will interpolate/blend across the triangle!
            struct Interpolators {
                float4 vertex : SV_POSITION; // clip space position
                float3 normal : TEXCOORD0;
                float2 uv : TEXCOORD1;
                //float2 uv : TEXCOORD0;
            };

            Interpolators vert (MeshData v) { // do most operations in the vert because of performance
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex); // local space to clip space
                // v.normals --> access variable normals of the MeshData struct, witch has the NORMAL values
                // UnityObjectToWorldNormal --> converts from object space to world space      mul(v.normals, (float3x3)unity_worldToObject) or mul((float3x3)unity_ObjectToWorld, v.normals) or mul((float3x3)UNITY_MATRIX_M, v.normals)
                o.normal = UnityObjectToWorldNormal( v.normals ); // just pass data through 
                o.uv = v.uv0; // (v.uv0 + _Offset) * _Scale;
                return o;
            }

            // bool 0 1
            // int
            // float (32 bit)
            // half (16 bit)
            // fixed (lower precision) -1 to 1
            // float4 -> half4 -> fixed4
            // float4x4 -> half4x4 (C#: Matrix4x4)

            float InverseLerp(float a, float b, float v) {
                return (v - a) / (b - a);
            }

            float4 frag(Interpolators i) : SV_Target{ // frag (fragments) == pixels
                // ----------- swizzling -----------
                //float4 myValue;
                //float2 otherValue = myValue.xy // or myValue.rg -- myValue.gr -- myValue.xxxx (grey)
                // ---------------------------------

                // ----------- Normal -----------
                //return float4(i.normal, 1);
                // ------------------------------

                // ----------- some coods -----------
                //return float4(i.uv.xxx, 1);
                //return float4(i.uv.yyy, 1);
                //return float4(i.uv, 0, 1);
                // ----------------------------------

                // ----------- Triangle waves -----------
                //float t = abs( frac(i.uv.x * 5) * 2 -1 );  --> manual

                // y --> seconds
                //_Time.y

                // ------ Example 1 ------
                //float xOffset = cos ( i.uv.y * TAU * 8 ) * 0.05;
                //float t = cos((i.uv.x + xOffset + _Time.y * 0.3) * TAU * 5) * 0.5 + 0.5;

                float xOffset = cos(i.uv.x * TAU * 8) * 0.05;
                float t = cos((i.uv.y + xOffset - _Time.y * 0.1) * TAU * 5) * 0.5 + 0.5;
                t *= 1-i.uv.y;
                return t;
                // --------------------------------------

                // lerp --> blend between 2 colors based on the X UV coords
                //float t = saturate ( InverseLerp(_ColorStart, _ColorEnd, i.uv.x) ); // saturate --> campls between 0 to 1
                //// frac = v - floor(v)
                //float4 outColor = lerp(_ColorA, _ColorB, t);
                //return outColor;

            }
            ENDCG
        }
    }
}
