#ifndef FLAT_TRI_TESSELLATION
#define FLAT_TRI_TESSELLATION

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

CBUFFER_START(UnityPerMaterial) 
float _EdgeFactor; 
float _InsideFactor; 
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
    float3 positionOS : INTERNALTESSPOS; 
    float2 texcoord : TEXCOORD0;
};

struct HSPCOutput {  
    float edgeFactor[3] : SV_TESSFACTOR;
    float insideFactor  : SV_INSIDETESSFACTOR;
};

HSInput FlatTriTessVert(Attributes input){ 
    HSInput o;
    o.positionOS = input.positionOS; 
    o.texcoord   = input.texcoord;
    return o;
}
   
   
HSPCOutput PatchConstant (InputPatch<HSInput,3> patch, uint patchID : SV_PrimitiveID){
    // 最多两个不同的变量，否则图像消失？？
    HSPCOutput o;
    o.edgeFactor[0] = _EdgeFactor;
    o.edgeFactor[1] = _EdgeFactor; 
    o.edgeFactor[2] = _EdgeFactor;
    o.insideFactor  = _InsideFactor;
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
HSInput FlatTriTessControlPoint (InputPatch<HSInput,3> patch,uint id : SV_OutputControlPointID){ 
    return patch[id];
}
 
  
[domain("tri")]      
Varyings FlatTriTessDomain (HSPCOutput tessFactors, const OutputPatch<HSInput,3> patch, float3 bary : SV_DOMAINLOCATION)
{
    Attributes input;
    input.positionOS = patch[0].positionOS * bary.x + patch[1].positionOS * bary.y + patch[2].positionOS * bary.z; 
	input.texcoord   = patch[0].texcoord * bary.x + patch[1].texcoord * bary.y + patch[2].texcoord * bary.z;

    Varyings output;
    output.positionCS = TransformObjectToHClip(input.positionOS);
    output.color = SAMPLE_TEXTURE2D_LOD(_BaseColor, sampler_BaseColor, input.texcoord, 0).rgb;
    
    return output; 
}
 

half4 FlatTriTessFrag(Varyings input) : SV_Target{  
     
    return half4(input.color ,1.0); 
}
 
#endif

 