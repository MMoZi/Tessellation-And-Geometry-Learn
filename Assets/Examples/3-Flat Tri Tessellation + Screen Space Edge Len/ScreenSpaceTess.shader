Shader "TessAndGeometry/Flat Tri Tessellation + Screen Space Edge Len"
{
    Properties
    {
        [NoScaleOffset]_BaseColor ("Base Color", 2D) = "white" {}  
        
        [Header(Tess)][Space]
     
        [KeywordEnum(integer, fractional_even, fractional_odd)]_Partitioning ("Partitioning Mode", Float) = 2
        [KeywordEnum(triangle_cw, triangle_ccw)]_Outputtopology ("Outputtopology Mode", Float) = 0
        [IntRange]_EdgeFactor ("EdgeFactor", Range(1, 32)) = 4 
        _TriangleSize ("TriangleSize", Range(1, 100)) = 15.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
         
        Pass
        { 
            HLSLPROGRAM
            #pragma target 4.6 
            #pragma vertex ScreenSpaceTessVert
            #pragma fragment ScreenSpaceTessFrag 
            #pragma hull ScreenSpaceTessControlPoint
            #pragma domain ScreenSpaceTessDomain
             
            #pragma multi_compile _PARTITIONING_INTEGER _PARTITIONING_FRACTIONAL_EVEN _PARTITIONING_FRACTIONAL_ODD 
            #pragma multi_compile _OUTPUTTOPOLOGY_TRIANGLE_CW _OUTPUTTOPOLOGY_TRIANGLE_CCW 

            #include "./ScreenSpaceTess.hlsl"
            ENDHLSL
        }
    }
}
