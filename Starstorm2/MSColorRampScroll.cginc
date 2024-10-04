#include "UnityCG.cginc"
#include "Lighting.cginc"
#include "AutoLight.cginc"

struct appdata
{
    float4 vertex : POSITION;
    float3 normal : NORMAL;
    float4 tangent : TANGENT;
    float2 uv : TEXCOORD0;
};

struct v2f
{
    float4 vertex : SV_POSITION;
    float2 uv : TEXCOORD0;
    float3 normal : TEXCOORD1;
    float3 tangent : TEXCOORD2;
    float3 bitangent : TEXCOORD3;
    float4 local_space : TEXCOORD4;
    float3 wPos : TEXCOORD5;
    LIGHTING_COORDS(6,7)
};

fixed4 _Tint;
sampler2D _Ramp;
uniform float4 _Ramp_TexelSize;
uniform float4 _Ramp_ST;
float4 _ScrollVector;
float _Normal;
sampler2D _NormalTex;
uniform float4 _NormalTex_ST;
uniform float4 _NormalTex_TexelSize;
float _NormalPower;

float _Gloss;
float _SpecularExponent;
float _SpecularOuterBandThreshold;
float _SpecularPower;

float _ShadowThreshold;
float _ShadowPower;

fixed4 _FresnelTint;
sampler2D _FresnelRamp;
uniform float4 _FresnelRamp_TexelSize;
uniform float4 _FresnelRamp_ST;
float _Fresnel;
float _FresnelBlending;
float _FresnelThreshold;
float _FresnelPower;

v2f vert (appdata v)
{
    v2f o;
    o.vertex = UnityObjectToClipPos(v.vertex);
    o.uv = v.uv;
    o.normal = v.normal;
    o.tangent = v.tangent;
    o.bitangent = cross(o.normal, o.tangent) * (v.tangent.w * unity_WorldTransformParams.w);
    o.local_space = v.vertex;
    o.wPos = mul(unity_ObjectToWorld, v.vertex);
    TRANSFER_VERTEX_TO_FRAGMENT(o);
    return o;
}

fixed4 frag (v2f i) : SV_Target
{
    _ScrollVector.xyz = normalize(_ScrollVector.xyz);
    float samplePosition = (-dot(i.local_space.xyz, _ScrollVector.xyz) + _Ramp_ST.z) * _Ramp_ST.x;
    float4 sampleColor = tex2D(_Ramp, float2(samplePosition + _Time.y * _ScrollVector.w, 0));
    float3 N;
    if(_Normal){
        float3 tangentSpaceNormal = UnpackNormal(tex2D(_NormalTex, i.uv.xy * _NormalTex_ST.xy + _NormalTex_ST.zw));
        tangentSpaceNormal = normalize(lerp(float3(0,0,1), tangentSpaceNormal, _NormalPower));
        float3x3 mtxTangToWorld = {
            i.tangent.x, i.bitangent.x, i.normal.x,
            i.tangent.y, i.bitangent.y, i.normal.y,
            i.tangent.z, i.bitangent.z, i.normal.z
        };
        N = mul(mtxTangToWorld, _Normal ? tangentSpaceNormal : float3(1,1,1));
    }
    else{
        N = normalize(i.normal.xyz);
    }
    float3 L = normalize(UnityWorldSpaceLightDir(i.wPos));
    float attenuation = LIGHT_ATTENUATION(i);
    float3 lambertian = saturate(dot(N, L));
    float3 shadows = -step(lambertian * attenuation * _LightColor0.xyz, 1 - _ShadowThreshold) * _ShadowPower;

    //Speculars
    float3 V = normalize(_WorldSpaceCameraPos - i.wPos);
    float3 H = normalize (L + V);
    float specularExponent = exp2(_Gloss * _SpecularExponent) + 1;
    float3 specularLight = saturate(dot(H, N)) * (lambertian > 0);
    specularLight = pow(specularLight, specularExponent) * _Gloss * attenuation * _LightColor0.xyz;
    specularLight = step(0.7, specularLight) * _SpecularPower + step(0.7 * _SpecularOuterBandThreshold , specularLight) * _SpecularPower * (0.334);
    
    float fresnelSamplePosition = (-dot(i.local_space.xyz, _ScrollVector.xyz) + _FresnelRamp_ST.z) * _FresnelRamp_ST.x;
    float fresnelFactor = 1 - step(_FresnelThreshold, dot(V, N));
    float3 fresnel = fresnelFactor *  _Fresnel * _FresnelPower * tex2D(_FresnelRamp, float2(fresnelSamplePosition + _Time.y * _ScrollVector.w, 0)) * _FresnelTint;
    
    return _FresnelBlending || !_Fresnel ?
        float4((sampleColor + shadows + specularLight + fresnel) * _Tint, 1) :
        float4(lerp((sampleColor *attenuation + shadows + specularLight) * _Tint, fresnel, fresnelFactor), 1);
}