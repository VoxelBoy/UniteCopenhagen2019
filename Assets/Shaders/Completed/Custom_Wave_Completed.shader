Shader "Custom/Completed/Wave"
{
	Properties
	{
		_MainTex("Main Texture", 2D) = "white" {}
		_WaveSpeed("Wave Speed", float) = 0.01
	}
	
	SubShader
	{
	    Tags
	    {
            "RenderType"="Transparent"
            "Queue" = "Geometry+99"
            "RenderPipeline"="UniversalPipeline"
        }
	    
	    ZWrite Off
	    Blend SrcAlpha OneMinusSrcAlpha
	    
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
            half4 _MainTex_ST;
            half _WaveSpeed;
            CBUFFER_END
            
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            
            v2f_common vert (appdata_common v)
            {
                v2f_common o;
                
                o.pos = TransformObjectToHClip(v.vertex.xyz);
                o.normal = v.normal;
                o.color = v.color;
                OUTPUT_SH(o.normal.xyz, o.vertexSH);
                
                half waveTime = frac(_Time[1] * _WaveSpeed);
                half2 _vTexXYCord = half2(v.texcoord.x, v.texcoord.y - waveTime);
                o.uv = TRANSFORM_TEX(_vTexXYCord, _MainTex);
                
                return o;
            }
            
            half4 frag(v2f_common i) : COLOR 
            {
                half4 lighting = CustomLighting(i.normal, i.vertexSH);
			    half4 color = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv);
				return half4(color.rgb, color.a * i.color.a) * lighting;
            }
            
	        ENDHLSL
	    }
	}
	
	SubShader {
		Tags 
		{ 
			"RenderType"="Transparent" 
			"Queue" = "Geometry+99"
		}

		UsePass "Custom/Wave/Main"
	} 
}
