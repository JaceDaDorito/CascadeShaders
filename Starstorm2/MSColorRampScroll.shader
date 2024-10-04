Shader "Moonstorm/FX/MSColorRampScroll"
{
    Properties
    {
        _Tint("Tint: ", Color) = (1,1,1,1)
        _Ramp("Ramp: ", 2D) = "white"{}
        _ScrollVector("Scroll Vector: ", Vector) = (1, 0, 0, 0)
        [MaterialToggle] _Normal("Normal :", Float) = 0
        _NormalTex("Normal Texture: ", 2D) = "black"{}
        _NormalPower("Normal Power: ", Range(0,1)) = 1

        _Gloss ("Gloss: ", Range(0,1)) = 1
        _SpecularExponent ("Specular Exponent: ", Float) = 6
        _SpecularOuterBandThreshold ("Specular Outer Band Threshold: ", Range(0,1)) = 0.7
        _SpecularPower ("Specular Power: ", Range(0,3)) = 0.4

        _ShadowThreshold ("Shadow Threshold: ", Range(0,1)) = 0.9
        _ShadowPower ("Shadow Power: ", Range(0,1)) = 0.2

        [MaterialToggle]_Fresnel ("Fresnel: ", Float) = 0
        _FresnelTint("Fresnel Tint: ", Color) = (1,1,1,1)
        _FresnelRamp("Fresnel Ramp: ", 2D) = "white"{}
        [MaterialToggle]_FresnelBlending ("Fresnel Blending: ", Float) = 0
        _FresnelThreshold ("Fresnel Threshold: ", Range(0,1)) = 0.5
        _FresnelPower ("Fresnel Power: ", Range(0,2)) = 0.5

    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            Tags { "LightMode" = "ForwardBase" }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"
            #include "MSColorRampScroll.cginc"

            ENDCG
        }

        Pass{
            Tags { "LightMode" = "ForwardAdd" }
            Blend One One
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "MSColorRampScroll.cginc"

            ENDCG
        }
        
    }
}
