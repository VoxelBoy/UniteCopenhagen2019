Shader "Custom/Completed/TreeSway_Vertex" 
{
	Properties 
	{
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_TimeOffset ("Time Offset", float) = 0.0
		_Bend ("Bend", float) = 1.0
		_speed ("Speed", float) = 1.0
		_Brightness("Overbright", float) = 1.0
	}
	
	SubShader {
	    Tags { "RenderType"="Opaque" "IgnoreProjector"="True" "Queue" = "Geometry" "RenderPipeline"="UniversalPipeline"}
	    ZWrite On
	    
	    Pass
	    {
	        Tags { "LightMode" = "UniversalForward" }
	        
	        HLSLPROGRAM
	        // Required to compile gles 2.0 with standard srp library
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Custom.hlsl"
            
            CBUFFER_START(UnityPerMaterial)
            half _Bend, _speed, _Brightness, _TimeOffset;
            half4 _MainTex_ST;
            CBUFFER_END
            
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            
            #pragma vertex vert
            #pragma fragment frag
            
            struct appdata {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 texcoord : TEXCOORD0;
                float4 color : COLOR;
            };
            
            struct v2f {
                float4 Pos : POSITION;
                float3 normal : NORMAL;
                float2 UvMain : TEXCOORD0;
                half3 vertexSH : TEXCOORD1;
            };
            
            v2f vert (appdata v) {
                v2f o;
                
                float speed = (_Time[1] + _TimeOffset) * _speed;
                float3 offst = float3(0, 0, 0);
                offst.x += (_Bend * v.color.z) * ((sin(speed)) * 0.75);
                offst.z += (_Bend * v.color.z) * ((cos(speed)) * 0.65);
                v.vertex.xyz += mul((float3x3)unity_WorldToObject, offst);
                //o.Pos = UnityObjectToClipPos(v.vertex);
                o.Pos = TransformObjectToHClip(v.vertex.xyz);
                o.normal = v.normal;
                o.UvMain = TRANSFORM_TEX(v.texcoord, _MainTex);
                
                OUTPUT_SH(o.normal.xyz, o.vertexSH);
    
                return o;
            }
            
            half4 frag(v2f i) : COLOR
			{
				return half4(SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.UvMain).rgb * _Brightness, 1.0) * CustomLighting(i.normal, i.vertexSH);
			}
            
	        ENDHLSL
	    }
	}
	
	SubShader 
	{
		Tags { "RenderType"="Opaque" "Queue"="Geometry"}
		LOD 200

		Pass
		{
			Tags { "LightMode" = "ForwardBase" }
		
			CGPROGRAM
			#include "UnityCG.cginc"
			#include "../Custom.cginc"
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