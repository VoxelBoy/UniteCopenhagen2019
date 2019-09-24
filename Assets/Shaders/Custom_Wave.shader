Shader "Custom/Wave" {
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
		}

        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha
        
		Pass
		{
		    Name "Main"
			Tags { "LightMode" = "ForwardBase" }

			CGPROGRAM
            #include "UnityCG.cginc"
            #include "Custom.cginc"
            
            #pragma vertex vert
            #pragma fragment frag

            sampler2D _MainTex;
            fixed4 _MainTex_ST;
            fixed _WaveSpeed;

            v2f_common vert (appdata_common v)
            {
                v2f_common o;
                
                o.pos = UnityObjectToClipPos(v.vertex);
                o.normal = v.normal;
                o.color = v.color;
                
                fixed waveTime = frac(_Time[1] * _WaveSpeed);
                fixed2 _vTexXYCord = fixed2(v.texcoord.x, v.texcoord.y - waveTime);
                o.uv = TRANSFORM_TEX(_vTexXYCord, _MainTex);
                
                return o;
            }

            fixed4 frag(v2f_common i) : COLOR 
            {
                half4 lighting = CustomLighting(i.normal);
			    half4 color = tex2D(_MainTex, i.uv);
				return fixed4(color.rgb, color.a * i.color.a * 0.5) * lighting;
            }
			ENDCG
		}
	} 
}
