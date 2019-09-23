Shader "Custom/Wave" {
	Properties {
		_MainTex("Main Texture", 2D) = "white" {}
		_WaveSpeed("Wave Speed", float) = 0.01
	}
	SubShader {
		Tags 
		{ 
			"RenderType"="Transparent" 
			"IgnoreProjector"="True" 
			"Queue" = "Geometry+99"
		}
		LOD 200

		Pass {
			Tags { "LightMode" = "ForwardBase" }
			ZWrite off
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
            #include "UnityCG.cginc"
            #include "CustomLighting.cginc"
            
            #pragma vertex vert
            #pragma fragment frag
            #pragma fragmentoption ARB_precision_hint_fastest

            sampler2D _MainTex;
            fixed4 _MainTex_ST;
            fixed _WaveSpeed; 
            
            struct appdata_D {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 texcoord : TEXCOORD0;
                float4 color : COLOR;
            };
            struct v2f {
                float4 Pos : SV_POSITION;
                fixed2 UvMain : TEXCOORD0;
                float3 normal : NORMAL;
                fixed4 color : COLOR;
            };

            v2f vert (appdata_D v) {
                v2f o;
                o.Pos = UnityObjectToClipPos(v.vertex);
                fixed waveTime = frac(_Time[1] * _WaveSpeed);
                fixed2 _vTexXYCord = fixed2(v.texcoord.x, v.texcoord.y - waveTime);
                o.UvMain = TRANSFORM_TEX(_vTexXYCord, _MainTex);
                o.color = v.color;
                o.normal = v.normal;
                return o;
            }

            fixed4 frag(v2f i) : COLOR 
            {
                fixed4 c = tex2D(_MainTex, i.UvMain);
                return fixed4(c.rgb, c.a * i.color.a * 0.5) * CustomLighting(i.normal);
            }
			ENDCG
		}
	} 
	FallBack Off
}
