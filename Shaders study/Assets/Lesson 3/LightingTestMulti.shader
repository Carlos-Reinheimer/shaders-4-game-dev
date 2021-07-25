Shader "Unlit/LightingTestMulti" {
    Properties {
        _RockAlbedo("Rock Albedo", 2D) = "white" {}
        [NoScaleOffset]_RockNormals("Rock Normals", 2D) = "bump" {}
        _Gloss ("Gloss", Range(0, 1)) = 1
        _Color("Color", Color) = (1, 1, 1, 1)
        _NormalIntensity("Normal Intensity", Range(0, 1)) = 1
    }
    SubShader {
        Tags { "RenderType"="Opaque" }

        // Base pass
        Pass {
            Tags {"LightMode" = "ForwardBase"} // what is this pass
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define IS_IN_BASE_PASS 
            #include "FGLighting.cginc"
            
            ENDCG
        }

        // Add pass
         Pass {
            Tags {"LightMode" = "ForwardAdd"}
            Blend One One // src*1 + dst*1
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdadd

            #include "FGLighting.cginc"

            ENDCG
        }
    }
}
