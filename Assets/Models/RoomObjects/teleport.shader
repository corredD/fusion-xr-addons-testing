// Upgrade NOTE: upgraded instancing buffer 'teleport' to new syntax.

// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "teleport"
{
	Properties
	{
		_Opacity("_Opacity", Range( 0 , 2)) = 0.5
		_RimColor("RimColor", Color) = (1,1,1,1)
		_Normal("Normal", 2D) = "bump" {}
		_Color("Color", Color) = (1,1,1,0)
		_Smoothness("_Smoothness", Range( 0 , 1)) = 0.3
		_Metalic("_Metalic", Range( 0 , 1)) = 0.1
		_RimPower("RimPower", Range( 0 , 10)) = 2
		_RimLightness("_RimLightness", Range( 0 , 1)) = 0.125
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Off
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#pragma multi_compile_instancing
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float2 uv_texcoord;
			float3 viewDir;
			INTERNAL_DATA
		};

		uniform sampler2D _Normal;
		uniform float4 _Color;
		uniform float _Opacity;

		UNITY_INSTANCING_BUFFER_START(teleport)
			UNITY_DEFINE_INSTANCED_PROP(float4, _Normal_ST)
#define _Normal_ST_arr teleport
			UNITY_DEFINE_INSTANCED_PROP(float4, _RimColor)
#define _RimColor_arr teleport
			UNITY_DEFINE_INSTANCED_PROP(float, _RimPower)
#define _RimPower_arr teleport
			UNITY_DEFINE_INSTANCED_PROP(float, _RimLightness)
#define _RimLightness_arr teleport
			UNITY_DEFINE_INSTANCED_PROP(float, _Metalic)
#define _Metalic_arr teleport
			UNITY_DEFINE_INSTANCED_PROP(float, _Smoothness)
#define _Smoothness_arr teleport
		UNITY_INSTANCING_BUFFER_END(teleport)

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float4 _Normal_ST_Instance = UNITY_ACCESS_INSTANCED_PROP(_Normal_ST_arr, _Normal_ST);
			float2 uv_Normal = i.uv_texcoord * _Normal_ST_Instance.xy + _Normal_ST_Instance.zw;
			float3 tex2DNode28 = UnpackNormal( tex2D( _Normal, uv_Normal ) );
			o.Normal = tex2DNode28;
			float4 temp_output_20_0 = _Color;
			o.Albedo = temp_output_20_0.rgb;
			float3 normalizeResult10 = normalize( i.viewDir );
			float dotResult12 = dot( tex2DNode28 , normalizeResult10 );
			float _RimPower_Instance = UNITY_ACCESS_INSTANCED_PROP(_RimPower_arr, _RimPower);
			float4 _RimColor_Instance = UNITY_ACCESS_INSTANCED_PROP(_RimColor_arr, _RimColor);
			float4 blendOpSrc19 = _RimColor_Instance;
			float4 blendOpDest19 = _Color;
			float _RimLightness_Instance = UNITY_ACCESS_INSTANCED_PROP(_RimLightness_arr, _RimLightness);
			float4 lerpBlendMode19 = lerp(blendOpDest19, (( blendOpSrc19 > 0.5 ) ? ( 1.0 - ( 1.0 - 2.0 * ( blendOpSrc19 - 0.5 ) ) * ( 1.0 - blendOpDest19 ) ) : ( 2.0 * blendOpSrc19 * blendOpDest19 ) ),_RimLightness_Instance);
			o.Emission = ( pow( ( 1.0 - saturate( dotResult12 ) ) , _RimPower_Instance ) * ( saturate( lerpBlendMode19 )) ).rgb;
			float _Metalic_Instance = UNITY_ACCESS_INSTANCED_PROP(_Metalic_arr, _Metalic);
			o.Metallic = _Metalic_Instance;
			float _Smoothness_Instance = UNITY_ACCESS_INSTANCED_PROP(_Smoothness_arr, _Smoothness);
			o.Smoothness = _Smoothness_Instance;
			o.Alpha = ( _Opacity - i.uv_texcoord.y );
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard alpha:fade keepalpha fullforwardshadows 

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
				float2 customPack1 : TEXCOORD1;
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
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
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.viewDir = IN.tSpace0.xyz * worldViewDir.x + IN.tSpace1.xyz * worldViewDir.y + IN.tSpace2.xyz * worldViewDir.z;
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
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
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18930
622;73;2105;910;2111.95;631.058;1.809475;True;True
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;9;-1463.561,-1.805092;Float;False;Tangent;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SamplerNode;28;-1370.065,-403.0642;Inherit;True;Property;_Normal;Normal;2;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NormalizeNode;10;-1240.863,-4.904884;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;12;-1049.164,-83.30537;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;13;-873.9646,-107.8055;Inherit;False;1;0;FLOAT;1.23;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;16;-801.5632,49.89441;Float;False;InstancedProperty;_RimPower;RimPower;5;0;Create;True;0;0;0;False;0;False;2;0;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;17;-704.9619,-65.50618;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;14;-888.4395,561.1769;Inherit;False;InstancedProperty;_RimLightness;_RimLightness;7;0;Create;True;0;0;0;False;0;False;0.125;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;20;-729.0239,-482.4871;Inherit;False;Property;_Color;Color;2;0;Create;True;0;0;0;False;0;False;1,1,1,0;0,1,0.1144985,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;15;-868.1965,371.9027;Float;False;InstancedProperty;_RimColor;RimColor;1;0;Create;True;0;0;0;False;0;False;1,1,1,1;1,1,1,1;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;1;-121.3345,206.0168;Inherit;False;Property;_Opacity;_Opacity;0;0;Create;True;0;0;0;False;0;False;0.5;0.624;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.BlendOpsNode;19;-436.3262,363.6248;Inherit;True;HardLight;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0.5;False;1;COLOR;0
Node;AmplifyShaderEditor.PowerNode;18;-499.5807,18.71516;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;23;-123.6273,316.0452;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;27;215.998,187.8808;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;7;-106.3846,118.9396;Inherit;False;InstancedProperty;_Smoothness;_Smoothness;3;0;Create;True;0;0;0;False;0;False;0.3;0.563;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;8;-107.6154,48.06036;Inherit;False;InstancedProperty;_Metalic;_Metalic;4;0;Create;True;0;0;0;False;0;False;0.1;0.419;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;21;-273.4984,-52.43726;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;368,-27;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;teleport;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;True;0;False;Transparent;;Transparent;All;18;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;10;0;9;0
WireConnection;12;0;28;0
WireConnection;12;1;10;0
WireConnection;13;0;12;0
WireConnection;17;0;13;0
WireConnection;19;0;15;0
WireConnection;19;1;20;0
WireConnection;19;2;14;0
WireConnection;18;0;17;0
WireConnection;18;1;16;0
WireConnection;27;0;1;0
WireConnection;27;1;23;2
WireConnection;21;0;18;0
WireConnection;21;1;19;0
WireConnection;0;0;20;0
WireConnection;0;1;28;0
WireConnection;0;2;21;0
WireConnection;0;3;8;0
WireConnection;0;4;7;0
WireConnection;0;9;27;0
ASEEND*/
//CHKSM=2D9D47C0EF00FFCE4A10CE8D03847F4E280786E4