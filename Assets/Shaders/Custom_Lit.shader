Shader "Custom/Lit" 
{
	Properties 
	{
		_MainTex ("Base (RGB)", 2D) = "white" {}
		[Toggle(TogglePlanerUvs)] _PlanarUvs("PlanerUvs", Float) = 0
	}
	
	SubShader
	{
		Tags
		{
            "RenderType"="Opaque"
            "IgnoreProjector"="True"
            "Queue" = "Geometry"
		}
		
		ZWrite On
		
		Pass
        {
            Tags { "LightMode" = "ForwardBase" }
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"
            #include "Custom.cginc"
            
            #pragma multi_compile __ TogglePlanerUvs
    
            sampler2D _MainTex;
    
            v2f_common vert (appdata_common v)
            {
                v2f_common o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.normal = v.normal;
    
                #ifdef TogglePlanerUvs
                o.uv = mul(UNITY_MATRIX_M, v.vertex).xz * 0.3;
                #else
                o.uv = fixed2(v.texcoord.xy);
                #endif
    
                return o;
            }
            
            fixed4 frag(v2f_common i) : COLOR
            {
                return tex2D(_MainTex, i.uv) * CustomLighting(i.normal);
            }
            ENDCG
        }
	} 
}
