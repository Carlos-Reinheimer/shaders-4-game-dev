Shader "Unlit/Healthbar" {
    Properties {
       [NoScaleOffset] _MainTex ("Texture", 2D) = "white" {}
        _Health ("Health", Range(0, 1)) = 1
        _BorderSize("Border Size", Range(0, 0.5)) = 0.1
    }
    SubShader {
        Tags { "RenderType"="Transparent"
               "Queue" = "Transparent" }
        Pass {

            ZWrite off
            // src * srcAlpha + dst * (1-srcAlpha)
            Blend SrcAlpha OneMinusSrcAlpha // Alpha blending

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct MeshData {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Interpolators {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float _Health;
            float _BorderSize;

            Interpolators vert (MeshData v) {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float InverseLerp(float a, float b, float v) {
                return (v - a) / (b - a);
            }

            fixed4 frag(Interpolators i) : SV_Target{

                //float t = saturate(InverseLerp(0.2, 0.8, _Health)); // make sure is clamped 
                //float3 healthBarColor = lerp(float3(1, 0, 0), float3(0, 1, 0), t);

                //float4 col = tex2D(_MainTex, i.uv);

                //clip(healthbarMask - 0.5); // make renders transparent on the black part  
                //float bgColor = float3(0, 0, 0);
                //float3 outColor = lerp(bgColor, healthBarColor, healthbarMask);

                // rounded corner clipping
                float2 coords = i.uv;
                coords.x *= 8;
                float2 pointOnLineSeg = float2(clamp(coords.x, 0.5, 7.5), 0.5);
                float sdf = distance(coords, pointOnLineSeg) * 2 - 1; // sign distance field
                float borderSdf = sdf + _BorderSize;
                float borderMask = step(0, -borderSdf);
                clip(-sdf);

                float healthbarMask = _Health > i.uv.x;

                float3 healthBarColor = tex2D(_MainTex, float2(_Health, i.uv.y));
                
                if (_Health < 0.2) {
                    float flash = cos(_Time.y * 4) * 0.4 + 1;
                    healthBarColor *= flash;
                }


                return float4(healthBarColor * healthbarMask * borderMask, 1);
                //return col;   
            }
            ENDCG
        }
    }
}
