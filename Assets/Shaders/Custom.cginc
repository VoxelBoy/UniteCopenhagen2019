#include "AutoLight.cginc"

fixed4 _LightColor0;

struct appdata_common {
    float4 vertex : POSITION;
    float3 normal : NORMAL;
    float4 texcoord : TEXCOORD0;
    float4 color : COLOR;
};

struct v2f_common {
    float4 pos : POSITION;
    float3 normal : NORMAL;
    fixed2 uv : TEXCOORD0;
    fixed4 uv2 : TEXCOORD1;
    fixed4 color : COLOR;
};

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