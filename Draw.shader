Shader "Hidden/Draw"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always
        CGINCLUDE
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

        ENDCG
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_TexelSize;
            float4 _MousePos;
            float4 _LastPos;
            float4 _Color;
            float _Decay;
            fixed4 frag (v2f i) : SV_Target
            {
                for(int j=0; j < 100;j++){
                    float2 mousePos = lerp(_LastPos.xy,_MousePos.xy,j/100.0);
                    float2 delta = abs(mousePos.xy - i.uv);
                    delta.x *= (_ScreenParams.x/_ScreenParams.y);
                    if(length(delta) <= lerp(_LastPos.z,_MousePos.z,j/100.0) * _MainTex_TexelSize.x){
                        fixed4 col = _Color;
                        _Color.a = 1;
                        return _Color;
                    }
                }
                fixed4 pix = tex2D(_MainTex,i.uv);
                return saturate(pix + (unity_DeltaTime.x * _Decay));
            }
            ENDCG
        }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            fixed4 frag (v2f i) : SV_Target
            {
                return 1;
            }
            
            ENDCG
        }
    }
}
