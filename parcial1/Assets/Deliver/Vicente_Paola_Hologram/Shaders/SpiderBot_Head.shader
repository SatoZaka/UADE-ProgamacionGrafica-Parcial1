// Upgrade NOTE: upgraded instancing buffer 'SpiderBot_Head' to new syntax.

// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "SpiderBot_Head"
{
	Properties
	{
		_headColor("headColor", Color) = (0.3366411,0.6782446,0.8018868,0)
		_fresnelPower("fresnelPower", Range( 0 , 10)) = 3
		_glowStrength("glowStrength", Range( 0 , 10)) = 0.5
		_opacity("opacity", Range( 0 , 1)) = 0.35
		_albedoStrength("albedoStrength", Range( 0 , 1)) = 0.25
		_lineDensity("lineDensity", Range( 0 , 100)) = 30
		_lineSpeed("lineSpeed", Range( 0 , 100)) = 10
		_lineGlow("lineGlow", Range( 0 , 1)) = 0.3
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#pragma multi_compile_instancing
		struct Input
		{
			float3 worldPos;
			float3 worldNormal;
			float2 uv_texcoord;
		};

		uniform float _albedoStrength;
		uniform float4 _headColor;
		uniform float _fresnelPower;
		uniform float _lineDensity;
		uniform float _lineSpeed;
		uniform float _lineGlow;
		uniform float _opacity;

		UNITY_INSTANCING_BUFFER_START(SpiderBot_Head)
			UNITY_DEFINE_INSTANCED_PROP(float, _glowStrength)
#define _glowStrength_arr SpiderBot_Head
		UNITY_INSTANCING_BUFFER_END(SpiderBot_Head)

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float4 headColor26 = _headColor;
			o.Albedo = ( _albedoStrength * headColor26 ).rgb;
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = i.worldNormal;
			float fresnelNdotV1 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode1 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV1, _fresnelPower ) );
			float _glowStrength_Instance = UNITY_ACCESS_INSTANCED_PROP(_glowStrength_arr, _glowStrength);
			float smoothstepResult22 = smoothstep( 0.9 , 0.95 , ( 1.0 - abs( sin( ( ( i.uv_texcoord.y * _lineDensity ) + ( _Time.y * _lineSpeed ) ) ) ) ));
			o.Emission = ( ( headColor26 * ( fresnelNode1 * _glowStrength_Instance ) ) + ( ( smoothstepResult22 * _lineGlow ) * headColor26 ) ).rgb;
			o.Alpha = ( fresnelNode1 * _opacity );
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
Version=18900
368;73;1096;535;1433.225;-517.8022;1;False;False
Node;AmplifyShaderEditor.TextureCoordinatesNode;11;-1216.682,584.2358;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BreakToComponentsNode;12;-915.2447,598.6855;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RangedFloatNode;17;-1094.683,927.5314;Inherit;False;Property;_lineSpeed;lineSpeed;6;0;Create;True;0;0;0;False;0;False;10;50;0;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;13;-1004.141,844.1712;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;18;-1033.287,739.8417;Inherit;False;Property;_lineDensity;lineDensity;5;0;Create;True;0;0;0;False;0;False;30;80;0;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;19;-720.5079,818.442;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;14;-753.3231,606.6589;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;15;-570.4566,620.2307;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;16;-410.0839,640.8309;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;20;-235.4504,639.7759;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;2;-1801.001,-443.781;Inherit;False;Property;_headColor;headColor;0;0;Create;True;0;0;0;False;0;False;0.3366411,0.6782446,0.8018868,0;0.05540227,0.7830189,0.5011495,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;23;-262.8383,818.3259;Inherit;False;Property;_lineGlow;lineGlow;7;0;Create;True;0;0;0;False;0;False;0.3;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;21;-107.5331,636.1893;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;26;-1564.148,-431.722;Inherit;False;headColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;25;152.6925,827.4587;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;3;-1305.856,133.6741;Inherit;False;Property;_fresnelPower;fresnelPower;1;0;Create;True;0;0;0;False;0;False;3;1.96;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;22;72.98565,643.1667;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.9;False;2;FLOAT;0.95;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;24;245.1345,692.0536;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;28;171.7363,882.6838;Inherit;True;26;headColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;4;-1037.262,239.5936;Inherit;False;InstancedProperty;_glowStrength;glowStrength;2;0;Create;True;0;0;0;False;0;False;0.5;0.9;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;1;-961.0283,7.028177;Inherit;False;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;29;445.199,668.2415;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;6;-621.1851,17.77873;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;27;-803.7391,-257.751;Inherit;True;26;headColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;31;471.0374,382.3931;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-642.3336,417.76;Inherit;False;Property;_opacity;opacity;3;0;Create;True;0;0;0;False;0;False;0.35;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;7;-384.3292,28.71061;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;10;-726.517,-357.0748;Inherit;False;Property;_albedoStrength;albedoStrength;4;0;Create;True;0;0;0;False;0;False;0.25;0.25;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;30;462.0974,137.6474;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;8;-347.8899,289.2526;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;9;-375.2195,-209.9678;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;641.6619,40.81242;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;SpiderBot_Head;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;True;0;False;Transparent;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;12;0;11;0
WireConnection;19;0;13;0
WireConnection;19;1;17;0
WireConnection;14;0;12;1
WireConnection;14;1;18;0
WireConnection;15;0;14;0
WireConnection;15;1;19;0
WireConnection;16;0;15;0
WireConnection;20;0;16;0
WireConnection;21;0;20;0
WireConnection;26;0;2;0
WireConnection;25;0;23;0
WireConnection;22;0;21;0
WireConnection;24;0;22;0
WireConnection;24;1;25;0
WireConnection;1;3;3;0
WireConnection;29;0;24;0
WireConnection;29;1;28;0
WireConnection;6;0;1;0
WireConnection;6;1;4;0
WireConnection;31;0;29;0
WireConnection;7;0;27;0
WireConnection;7;1;6;0
WireConnection;30;0;7;0
WireConnection;30;1;31;0
WireConnection;8;0;1;0
WireConnection;8;1;5;0
WireConnection;9;0;10;0
WireConnection;9;1;27;0
WireConnection;0;0;9;0
WireConnection;0;2;30;0
WireConnection;0;9;8;0
ASEEND*/
//CHKSM=22783C99BDF47C4F40EC45BDA647D4F7D69A05A0