Shader "TessAndGeometry/PN Tri Tessellation + Cubic Bezier Triangle Patch"
{
    Properties
    {
        [NoScaleOffset]_BaseColor ("Base Color", 2D) = "white" {}  
        
        [Header(Tess)][Space]
     
        [KeywordEnum(integer, fractional_even, fractional_odd )]_Partitioning ("Partitioning Mode", Float) = 2
        [KeywordEnum(triangle_cw, triangle_ccw)]_Outputtopology ("Outputtopology Mode", Float) = 2
        [IntRange]_EdgeFactor ("EdgeFactor", Range(1,32)) = 4 
        [IntRange]_InsideFactor ("InsideFactor", Range(1,32)) = 4 
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
         
        Pass
        { 
            HLSLPROGRAM
            #pragma target 4.6 
            #pragma vertex PNTriTessVert
            #pragma fragment PNTriTessFrag 
            #pragma hull PNTriTessControlPoint
            #pragma domain PNTriTessDomain
             
            #pragma multi_compile _PARTITIONING_INTEGER _PARTITIONING_FRACTIONAL_EVEN _PARTITIONING_FRACTIONAL_ODD   
            #pragma multi_compile _OUTPUTTOPOLOGY_TRIANGLE_CW _OUTPUTTOPOLOGY_TRIANGLE_CCW 

            #include "./PNTriTess.hlsl"
            ENDHLSL
        }
    }
}
 