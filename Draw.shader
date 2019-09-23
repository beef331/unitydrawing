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
            float4 _LastLastPos;
            float4 _Color;
            float _Decay;

            static const float STEPS = 100;


            float2 Bezier(float2 p0, float2 p1, float2 p2, float t){

                return (1-t) * (1-t)  * p0 + 2*t *(1-t)*p1 + t*t*p2;

            }



            fixed4 frag (v2f i) : SV_Target
            {
                float2 inputDir = normalize((_LastPos-_LastLastPos));
                float2 outputDir = normalize(_MousePos - _LastPos);
                float2 perpDir = float2(outputDir.y,-outputDir.x);
                float dist = distance(_LastPos,_MousePos);
                float2 anchor = dot(inputDir,perpDir) * perpDir * dist/2 + (_LastPos + outputDir * dist/2);
                fixed4 pix = tex2D(_MainTex,i.uv);
                for(int j=0; j < STEPS;j++){
                    float2 curvePos = Bezier(_LastPos,anchor,_MousePos,j/STEPS); 
                    float2 delta = abs(curvePos.xy - i.uv);
                    delta.x *= (_ScreenParams.x/_ScreenParams.y);
                    if(length(delta) <= lerp(_LastPos.z,_MousePos.z,j/STEPS) * _MainTex_TexelSize.x){
                        return float4(lerp(pix.rgb,_Color.rgb,_Color.a),1);
                    }
                }
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
