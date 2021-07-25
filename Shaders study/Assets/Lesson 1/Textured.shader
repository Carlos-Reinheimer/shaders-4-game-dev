Shader "Unlit/Textured" {
    Properties {
        _MainTex ("Texture", 2D) = "white" {}
        _Rock("_Rock", 2D) = "white" {}
        _Pattern("Pattern", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            #define TAU 6.28318530718

            struct MeshData {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

    float GetWave(float coord) {
        float wave = cos((coord - _Time.y * 0.1) * TAU * 5) * 0.5 + 0.5;
        wave *= coord;
        return wave;
    }

            struct Interpolators {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
            };

            sampler2D _MainTex;
            //float4 _MainTex_ST; // optional   scale offset
            sampler2D _Pattern;
            sampler2D _Rock;


            Interpolators vert (MeshData v) {
                Interpolators o;
                o.worldPos = mul(UNITY_MATRIX_M, v.vertex.xyz); // objecto to world
                o.vertex = UnityObjectToClipPos(v.vertex);
                //o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag(Interpolators i) : SV_Target{

                float2 topDownProjection = i.worldPos.xz;
                //return float4(i.worldPos.xyz, 1);
                fixed4 col = tex2D(_MainTex, topDownProjection);
                fixed4 rock = tex2D(_Rock, topDownProjection);
                float pattern = tex2D(_Pattern, i.uv).x;
                return GetWave(pattern);
                //float4 finalColor = lerp(float4(1, 0, 0, 1), col, pattern);
                float4 finalColor = lerp(rock, col, pattern);
                return finalColor;
            }
            ENDCG
        }
    }
}
