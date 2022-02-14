#ifndef SCREEN_SPACE_TESSELLATION
#define SCREEN_SPACE_TESSELLATION

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/GeometricTools.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Tessellation.hlsl"

CBUFFER_START(UnityPerMaterial) 
float _EdgeFactor;   
float _TriangleSize;
CBUFFER_END

TEXTURE2D(_BaseColor);
SAMPLER(sampler_BaseColor); 

struct Attributes
{
    float3 positionOS   : POSITION; 
    float2 texcoord     : TEXCOORD0;
    
};

struct Varyings
{
    float4  positionCS      : SV_POSITION;
    float3  color           : TEXCOORD0; 
};

struct HSInput{
    float3 positionWS : INTERNALTESSPOS; 
    float2 texcoord : TEXCOORD0;
};

struct HSPCOutput {  
    float edgeFactor[3] : SV_TESSFACTOR;
    float insideFactor  : SV_INSIDETESSFACTOR;
};

HSInput ScreenSpaceTessVert(Attributes input){ 
    HSInput o;
    o.positionWS = TransformObjectToWorld(input.positionOS);  
    o.texcoord   = input.texcoord;
    return o;
}
   
   
HSPCOutput PatchConstant (InputPatch<HSInput,3> patch, uint patchID : SV_PrimitiveID){ 
    HSPCOutput o; 
 
    real3 triVectexFactors =  GetScreenSpaceTessFactor(patch[0].positionWS, patch[1].positionWS, patch[2].positionWS, GetWorldToHClipMatrix() , _ScreenParams, _TriangleSize);
    float4 tessFactors = _EdgeFactor * CalcTriTessFactorsFromEdgeTessFactors(triVectexFactors);
    o.edgeFactor[0] = tessFactors.x;
    o.edgeFactor[1] = tessFactors.y;
    o.edgeFactor[2] = tessFactors.z;

    o.insideFactor  = tessFactors.w;
    return o;
}

//https://docs.microsoft.com/en-us/windows/win32/direct3dhlsl/sm5-attributes-outputcontrolpoints

[domain("tri")]   
#if _PARTITIONING_INTEGER
[partitioning("integer")] 
#elif _PARTITIONING_FRACTIONAL_EVEN
[partitioning("fractional_even")] 
#elif _PARTITIONING_FRACTIONAL_ODD
[partitioning("fractional_odd")]    
#endif 
 
#if _OUTPUTTOPOLOGY_TRIANGLE_CW
[outputtopology("triangle_cw")] 
#elif _OUTPUTTOPOLOGY_TRIANGLE_CCW
[outputtopology("triangle_ccw")] 
#endif

[patchconstantfunc("PatchConstant")]    //一个patch一共有三个点，但是这三个点都共用这个函数
[outputcontrolpoints(3)]                //This will be the number of times the main function will be executed.
[maxtessfactor(64.0f)]                  //最大的细分因子   
HSInput ScreenSpaceTessControlPoint (InputPatch<HSInput,3> patch,uint id : SV_OutputControlPointID){ 
    return patch[id];
}
 
  
[domain("tri")]      
Varyings ScreenSpaceTessDomain (HSPCOutput tessFactors, const OutputPatch<HSInput,3> patch, float3 bary : SV_DOMAINLOCATION)
{ 
    float3 positionWS = patch[0].positionWS * bary.x + patch[1].positionWS * bary.y + patch[2].positionWS * bary.z; 
	float2 texcoord   = patch[0].texcoord * bary.x + patch[1].texcoord * bary.y + patch[2].texcoord * bary.z;

    Varyings output;
    output.positionCS = TransformWorldToHClip(positionWS);
    output.color = SAMPLE_TEXTURE2D_LOD(_BaseColor, sampler_BaseColor, texcoord, 0).rgb;
    
    return output; 
}
 

half4 ScreenSpaceTessFrag(Varyings input) : SV_Target{  
     
    return half4(input.color ,1.0); 
}
 
#endif

 