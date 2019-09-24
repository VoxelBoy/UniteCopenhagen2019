﻿Shader "Custom/Completed/Water" {
	Properties {
		_MainTex("Main Texture", 2D) = "white" {}
		_WaveTex("Wave Texture", 2D) = "bump" {}
		_WaveSpeed("Wave Speed", Range(0.0, 0.1)) = 0.01
		_WaveAmount("Wave Amount", Range(0.0, 2.0)) = 0.5
		_InteriorColor ("Interior Color (RGBA)", Color) = (1.0,1.0,1.0,1.0)
		_ShoreColor ("Shore Color (RGBA)", Color) = (0.5,0.5,0.5,1.0)
	}
	
	SubShader {
	    Tags { "RenderType"="Opaque" "IgnoreProjector"="True" "Queue" = "Geometry+90" "RenderPipeline"="UniversalPipeline"}
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
            half4 _MainTex_ST, _WaveTex_ST, _ShoreColor, _InteriorColor;
            half _WaveSpeed, _WaveAmount;
            CBUFFER_END
            
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            
            TEXTURE2D(_WaveTex);
            SAMPLER(sampler_WaveTex);
            
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
                half4 color : COLOR;
                half4 UVTwoDirictions : TEXCOORD2;
            };
            
            v2f vert (appdata v) {
                v2f o;
                half _timeOffset = frac(_Time[1] * _WaveSpeed);
                //o.Pos = UnityObjectToClipPos(v.vertex);
                o.Pos = TransformObjectToHClip(v.vertex.xyz);
                o.normal = v.normal;
                o.UvMain = v.texcoord.xy;
                OUTPUT_SH(o.normal.xyz, o.vertexSH);
                
                half2 uvs = mul(UNITY_MATRIX_M, v.vertex).xz * 0.3;

                half4 _vTexXYCord = half4(uvs.x, uvs.y, uvs.x, uvs.y);
                //Assigning all ST XY coords for both MainTex and WaveTex into one half4
                half4 _ST_XYCord = half4(_MainTex_ST.x, _MainTex_ST.y, _WaveTex_ST.x, _WaveTex_ST.y);
                //Assigning all ST_ZW Coords for both MainTex and WaveTex into one half4
                half4 _ST_ZWCord = half4(_MainTex_ST.z, _MainTex_ST.w, _WaveTex_ST.z, _WaveTex_ST.w);
                //Performing one calculation on all half4 vectors
                half4 _UVCalc = half4(_vTexXYCord * _ST_XYCord + _ST_ZWCord);
                //Assign the UVMain texCoord
                o.UvMain = _UVCalc.xy;
                //Performing offset of UVs in either + or - directions to one half4
                o.UVTwoDirictions = half4(_UVCalc.x + _timeOffset, _UVCalc.y + _timeOffset, _UVCalc.z - _timeOffset, _UVCalc.w - _timeOffset);

                o.color = v.color;
    
                return o;
            }
            
            half4 frag(v2f i) : COLOR
            {
                half distort = SAMPLE_TEXTURE2D(_WaveTex, sampler_WaveTex, i.UVTwoDirictions.xy ).r * SAMPLE_TEXTURE2D(_WaveTex, sampler_WaveTex, i.UVTwoDirictions.zw).r;
                distort *= _WaveAmount;
                half3 c = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, (i.UvMain + distort)).rgb;
                half3 MixColEdge = lerp(c.rgb, (c.rgb *_ShoreColor.rgb), i.color.rrr);
                half3 MixColInterior = lerp(c.rgb, (c.rgb * _InteriorColor.rgb), i.color.ggg);
                half3 finalColor = lerp(MixColEdge.rgb, MixColInterior.rgb, i.color.ggg);
                return half4(finalColor, 1) * CustomLighting(i.normal, i.vertexSH);
            }
            
	        ENDHLSL
	    }
	}
	
	SubShader {
		Tags { "RenderType"="Opaque" "IgnoreProjector"="True" "Queue" = "Geometry+90"}
		LOD 200

		Pass {
			Tags { "LightMode" = "ForwardBase" }

			CGPROGRAM
            #include "UnityCG.cginc"
            #include "../Custom.cginc"
            
            #pragma vertex vert
            #pragma fragment frag
            #pragma fragmentoption ARB_precision_hint_fastest

            uniform sampler2D _MainTex, _WaveTex;
            half4 _MainTex_ST, _WaveTex_ST, _ShoreColor, _InteriorColor;
            half _WaveSpeed, _WaveAmount;
            
            struct appdata_D {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 texcoord : TEXCOORD0;
                float4 color : COLOR;
            };
            
            struct v2f {
                half4 Pos : SV_POSITION;
                half2 UvMain : TEXCOORD0;
                float3 normal : NORMAL;
                fixed4 color : COLOR;
                half4 UVTwoDirictions : TEXCOORD1;
            };

            v2f vert(appdata_D v)
            {
                v2f o;
                half _timeOffset = frac(_Time[1] * _WaveSpeed);
                o.Pos = UnityObjectToClipPos(v.vertex);
                //Assigning all vertex coord xy values into one fixed 4

                half2 uvs = mul(UNITY_MATRIX_M, v.vertex).xz * 0.3;

                half4 _vTexXYCord = fixed4(uvs.x, uvs.y, uvs.x, uvs.y);
                //Assigning all ST XY coords for both MainTex and WaveTex into one fixed4
                half4 _ST_XYCord = fixed4(_MainTex_ST.x, _MainTex_ST.y, _WaveTex_ST.x, _WaveTex_ST.y);
                //Assigning all ST_ZW Coords for both MainTex and WaveTex into one fixed4
                half4 _ST_ZWCord = fixed4(_MainTex_ST.z, _MainTex_ST.w, _WaveTex_ST.z, _WaveTex_ST.w);
                //Performing one calculation on all fixed4 vectors
                half4 _UVCalc = fixed4(_vTexXYCord * _ST_XYCord + _ST_ZWCord);
                //Assign the UVMain texCoord
                o.UvMain = _UVCalc.xy;
                //Performing offset of UVs in either + or - directions to one fixed4
                o.UVTwoDirictions = fixed4(_UVCalc.x + _timeOffset, _UVCalc.y + _timeOffset, _UVCalc.z - _timeOffset, _UVCalc.w - _timeOffset);

                o.color = v.color;
                o.normal = v.normal;
                return o;
            }

            fixed4 frag(v2f i) : COLOR
            {
                half distort = tex2D(_WaveTex, i.UVTwoDirictions.xy ).r * tex2D(_WaveTex, i.UVTwoDirictions.zw).r;
                distort *=  _WaveAmount;
                half3 c = tex2D(_MainTex, (i.UvMain + distort)).rgb;
                half3 MixColEdge = lerp(c.rgb, (c.rgb *_ShoreColor.rgb), i.color.rrr);
                half3 MixColInterior = lerp(c.rgb, (c.rgb * _InteriorColor.rgb), i.color.ggg);
                half3 finalColor = lerp(MixColEdge.rgb, MixColInterior.rgb, i.color.ggg);
                return half4(finalColor, 1) * CustomLighting(i.normal);
            }
			ENDCG
		}
	} 
}