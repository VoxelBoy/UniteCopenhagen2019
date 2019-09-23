Shader "Custom/Lit" 
{
	Properties 
	{
		_MainTex ("Base (RGB)", 2D) = "white" {}
		[Toggle(TogglePlanerUvs)] _PlanerUvs("PlanerUvs", Float) = 0
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
            #include "CustomLighting.cginc"
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
