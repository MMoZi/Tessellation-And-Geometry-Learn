#ifndef GEOMETRY_SHOW_NORMAL
#define GEOMETRY_SHOW_NORMAL

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

CBUFFER_START(UnityPerMaterial)
float4 _LineColor;
float _LineLength; 
CBUFFER_END
 
  
struct Attributes
{
    float3 positionOS   : POSITION;
    float3 normalOS     : NORMAL;  
    
};

struct Varyings
{
    float4  positionCS      : SV_POSITION; 
};

struct GSInput{
    float3  positionWS      : TEXCOORD0; 
    float3  normalWS        : TEXCOORD2;  
};


GSInput ShowNormalVert(Attributes input){

    GSInput output;
    output.positionWS = TransformObjectToWorld(input.positionOS); 
    output.normalWS = TransformObjectToWorldNormal(input.normalOS);
    return output;
}


[maxvertexcount(8)]
void ShowNormalGS(triangle GSInput p[3], inout LineStream<Varyings> triStream)
{
 
    Varyings p0;
    p0.positionCS = TransformWorldToHClip(p[0].positionWS);// UnityObjectToClipPos(p[0].pos); 
    triStream.Append(p0);

    Varyings p1;
    float3 positionWS = p[0].positionWS + p[0].normalWS * _LineLength;
    p1.positionCS = TransformWorldToHClip(positionWS); 
    triStream.Append(p1); 
    triStream.RestartStrip();
 
 

 
    p0.positionCS = TransformWorldToHClip(p[1].positionWS);// UnityObjectToClipPos(p[0].pos); 
    triStream.Append(p0);
    positionWS = p[1].positionWS + p[1].normalWS * _LineLength;
    p1.positionCS = TransformWorldToHClip(positionWS); 
    triStream.Append(p1); 
    triStream.RestartStrip();
    

 
    p0.positionCS = TransformWorldToHClip(p[2].positionWS);// UnityObjectToClipPos(p[0].pos); 
    triStream.Append(p0);
    positionWS = p[2].positionWS + p[2].normalWS * _LineLength;
    p1.positionCS = TransformWorldToHClip(positionWS); 
    triStream.Append(p1);  
 
}

half4 ShowNormalFrag(Varyings input) : SV_Target{  
    return _LineColor; 
}
 
#endif