#ifndef PN_TRI_TESSELLATION
#define PN_TRI_TESSELLATION

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
    float3 normalOS     : NORMAL;
    float2 texcoord     : TEXCOORD0;
    
};

struct Varyings
{
    float4 positionCS      : SV_POSITION;
    float3 normalWS        : TEXCOORD0; 
    float2 uv              : TEXCOORD1;
};

struct HSInput{
    float3 positionOS : INTERNALTESSPOS;
    float3 normalOS   : NORMAL;
    float2 texcoord   : TEXCOORD0;
    float3 positionOS1 : TEXCOORD1;
    float3 positionOS2 : TEXCOORD2;
}; 
struct HSPCOutput {  
    float edgeFactor[3] : SV_TESSFACTOR; 
    float insideFactor  : SV_INSIDETESSFACTOR; 
};

HSInput PNTriTessVert(Attributes input){ 
    HSInput o = (HSInput)0;
    o.positionOS = input.positionOS; 
    o.normalOS   = input.normalOS;
    o.texcoord   = input.texcoord;
    return o;
}

/*
https://docs.microsoft.com/en-us/windows/win32/direct3d11/direct3d-11-advanced-stages-tessellation
At a deeper level, a hull-shader actually operates in two phases: 
a control-point phase and a patch-constant phase, which are run in parallel by the hardware

*/
//Unity:  Patch constant function must use the same input control point type declared in the control point phase   
HSPCOutput TriTessPatchConstant (InputPatch<HSInput,3> patch, uint patchID : SV_PrimitiveID){
 
    HSPCOutput o; 
     
    o.edgeFactor[0] = _EdgeFactor;
    o.edgeFactor[1] = _EdgeFactor; 
    o.edgeFactor[2] = _EdgeFactor;
    o.insideFactor  = _InsideFactor;
    return o;
}

//Curved PN Triangles https://www.nvidia.com/content/PDF/GDC2011/John_McDonald.pdf
float3 ComputeCP(float3 pA, float3 pB, float3 nA){
    return (2 * pA + pB - dot((pB - pA), nA) * nA) / 3.0f;
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

[patchconstantfunc("TriTessPatchConstant")]     
[outputcontrolpoints(3)]                 
[maxtessfactor(64.0f)] 

HSInput PNTriTessControlPoint (InputPatch<HSInput,3> patch,uint id : SV_OutputControlPointID){ 
    HSInput output;
    const uint nextCPID = id < 2 ? id + 1 : 0;
    
    output.positionOS    = patch[id].positionOS;
    output.normalOS      = patch[id].normalOS;
    output.texcoord      = patch[id].texcoord;

    output.positionOS1 = ComputeCP(patch[id].positionOS, patch[nextCPID].positionOS, patch[id].normalOS);
    output.positionOS2 = ComputeCP(patch[nextCPID].positionOS, patch[id].positionOS, patch[nextCPID].normalOS);
      
    return output;
}
  

 
[domain("tri")]      
Varyings PNTriTessDomain (HSPCOutput tessFactors, const OutputPatch<HSInput,3> patch, float3 bary : SV_DOMAINLOCATION)
{ 
    float u = bary.x;
    float v = bary.y;
    float w = bary.z;

    float uu = u * u;
    float vv = v * v;
    float ww = w * w;
    float uu3 = 3 * uu;
    float vv3 = 3 * vv;
    float ww3 = 3 * ww;

    float3 b300 = patch[0].positionOS;
    float3 b210 = patch[0].positionOS1;
    float3 b120 = patch[0].positionOS2;
    float3 b030 = patch[1].positionOS;
    float3 b021 = patch[1].positionOS1;
    float3 b012 = patch[1].positionOS2;
    float3 b003 = patch[2].positionOS;
    float3 b102 = patch[2].positionOS1;
    float3 b201 = patch[2].positionOS2;  

    float3 E = (b210 + b120 + b021 + b012 + b102 + b201) / 6.0;
    float3 V = (b003 + b030 + b300) / 3.0; 
    float3 b111 = E + (E - V) / 2.0f;   //http://alex.vlachos.com/graphics/CurvedPNTriangles.pdf
  
    float3 positionOS = b300 * uu * u + b030 * vv * v + b003 * ww * w 
                    + b210 * uu3 * v 
                    + b120 * vv3 * u
                    + b021 * vv3 * w
                    + b012 * ww3 * v
                    + b102 * ww3 * u
                    + b201 * uu3 * w
                    + b111 * 6.0 * w * u * v;
   
    float3 normalOS = patch[0].normalOS * u 
                    + patch[1].normalOS * v
                    + patch[2].normalOS * w;
    normalOS = normalize(normalOS);

    float2 texcoord = patch[0].texcoord * u
                    + patch[1].texcoord * v
                    + patch[2].texcoord * w;
       
    Varyings output; 
    output.positionCS = TransformObjectToHClip(positionOS);  
    output.normalWS = TransformObjectToWorldNormal(normalOS);
    output.uv = texcoord;
    return output; 
}
 
half4 PNTriTessFrag(Varyings input) : SV_Target{  
     
    Light mainLight = GetMainLight();
    half3 baseColor = SAMPLE_TEXTURE2D(_BaseColor,sampler_BaseColor,input.uv).xyz;  
    half3 diffuseColor = LightingLambert(mainLight.color, mainLight.direction, input.normalWS);
      
    return half4(diffuseColor * baseColor ,1.0); 
}
 
#endif