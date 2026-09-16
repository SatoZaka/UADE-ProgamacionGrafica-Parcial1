// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "ToonShading"
{
	Properties
	{
		_Step1Weight("Step 1 Weight", Float) = 1
		_Step1("Step 1", Range( 0 , 1)) = 0.9
		_Step2("Step 2", Range( 0 , 1)) = 0.7
		_Step3("Step 3", Range( 0 , 1)) = 0.5
		_Step2Weight("Step 2 Weight", Float) = 1
		_Step3Weight("Step 3 Weight", Float) = 1
		_Texture("Texture", 2D) = "white" {}
		_MinLight("Min Light", Range( 0 , 1)) = 0.2
		_MaxLight("Max Light", Range( 0 , 1)) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityCG.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float2 uv_texcoord;
			float3 worldNormal;
			float3 worldPos;
		};

		struct SurfaceOutputCustomLightingCustom
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			half Alpha;
			Input SurfInput;
			UnityGIInput GIData;
		};

		uniform sampler2D _Texture;
		uniform float4 _Texture_ST;
		uniform float _Step1;
		uniform float _Step1Weight;
		uniform float _Step2;
		uniform float _Step2Weight;
		uniform float _Step3;
		uniform float _Step3Weight;
		uniform float _MinLight;
		uniform float _MaxLight;

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			float2 uv_Texture = i.uv_texcoord * _Texture_ST.xy + _Texture_ST.zw;
			float3 ase_worldNormal = i.worldNormal;
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult6 = dot( ase_worldNormal , ase_worldlightDir );
			float temp_output_17_0 = (0.0 + (dotResult6 - -1.0) * (1.0 - 0.0) / (1.0 - -1.0));
			float Weight113 = _Step1Weight;
			float Weight214 = _Step2Weight;
			float Weight315 = _Step3Weight;
			float SumaWeights29 = ( _Step1Weight + _Step2Weight + _Step3Weight );
			float clampResult45 = clamp( ( ( ( step( _Step1 , temp_output_17_0 ) * Weight113 ) + ( step( _Step2 , temp_output_17_0 ) * Weight214 ) + ( step( _Step3 , temp_output_17_0 ) * Weight315 ) ) / SumaWeights29 ) , _MinLight , _MaxLight );
			c.rgb = ( tex2D( _Texture, uv_Texture ) * clampResult45 ).rgb;
			c.a = 1;
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows 

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
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				float3 worldNormal : TEXCOORD3;
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
				o.worldNormal = worldNormal;
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
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
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = IN.worldNormal;
				SurfaceOutputCustomLightingCustom o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputCustomLightingCustom, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18900
368;73;1096;535;1932.817;-1010.352;1;True;False
Node;AmplifyShaderEditor.WorldNormalVector;7;-3373.666,25.07901;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;8;-3380.165,173.2799;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;12;-1501.289,1429.914;Inherit;False;Property;_Step3Weight;Step 3 Weight;5;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;11;-1547.557,1234.367;Inherit;False;Property;_Step2Weight;Step 2 Weight;4;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;3;-1526.441,1150.497;Inherit;False;Property;_Step1Weight;Step 1 Weight;0;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;6;-3113.666,111.2506;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-2332.425,-117.7762;Inherit;False;Property;_Step1;Step 1;1;0;Create;True;0;0;0;False;0;False;0.9;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;26;-2382.979,462.311;Inherit;False;Property;_Step3;Step 3;3;0;Create;True;0;0;0;False;0;False;0.5;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;17;-2868.183,140.7234;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;-1;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;22;-2391.749,123.0358;Inherit;False;Property;_Step2;Step 2;2;0;Create;True;0;0;0;False;0;False;0.7;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;13;-1310.83,1124.619;Inherit;False;Weight1;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;15;-1242.491,1434.815;Inherit;False;Weight3;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;14;-1380.678,1297.819;Inherit;False;Weight2;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;10;-1064.77,1187.758;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;4;-2030.424,-89.77625;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;23;-1671.81,273.8932;Inherit;False;14;Weight2;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;25;-2048.833,400.3005;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;21;-2044.011,159.2025;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;27;-1676.631,514.9918;Inherit;False;15;Weight3;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;18;-1658.222,24.91449;Inherit;False;13;Weight1;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;20;-1467.777,214.4059;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;24;-1472.599,454.5045;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;2;-1454.191,-35.57272;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;29;-871.0062,1230.734;Inherit;False;SumaWeights;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;39;-1181.321,424.0994;Inherit;False;29;SumaWeights;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1;-1197.867,206.4678;Inherit;True;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;47;-722.2908,493.5017;Inherit;False;Property;_MaxLight;Max Light;8;0;Create;True;0;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;38;-918.6313,305.8173;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;46;-723.5908,403.8016;Inherit;False;Property;_MinLight;Min Light;7;0;Create;True;0;0;0;False;0;False;0.2;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;41;-1633.215,-368.7151;Inherit;True;Property;_Texture;Texture;6;0;Create;True;0;0;0;False;0;False;None;c9fd4ccfc3404b04eae3cd87e40a8e2e;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SamplerNode;40;-1305.428,-360.5205;Inherit;True;Property;_TextureSample;Texture Sample;6;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;45;-407.692,357.0018;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;42;-171.2637,240.3902;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;0,0;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;ToonShading;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;6;0;7;0
WireConnection;6;1;8;0
WireConnection;17;0;6;0
WireConnection;13;0;3;0
WireConnection;15;0;12;0
WireConnection;14;0;11;0
WireConnection;10;0;3;0
WireConnection;10;1;11;0
WireConnection;10;2;12;0
WireConnection;4;0;5;0
WireConnection;4;1;17;0
WireConnection;25;0;26;0
WireConnection;25;1;17;0
WireConnection;21;0;22;0
WireConnection;21;1;17;0
WireConnection;20;0;21;0
WireConnection;20;1;23;0
WireConnection;24;0;25;0
WireConnection;24;1;27;0
WireConnection;2;0;4;0
WireConnection;2;1;18;0
WireConnection;29;0;10;0
WireConnection;1;0;2;0
WireConnection;1;1;20;0
WireConnection;1;2;24;0
WireConnection;38;0;1;0
WireConnection;38;1;39;0
WireConnection;40;0;41;0
WireConnection;45;0;38;0
WireConnection;45;1;46;0
WireConnection;45;2;47;0
WireConnection;42;0;40;0
WireConnection;42;1;45;0
WireConnection;0;13;42;0
ASEEND*/
//CHKSM=F5DB4707B5E11F4ED3E724D61592DCDA8FEED9CD