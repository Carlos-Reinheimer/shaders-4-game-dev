Shader "Unlit/Shader1" {
    Properties { // input data
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0; // maps, etc
            };

            struct v2f {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v) {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex); // local space to clip space
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            // bool 0 1
            // int
            // float (32 bit)
            // half (16 bit)
            // fixed (lower precision) -1 to 1
            // float4 -> half4 -> fixed4
            // float4x4 -> half4x4 (C#: Matrix4x4)

            fixed4 frag (v2f i) : SV_Target {
                return float4(1, 0, 0, 1); // returning red color
            }
            ENDCG
        }
    }
}
