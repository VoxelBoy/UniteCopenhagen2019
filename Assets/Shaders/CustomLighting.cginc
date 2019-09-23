#include "AutoLight.cginc"

fixed4 _LightColor0;

float4 CustomLighting(float3 normal)
{
    normal = normalize(normal);
    float3 worldNormal = UnityObjectToWorldNormal(normal);
    float nl = max(0, dot(worldNormal, _WorldSpaceLightPos0.xyz));
    float4 diffuse = nl * _LightColor0;
    float3 ambient = ShadeSH9(half4(normal,1));
    float attenuation = LIGHT_ATTENUATION(i);
    float4 lighting = diffuse * attenuation + float4(ambient,1);
    return lighting;
}