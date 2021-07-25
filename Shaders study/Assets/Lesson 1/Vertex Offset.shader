Shader "Unlit/Vertex Offet" {
    Properties{ // input data
        _ColorA("Color A", Color) = (1, 1, 1, 1)
        _ColorB("Color B", Color) = (1, 1, 1, 1)
        _ColorStart("ColorStart", Range(0, 1)) = 0
        _ColorEnd("ColorEnd", Range(0, 1)) = 1
        _WaveAmp("Wave Amplitude", Range(0, 0.5)) = 0.1

        _Scale("UV Scale", Float) = 1
        _Offset("UV Offset", Float) = 0
    }
        SubShader{
        Tags {
        "RenderType" = "Opaque"
        }

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
                float _WaveAmp;

                float _Scale;
                float _Offset;

            struct MeshData { 
                float4 vertex : POSITION; 
                float3 normals : NORMAL; 
                float2 uv0 : TEXCOORD0;
            };

            struct Interpolators {
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD0;
                float2 uv : TEXCOORD1;
            };

            float GetWave(float2 uv) {
                float2 uvsCentered = uv * 2 - 1;
                float radialDistance = length(uvsCentered);

                float wave = cos((radialDistance - _Time.y * 0.1) * TAU * 5) * 0.5 + 0.5;
                wave *= 1 - radialDistance;
                return wave;
            }

            Interpolators vert(MeshData v) { 
                Interpolators o;

                //float wave = cos((v.uv0.y - _Time.y * 0.1) * TAU * 5);
                //float wave2 = cos((v.uv0.x - _Time.y * 0.1) * TAU * 5);
                //v.vertex.y = wave * wave2 * _WaveAmp;

                v.vertex.y = GetWave(v.uv0) * _WaveAmp;

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normals); 
                o.uv = v.uv0;
                return o;
            }

            float InverseLerp(float a, float b, float v) {
                return (v - a) / (b - a);
            }

            float4 frag(Interpolators i) : SV_Target{

                //float xOffset = cos(i.uv.x * TAU * 8) * 0.05;
                //t *= 1 - i.uv.y;
                //float topBottomRemover = (abs(i.normal.y) < 0.999);
                //float waves = t * topBottomRemover;
                //float4 gradient = lerp(_ColorA, _ColorB, i.uv.y);

                return GetWave(i.uv);
            }
            ENDCG
        }
    }
}
