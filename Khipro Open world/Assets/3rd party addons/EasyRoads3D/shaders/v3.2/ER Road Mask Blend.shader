Shader "EasyRoads3D/ER Road Mask Blend"
{
	Properties
	{
		_Maintex("Albedo", 2D) = "white" {}
		_Color0("Color 0", Color) = (1,1,1,1)
		_MetallicGlossMap("Metallic (R) AO (G) Smoothness (A)", 2D) = "white" {}
		_BumpMap("Normal Map", 2D) = "bump" {}
		_Albedo("Albedo", 2D) = "white" {}
		_Color("Color", Color) = (1,1,1,1)
		_MetallicGlossMap2("Metallic (R) AO (G) Smoothness (A)", 2D) = "white" {}
		_BumpMap2("Normal Map", 2D) = "bump" {}
		_Mask("Mask", 2D) = "white" {}

		[Header(Terrain Z Fighting Offset)]
		[Space]
		_OffsetFactor ("Offset Factor", Range(0.0,-10.0)) = -1
        _OffsetUnit ("Offset Unit", Range(0.0,-10.0)) = -1
		[Space]

		[HideInInspector] _texcoord4( "", 2D ) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+2450" "IgnoreProjector" = "True" }
		Offset [_OffsetFactor],[_OffsetUnit]
		LOD 200
		Cull Back
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float2 uv_texcoord;
			float2 uv4_texcoord4;
		};

		uniform sampler2D _BumpMap;
		uniform float4 _BumpMap_ST;
		uniform sampler2D _BumpMap2;
		uniform float4 _BumpMap2_ST;
		uniform sampler2D _Mask;
		uniform sampler2D _Maintex;
		uniform float4 _Maintex_ST;
		uniform float4 _Color0;
		uniform sampler2D _Albedo;
		uniform float4 _Albedo_ST;
		uniform float4 _Color;
		uniform sampler2D _MetallicGlossMap;
		uniform float4 _MetallicGlossMap_ST;
		uniform sampler2D _MetallicGlossMap2;
		uniform float4 _MetallicGlossMap2_ST;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_BumpMap = i.uv_texcoord * _BumpMap_ST.xy + _BumpMap_ST.zw;
			float2 uv_BumpMap2 = i.uv_texcoord * _BumpMap2_ST.xy + _BumpMap2_ST.zw;
			float4 tex2DNode30 = tex2D( _Mask, i.uv4_texcoord4 );
			float3 lerpResult24 = lerp( UnpackNormal( tex2D( _BumpMap, uv_BumpMap ) ) , UnpackNormal( tex2D( _BumpMap2, uv_BumpMap2 ) ) , tex2DNode30.g);
			o.Normal = lerpResult24;
			float2 uv_Maintex = i.uv_texcoord * _Maintex_ST.xy + _Maintex_ST.zw;
			float4 tex2DNode1 = tex2D( _Maintex, uv_Maintex );
			float2 uv_Albedo = i.uv_texcoord * _Albedo_ST.xy + _Albedo_ST.zw;
			float4 lerpResult16 = lerp( ( tex2DNode1 * _Color0 ) , ( tex2D( _Albedo, uv_Albedo ) * _Color ) , tex2DNode30.g);
			o.Albedo = lerpResult16.rgb;
			float2 uv_MetallicGlossMap = i.uv_texcoord * _MetallicGlossMap_ST.xy + _MetallicGlossMap_ST.zw;
			float4 tex2DNode2 = tex2D( _MetallicGlossMap, uv_MetallicGlossMap );
			float2 uv_MetallicGlossMap2 = i.uv_texcoord * _MetallicGlossMap2_ST.xy + _MetallicGlossMap2_ST.zw;
			float4 tex2DNode25 = tex2D( _MetallicGlossMap2, uv_MetallicGlossMap2 );
			float lerpResult26 = lerp( tex2DNode2.r , tex2DNode25.r , tex2DNode30.g);
			o.Metallic = lerpResult26;
			float lerpResult27 = lerp( tex2DNode2.a , tex2DNode25.a , tex2DNode30.g);
			o.Smoothness = lerpResult27;
			float lerpResult29 = lerp( tex2DNode2.g , tex2DNode25.g , tex2DNode30.g);
			o.Occlusion = lerpResult29;
			o.Alpha = ( tex2DNode1.a * _Color0.a );
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard keepalpha fullforwardshadows 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			Offset [_OffsetFactor],[_OffsetUnit]
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
