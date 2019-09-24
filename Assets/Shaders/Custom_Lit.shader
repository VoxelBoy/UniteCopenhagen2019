Shader "Custom/Lit" 
{
	Properties 
	{
		_MainTex ("Base (RGB)", 2D) = "white" {}
		[Toggle(TogglePlanarUvs)] _PlanarUvs("PlanarUvs", Float) = 0
	}
	
	SubShader
	{
		Tags
		{
            "RenderType"="Opaque"
            "Queue"="Geometry"
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
            
            #pragma multi_compile __ TogglePlanarUvs
    
            sampler2D _MainTex;
    
            v2f_common vert (appdata_common v)
            {
                v2f_common o;
                
                o.pos = UnityObjectToClipPos(v.vertex);
                o.normal = v.normal;
                
                #ifdef TogglePlanarUvs
                o.uv = mul(UNITY_MATRIX_M, v.vertex).xz * 0.3;
                #else
                o.uv = fixed2(v.texcoord.xy);
                #endif
    
                return o;
            }
            
            fixed4 frag(v2f_common i) : COLOR
            {
                half4 lighting = CustomLighting(i.normal);
			    half4 color = tex2D(_MainTex, i.uv);
				return color * lighting;
            }
            ENDCG
        }
	} 
}
