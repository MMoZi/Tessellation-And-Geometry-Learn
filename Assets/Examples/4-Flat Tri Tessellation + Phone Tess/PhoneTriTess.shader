Shader "TessAndGeometry/Flat Tri Tessellation + Phone Tess"
{
    Properties
    {
        [NoScaleOffset]_BaseColor ("Base Color", 2D) = "white" {}  
        
        [Header(Tess)][Space]
     
        [KeywordEnum(integer, fractional_even, fractional_odd)]_Partitioning ("Partitioning Mode", Float) = 2
        [KeywordEnum(triangle_cw, triangle_ccw)]_Outputtopology ("Outputtopology Mode", Float) = 0
        [IntRange]_EdgeFactor ("EdgeFactor", Range(1,32)) = 4 
        [IntRange]_InsideFactor ("InsideFactor", Range(1,32)) = 4  
        _PhoneShape ("PhoneShape", Range(0, 1)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
         
        Pass
        { 
            HLSLPROGRAM
            #pragma target 4.6 
            #pragma vertex PhoneTriTessVert
            #pragma fragment PhoneTriTessFrag 
            #pragma hull PhoneTriTessControlPoint
            #pragma domain PhoneTriTessDomain
             
            #pragma multi_compile _PARTITIONING_INTEGER _PARTITIONING_FRACTIONAL_EVEN _PARTITIONING_FRACTIONAL_ODD 
            #pragma multi_compile _OUTPUTTOPOLOGY_TRIANGLE_CW _OUTPUTTOPOLOGY_TRIANGLE_CCW 

            #include "./PhoneTriTess.hlsl"
            ENDHLSL
        }
    }
}
