﻿Shader "NoteCAD/DraftLines" {

	Properties {
		_MainTex ("Texture", 2D) = "white" {}
		_Width("Width", Float) = 1.0
		_StippleWidth("StippleWidth", Float) = 1.0
		[HideInInspector]
		_PatternLength("PatternLength", Float) = 1.0
		[HideInInspector]
		_Pixel("Pixel", Float) = 1.0
		[HideInInspector]
		_CamDir("CamDir", Vector) = (1,1,1,0)
		_CamRight("CamRight", Vector) = (1,0,1,0)
		_Color("Color", Color) = (1,1,1,1)
	}
	
	SubShader {
		Tags { "RenderType" = "Transparent" }
		LOD 100
		//AlphaToMask On
		//ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha

		Pass {
			Offset -1, -1
			Cull Off
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			
			#include "UnityCG.cginc"

			struct appdata {
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float4 tangent: NORMAL;
				float4 params: TANGENT;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float3 cap: TEXCOORD1;

				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _Width;
			float _StippleWidth;
			float _PatternLength;
			float _Pixel;
			float4 _CamDir;
			float4 _CamRight;
			fixed4 _Color;

			v2f vert (appdata v) {
				const float feather = 0.7;
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				float4 projected = UnityObjectToClipPos(float4(v.vertex.xyz, 1.0));
				float4 projectedTang = UnityObjectToClipPos(float4(v.vertex.xyz + normalize(v.tangent.xyz), 1.0));
				float3 tang = projectedTang.xyz / projectedTang.w - projected.xyz / projected.w;
				if((projected.w >= 0) != (projectedTang.w >= 0)) tang = -tang;
				tang = tang / length(tang.xy);
				tang.x *= _ScreenParams.x / _ScreenParams.y;
				float scale = length(float3(unity_ObjectToWorld[0].x, unity_ObjectToWorld[1].x, unity_ObjectToWorld[2].x));
				float pixel = projected.w / _ScreenParams.y;
				float pix = pixel / 2.0;
				float3 dir = mul((float3x3)unity_WorldToObject, (float3)_CamDir);
				if (all(v.tangent.xyz == float3(0, 0, 0))) {
					tang = normalize(mul((float3x3)unity_WorldToObject, (float3)_CamRight));
				}
				float cap = _Width * pix + feather * pixel;
				float3 x = float3(0.0, 0.0, 0.0);//tang * cap / 2.0;
				float3 y = cross(tang, float3(0.0, 0.0, 1.0)) * cap;

				o.vertex = UnityObjectToClipPos(v.vertex) + float4(v.params.x * x + v.params.y * y, 0.0);
				float2 uv = v.uv;
				uv.x += v.params.x * cap;
				float len = length(v.tangent.xyz) * scale;
				if(v.params.x == -1.0) {
					o.cap = float3(-1.0, len / cap, pixel);
				} else {
					o.cap = float3(len / cap + 1.0, len / cap, pixel);
				}
				o.uv = TRANSFORM_TEX(uv, _MainTex);
				return o;
			}

			fixed4 frag (v2f i) : SV_Target {
				const float feather = 0.7;
				float patternScale = _PatternLength * _StippleWidth * _Pixel;
				fixed4 v = tex2D(_MainTex, float2(i.uv.x / patternScale, 0.0));
				float val = dot(v, float4(1.0, 1.0 / 255.0, 1.0 / 65025.0, 1.0 / 160581375.0));
				float pix = i.cap.z / 2.0;
				float pat = val * patternScale / (_Width * pix);
				float c = (_Width / 2.0 + feather) / (_Width / 2.0);
				float cap = (max(i.cap.x - i.cap.y, 0.0) - min(i.cap.x, 0.0)) * c;
				float dist = abs(i.uv.y * c);//length(float2(max(cap, pat), i.uv.y * c));

				float f = 2.0 * feather / (_Width / 2.0 + feather);
				float k = smoothstep(1.0 - f, 1.0+ f, dist);
				if (k == 1.0) discard;
				return float4(_Color.rgb, _Color.a * (1.0 - k));
			}
			ENDCG

		}
	}
}
