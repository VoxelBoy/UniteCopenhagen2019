Shader "Custom/Completed/Lit" 
{
	Properties 
	{
		_MainTex ("Base (RGB)", 2D) = "white" {}
		[Toggle(TogglePlanerUvs)] _PlanerUvs("PlanerUvs", Float) = 0
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
            
            #pragma multi_compile __ TogglePlanerUvs
            
            #pragma vertex vert
            #pragma fragment frag
            
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            
            v2f_common vert (appdata_common v)
            {
                v2f_common o;
                
                o.pos = TransformObjectToHClip(v.vertex.xyz);
                o.normal = v.normal;
    
                #ifdef TogglePlanerUvs
                o.uv = mul(UNITY_MATRIX_M, v.vertex).xz * 0.3;
                #else
                o.uv = v.texcoord.xy;
                #endif
                
                OUTPUT_SH(o.normal.xyz, o.vertexSH);
    
                return o;
            }
            
            float4 frag(v2f_common i) : COLOR
            {
                half4 lighting = CustomLighting(i.normal, i.vertexSH);
			    half4 color = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv);
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
            "Queue" = "Geometry"
		}
		
		UsePass "Custom/Lit/Main"
	} 
}
