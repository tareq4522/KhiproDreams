Shader "EasyRoads3D/ER Tunnel"
{
	Properties
	{
		_Maintex("Main Albedo", 2D) = "white" {}
		_Color("Main Color", Color) = (1,1,1,1)
		_MetallicGlossMap1("Main Metallic (R) AO (G) Smoothness (A)", 2D) = "white" {}
		_MainMetallicPower("Main Metallic Power", Range( 0 , 2)) = 1
		_MainSmoothnessPower("Main Smoothness Power", Range( 0 , 2)) = 1
		_OcclusionStrength("Main Ambient Occlusion Power", Range( 0 , 2)) = 1
		_BumpMap("Main Normals", 2D) = "bump" {}
		_BumpScale("Main Normal Map Scale", Range( 0 , 4)) = 1
		_Detail("Detail", 2D) = "white" {}
		_Color1("Detail Color", Color) = (1,1,1,1)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] _texcoord4( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "AlphaTest+2450" "IgnoreProjector" = "True" }
		LOD 200
		Cull Off
		Offset  [_OffsetFactor] , [_OffsetUnit]
		Blend SrcAlpha OneMinusSrcAlpha
		
		CGINCLUDE
		#include "UnityStandardUtils.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float2 uv_texcoord;
			float2 uv4_texcoord4;
		};

		uniform half _BumpScale;
		uniform sampler2D _BumpMap;
		uniform sampler2D _Maintex;
		uniform float4 _Maintex_ST;
		uniform float4 _Color;
		uniform sampler2D _Detail;
		uniform float4 _Color1;
		uniform sampler2D _MetallicGlossMap1;
		uniform float4 _MetallicGlossMap1_ST;
		uniform half _MainMetallicPower;
		uniform half _MainSmoothnessPower;
		uniform half _OcclusionStrength;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			o.Normal = UnpackScaleNormal( tex2D( _BumpMap, i.uv_texcoord ), _BumpScale );
			float2 uv_Maintex = i.uv_texcoord * _Maintex_ST.xy + _Maintex_ST.zw;
			float4 tex2DNode1 = tex2D( _Maintex, uv_Maintex );
			o.Albedo = ( ( ( tex2DNode1 * _Color ) * ( tex2D( _Detail, i.uv4_texcoord4 ) * _Color1 ) ) * float4(2,2,2,2) ).rgb;
			float2 uv_MetallicGlossMap1 = i.uv_texcoord * _MetallicGlossMap1_ST.xy + _MetallicGlossMap1_ST.zw;
			float4 tex2DNode23 = tex2D( _MetallicGlossMap1, uv_MetallicGlossMap1 );
			o.Metallic = ( tex2DNode23.r * _MainMetallicPower );
			o.Smoothness = ( tex2DNode23.a * _MainSmoothnessPower );
			o.Occlusion = ( tex2DNode23.g * _OcclusionStrength );
			o.Alpha = tex2DNode1.a;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard keepalpha fullforwardshadows 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			sampler3D _DitherMaskLOD;
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float4 customPack1 : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				float4 tSpace0 : TEXCOORD3;
				float4 tSpace1 : TEXCOORD4;
				float4 tSpace2 : TEXCOORD5;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				o.customPack1.zw = customInputData.uv4_texcoord4;
				o.customPack1.zw = v.texcoord3;
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				surfIN.uv4_texcoord4 = IN.customPack1.zw;
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				half alphaRef = tex3D( _DitherMaskLOD, float3( vpos.xy * 0.25, o.Alpha * 0.9375 ) ).a;
				clip( alphaRef - 0.01 );
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
}