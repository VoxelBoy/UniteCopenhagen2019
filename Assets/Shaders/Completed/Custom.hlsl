struct appdata_common {
    float4 vertex : POSITION;
    float3 normal : NORMAL;
    float4 texcoord : TEXCOORD0;
    float4 color : COLOR;
};

struct v2f_common {
    float4 pos : POSITION;
    float3 normal : NORMAL;
    half2 uv : TEXCOORD0;
    half4 uv2 : TEXCOORD1;
    half3 vertexSH : TEXCOORD2;
    half4 color : COLOR;
};

float4 CustomLighting(float3 normal, half3 vertexSH)
{
    normal = normalize(normal);
    
    float3 normalWS = TransformObjectToWorldDir(normal);
    
    Light mainLight = GetMainLight();
    half3 attenuatedLightColor = mainLight.color * (mainLight.distanceAttenuation * mainLight.shadowAttenuation);
    half3 bakedGI = SampleSHPixel(vertexSH, normalWS);
    half3 diffuseColor = bakedGI + LightingLambert(attenuatedLightColor, mainLight.direction, normalWS);

    return float4(diffuseColor,1);
}