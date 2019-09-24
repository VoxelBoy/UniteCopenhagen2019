Shader "Custom/Water"
{
	Properties
	{
		_MainTex("Main Texture", 2D) = "white" {}
		_WaveTex("Wave Texture", 2D) = "bump" {}
		_WaveSpeed("Wave Speed", Range(0.0, 0.1)) = 0.01
		_WaveAmount("Wave Amount", Range(0.0, 2.0)) = 0.5
		_InteriorColor ("Interior Color (RGBA)", Color) = (1.0,1.0,1.0,1.0)
		_ShoreColor ("Shore Color (RGBA)", Color) = (0.5,0.5,0.5,1.0)
	}
	
	SubShader
	{
		Tags
		{
            "RenderType"="Opaque"
            "Queue" = "Geometry+90"
		}

		Pass
		{
		    Name "Main"
			Tags { "LightMode" = "ForwardBase" }

			CGPROGRAM
            #include "UnityCG.cginc"
            #include "Custom.cginc"
            
            #pragma vertex vert
            #pragma fragment frag

            half4 _MainTex_ST, _WaveTex_ST, _ShoreColor, _InteriorColor;
            half _WaveSpeed, _WaveAmount;
            
            sampler2D _MainTex, _WaveTex;

            v2f_common vert(appdata_common v)
            {
                v2f_common o;
                
                o.pos = UnityObjectToClipPos(v.vertex);
                o.normal = v.normal;
                o.uv = v.texcoord.xy;
                o.color = v.color;
                
                half2 uvs = mul(UNITY_MATRIX_M, v.vertex).xz * 0.3;

                half4 _vTexXYCord = fixed4(uvs.x, uvs.y, uvs.x, uvs.y);
                //Assigning all ST XY coords for both MainTex and WaveTex into one fixed4
                half4 _ST_XYCord = fixed4(_MainTex_ST.x, _MainTex_ST.y, _WaveTex_ST.x, _WaveTex_ST.y);
                //Assigning all ST_ZW Coords for both MainTex and WaveTex into one fixed4
                half4 _ST_ZWCord = fixed4(_MainTex_ST.z, _MainTex_ST.w, _WaveTex_ST.z, _WaveTex_ST.w);
                //Performing one calculation on all fixed4 vectors
                half4 _UVCalc = fixed4(_vTexXYCord * _ST_XYCord + _ST_ZWCord);
                //Assign the UVMain texCoord
                o.uv = _UVCalc.xy;
                //Performing offset of UVs in either + or - directions to one fixed4
                half _timeOffset = frac(_Time[1] * _WaveSpeed);
                o.uv2 = fixed4(_UVCalc.x + _timeOffset, _UVCalc.y + _timeOffset, _UVCalc.z - _timeOffset, _UVCalc.w - _timeOffset);

                return o;
            }

            fixed4 frag(v2f_common i) : COLOR
            {
                half4 lighting = CustomLighting(i.normal);
                
                half distort = tex2D(_WaveTex, i.uv2.xy).r * tex2D(_WaveTex, i.uv2.zw).r;
                distort *=  _WaveAmount;
                half3 color = tex2D(_MainTex, (i.uv + distort)).rgb;
                
                half3 MixColEdge = lerp(color.rgb, (color.rgb *_ShoreColor.rgb), i.color.rrr);
                half3 MixColInterior = lerp(color.rgb, (color.rgb * _InteriorColor.rgb), i.color.ggg);
                half3 finalColor = lerp(MixColEdge.rgb, MixColInterior.rgb, i.color.ggg);
                
                return half4(finalColor, 1) * lighting;
            }
			ENDCG
		}
	} 
}
