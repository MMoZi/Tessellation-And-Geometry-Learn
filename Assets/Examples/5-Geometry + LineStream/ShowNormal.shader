Shader "TessAndGeometry/Geometry ShowNormal"
{
    Properties
    {
         _LineColor ("LineColor", Color) = (0, 1, 0, 1)
         _LineLength ("LineLength", Range(0.0 ,1.0)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
         
        Pass
        { 
            HLSLPROGRAM
            #pragma vertex ShowNormalVert
            #pragma fragment ShowNormalFrag
            #pragma geometry ShowNormalGS
            #include "./ShowNormal.hlsl"
            ENDHLSL
        }
    }
}
