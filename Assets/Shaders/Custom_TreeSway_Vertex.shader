Shader "Custom/TreeSway_Vertex" 
{
	Properties 
	{
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_TimeOffset ("Time Offset", float) = 0.0
		_Bend ("Bend", float) = 1.0
		_speed ("Speed", float) = 1.0
		_Brightness("Overbright", float) = 1.0
	}
	
	SubShader 
	{
		Tags { "RenderType"="Opaque" "Queue"="Geometry"}
		LOD 200
		Lighting Off
		Fog{ Mode Off }

		Pass
		{
			Tags { "LightMode" = "ForwardBase" }
		
			CGPROGRAM
			#include "UnityCG.cginc"
			#include "CustomLighting.cginc"
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma target 2.0
			
			#include "UnityCG.cginc"

            sampler2D _MainTex;
            half4 _MainTex_ST;
            half _Bend, _speed, _Brightness, _TimeOffset;
    
            struct appdata_D
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 texcoord : TEXCOORD0;
                float4 texcoordLM : TEXCOORD1;
                float4 color : COLOR;
            };
    
            struct v2f
            {
                float4 Pos : POSITION;
                float3 normal : NORMAL;
                float2 UvMain : TEXCOORD0;
            };
    
            v2f vert (appdata_D v) 
			{
				v2f o;
                float speed = (_Time[1] + _TimeOffset) * _speed;
                float3 offst = float3(0, 0, 0);
                offst.x += (_Bend * v.color.z) * ((sin(speed)) * 0.75);
                offst.z += (_Bend * v.color.z) * ((cos(speed)) * 0.65);
                v.vertex.xyz += mul((float3x3)unity_WorldToObject, offst);
                o.Pos = UnityObjectToClipPos(v.vertex);
                o.UvMain = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.normal = v.normal;
                return o;
			}
			
			half4 frag(v2f i) : COLOR
			{
				return half4(tex2D(_MainTex, i.UvMain).rgb * _Brightness, 1.0) * CustomLighting(i.normal);
			}

			ENDCG
		}
	} 
}