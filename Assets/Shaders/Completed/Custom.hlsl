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