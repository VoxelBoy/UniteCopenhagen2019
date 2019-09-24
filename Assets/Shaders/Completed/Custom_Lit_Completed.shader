Shader "Custom/Completed/Lit" 
{
	Properties 
	{
		_MainTex ("Base (RGB)", 2D) = "white" {}
		[Toggle(TogglePlanerUvs)] _PlanerUvs("PlanerUvs", Float) = 0
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
            
            #pragma multi_compile __ TogglePlanerUvs
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Custom.hlsl"
            
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            
            #pragma vertex vert
            #pragma fragment frag
            
            struct appdata {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 texcoord : TEXCOORD0;
            };
            
            struct v2f {
                float4 Pos : POSITION;
                float3 normal : NORMAL;
                float2 UvMain : TEXCOORD0;
                half3 vertexSH : TEXCOORD1;
            };
            
            v2f vert (appdata v) {
                v2f o;
                
                //o.Pos = UnityObjectToClipPos(v.vertex);
                o.Pos = TransformObjectToHClip(v.vertex.xyz);
                o.normal = v.normal;
    
                #ifdef TogglePlanerUvs
                o.UvMain = mul(UNITY_MATRIX_M, v.vertex).xz * 0.3;
                #else
                o.UvMain = v.texcoord.xy;
                #endif
                
                OUTPUT_SH(o.normal.xyz, o.vertexSH);
    
                return o;
            }
            
            float4 frag(v2f i) : COLOR
            {
                //return tex2D(_MainTex, i.UvMain) * CustomLighting(i.normal);
                return SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.UvMain) * CustomLighting(i.normal, i.vertexSH);
            }
            
	        ENDHLSL
	    }
	}
	
	SubShader {
		Tags { "RenderType"="Opaque" "IgnoreProjector"="True" "Queue" = "Geometry" }
		ZWrite On
		
		Pass
        {
            Tags { "LightMode" = "ForwardBase" }
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"
            #include "../Custom.cginc"
            #pragma multi_compile __ TogglePlanerUvs
    
            sampler2D _MainTex;
            
            struct appdata {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 texcoord : TEXCOORD0;
            };
            
            struct v2f {
                float4 Pos : POSITION;
                float3 normal : NORMAL;
                fixed2 UvMain : TEXCOORD0;
            };
    
            v2f vert (appdata v) {
                v2f o;
                o.Pos = UnityObjectToClipPos(v.vertex);
                o.normal = v.normal;
    
                #ifdef TogglePlanerUvs
                o.UvMain = mul(UNITY_MATRIX_M, v.vertex).xz * 0.3;
                #else
                o.UvMain = fixed2(v.texcoord.xy);
                #endif
    
                return o;
            }
            
            fixed4 frag(v2f i) : COLOR
            {
                return tex2D(_MainTex, i.UvMain) * CustomLighting(i.normal);
            }
            ENDCG
        }
	} 
}
