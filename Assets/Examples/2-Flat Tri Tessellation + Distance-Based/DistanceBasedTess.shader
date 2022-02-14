Shader "TessAndGeometry/Flat Tri Tessellation + Distance-Based"
{
    Properties
    {
        [NoScaleOffset]_BaseColor ("Base Color", 2D) = "white" {}  
        
        [Header(Tess)][Space]
     
        [KeywordEnum(integer, fractional_even, fractional_odd)]_Partitioning ("Partitioning Mode", Float) = 2
        [KeywordEnum(triangle_cw, triangle_ccw)]_Outputtopology ("Outputtopology Mode", Float) = 0
        [IntRange]_EdgeFactor ("EdgeFactor", Range(1,32)) = 4
        _TessMinDist ("TessMinDist", Range(0,10)) = 10.0
        _FadeDist ("FadeDist", Range(1,20)) = 15.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
         
        Pass
        { 
            HLSLPROGRAM
            #pragma target 4.6 
            #pragma vertex DistanceBasedTessVert
            #pragma fragment DistanceBasedTessFrag 
            #pragma hull DistanceBasedTessControlPoint
            #pragma domain DistanceBasedTessDomain
             
            #pragma multi_compile _PARTITIONING_INTEGER _PARTITIONING_FRACTIONAL_EVEN _PARTITIONING_FRACTIONAL_ODD 
            #pragma multi_compile _OUTPUTTOPOLOGY_TRIANGLE_CW _OUTPUTTOPOLOGY_TRIANGLE_CCW 

            #include "./DistanceBasedTess.hlsl"
            ENDHLSL
        }
    }
}
