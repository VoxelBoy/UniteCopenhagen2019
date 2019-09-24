Shader "Custom/Completed/TreeSway_Vertex" 
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
	        "RenderPipeline"="UniversalPipeline"
	    }
	    
	    Pass
	    {
	        Tags { "LightMode" = "UniversalForward" }
	        
	        HLSLPROGRAM
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Custom.hlsl"
            
	        // Required to compile gles 2.0 with standard srp library
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0
            
            #pragma vertex vert
            #pragma fragment frag
            
            CBUFFER_START(UnityPerMaterial)
            half _Bend, _Speed, _Brightness, _TimeOffset;
            half4 _MainTex_ST;
            CBUFFER_END
            
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            
            v2f_common vert (appdata_common v)
            {
                v2f_common o;
                
                float speed = (_Time[1] + _TimeOffset) * _Speed;
                float3 offst = float3(0, 0, 0);
                offst.x += (_Bend * v.color.z) * ((sin(speed)) * 0.75);
                offst.z += (_Bend * v.color.z) * ((cos(speed)) * 0.65);
                v.vertex.xyz += mul((float3x3)unity_WorldToObject, offst);
                
                o.pos = TransformObjectToHClip(v.vertex);
                o.normal = v.normal;
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                OUTPUT_SH(o.normal.xyz, o.vertexSH);
                
                return o;
            }
            
            half4 frag(v2f_common i) : COLOR
			{
			    half4 lighting = CustomLighting(i.normal, i.vertexSH);
			    half4 color = half4(SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv).rgb * _Brightness, 1);
				return color * lighting;
			}
            
	        ENDHLSL
	    }
	}
	
	SubShader 
	{
		Tags
		{
            "RenderType"="Opaque"
            "Queue"="Geometry"
		}
		
		UsePass "Custom/TreeSway_Vertex/Main"
	} 
}