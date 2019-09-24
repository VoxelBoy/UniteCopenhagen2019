Shader "Custom/TreeSway_Vertex" 
{
	Properties 
	{
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_TimeOffset ("Time Offset", float) = 0.0
		_Bend ("Bend", float) = 1.0
		_Speed ("Speed", float) = 1.0
		_Brightness("Overbright", float) = 1.0
	}
	
	SubShader 
	{
		Tags
		{
            "RenderType"="Opaque"
            "Queue"="Geometry"
		}

		Pass
		{
			Tags { "LightMode" = "ForwardBase" }
		
			CGPROGRAM
			#include "UnityCG.cginc"
			#include "Custom.cginc"
			
			#pragma vertex vert
			#pragma fragment frag

            sampler2D _MainTex;
            half4 _MainTex_ST;
            half _Bend, _Speed, _Brightness, _TimeOffset;
    
            v2f_common vert (appdata_common v) 
			{
				v2f_common o;
                float speed = (_Time[1] + _TimeOffset) * _Speed;
                float3 offst = float3(0, 0, 0);
                offst.x += (_Bend * v.color.z) * ((sin(speed)) * 0.75);
                offst.z += (_Bend * v.color.z) * ((cos(speed)) * 0.65);
                v.vertex.xyz += mul((float3x3)unity_WorldToObject, offst);
                o.pos = UnityObjectToClipPos(v.vertex);
                o.normal = v.normal;
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
			}
			
			half4 frag(v2f_common i) : COLOR
			{
				return half4(tex2D(_MainTex, i.uv).rgb * _Brightness, 1.0) * CustomLighting(i.normal);
			}

			ENDCG
		}
	} 
}