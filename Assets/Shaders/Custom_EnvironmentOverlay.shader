Shader "Custom/EnvironmentOverlay" 
{
	Properties 
	{
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_alphaUVShift ("AlphaUVShift", float) = 0.5 
	}

	SubShader 
	{
		Tags 
		{
			"RenderType"="Transparent" 
			"Queue"="Geometry+1" 
			"IgnoreProjector"="True" 
			"ForceNoShadowCasting"="True"
		}

 		LOD 100
 		ZWrite Off
 		Blend SrcAlpha OneMinusSrcAlpha
 		Cull back

		Pass
		{
			Tags { "LightMode" = "ForwardBase" }

			CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma fragmentoption ARB_precision_hint_fastest
            #pragma target 2.0
            
            #include "UnityCG.cginc"
            #include "CustomLighting.cginc"

            uniform sampler2D _MainTex;
            half4 _MainTex_ST;
            float _alphaUVShift;
    
            struct vertexInput
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 texcoord : TEXCOORD0;
                float4 uv2 : TEXCOORD1;
            };
    
            struct vertexOutput
            {
                half4 Pos : SV_POSITION;
                float3 normal : NORMAL;
                half2 UvMain : TEXCOORD0;
            };

            vertexOutput vert(vertexInput v)
            {
                vertexOutput o;
                o.Pos = UnityObjectToClipPos(v.vertex);
                o.UvMain = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.normal = v.normal;
                return o;
            }

            half4 frag(vertexOutput i) : COLOR
            {
                half3 c = tex2D(_MainTex, i.UvMain).rgb;
                half alphaTex = tex2D(_MainTex, i.UvMain + half2(_alphaUVShift, 0)).r;
                return half4(c.rgb, alphaTex.r) * CustomLighting(i.normal);
            }
			ENDCG
		}
	}	
}

