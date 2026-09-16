// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Road"
{
	Properties
	{
		_noiseScale("noiseScale", Range( 0 , 50)) = 3
		_colordark("color dark", Color) = (0.3301887,0.2521683,0.2227216,0)
		_colorlight("color light", Color) = (0.5471698,0.452597,0.4155393,0)
		_normalStrength("normalStrength", Range( 0 , 50)) = 0
		_brickTiling("brickTiling", Vector) = (0,0,0,0)
		_rockScale("rockScale", Range( 0 , 50)) = 0
		_rockColor("rockColor", Color) = (0,0,0,0)
		_brickHeight("brickHeight", Range( 0 , 5)) = 0
		_rockHeigth("rockHeigth", Range( 0 , 20)) = 0
		_rockNoiseScale("rockNoiseScale", Range( 0 , 50)) = 0
		_rockIrregularity("rockIrregularity", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
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
			float3 worldPos;
			float3 worldNormal;
			INTERNAL_DATA
			float2 uv_texcoord;
		};

		uniform float2 _brickTiling;
		uniform float _brickHeight;
		uniform float _rockScale;
		uniform float _rockNoiseScale;
		uniform float _rockIrregularity;
		uniform float _rockHeigth;
		uniform float _normalStrength;
		uniform float4 _colordark;
		uniform float4 _colorlight;
		uniform float _noiseScale;
		uniform float4 _rockColor;


		float2 voronoihash23( float2 p )
		{
			
			p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
			return frac( sin( p ) *43758.5453);
		}


		float voronoi23( float2 v, float time, inout float2 id, inout float2 mr, float smoothness )
		{
			float2 n = floor( v );
			float2 f = frac( v );
			float F1 = 8.0;
			float F2 = 8.0; float2 mg = 0;
			for ( int j = -1; j <= 1; j++ )
			{
				for ( int i = -1; i <= 1; i++ )
			 	{
			 		float2 g = float2( i, j );
			 		float2 o = voronoihash23( n + g );
					o = ( sin( time + o * 6.2831 ) * 0.5 + 0.5 ); float2 r = f - g - o;
					float d = 0.5 * dot( r, r );
			 		if( d<F1 ) {
			 			F2 = F1;
			 			F1 = d; mg = g; mr = r; id = o;
			 		} else if( d<F2 ) {
			 			F2 = d;
			 		}
			 	}
			}
			return F1;
		}


		float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }

		float snoise( float2 v )
		{
			const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
			float2 i = floor( v + dot( v, C.yy ) );
			float2 x0 = v - i + dot( i, C.xx );
			float2 i1;
			i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
			float4 x12 = x0.xyxy + C.xxzz;
			x12.xy -= i1;
			i = mod2D289( i );
			float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
			float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
			m = m * m;
			m = m * m;
			float3 x = 2.0 * frac( p * C.www ) - 1.0;
			float3 h = abs( x ) - 0.5;
			float3 ox = floor( x + 0.5 );
			float3 a0 = x - ox;
			m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
			float3 g;
			g.x = a0.x * x0.x + h.x * x0.y;
			g.yz = a0.yz * x12.xz + h.yz * x12.yw;
			return 130.0 * dot( m, g );
		}


		float3 PerturbNormal107_g1( float3 surf_pos, float3 surf_norm, float height, float scale )
		{
			// "Bump Mapping Unparametrized Surfaces on the GPU" by Morten S. Mikkelsen
			float3 vSigmaS = ddx( surf_pos );
			float3 vSigmaT = ddy( surf_pos );
			float3 vN = surf_norm;
			float3 vR1 = cross( vSigmaT , vN );
			float3 vR2 = cross( vN , vSigmaS );
			float fDet = dot( vSigmaS , vR1 );
			float dBs = ddx( height );
			float dBt = ddy( height );
			float3 vSurfGrad = scale * 0.05 * sign( fDet ) * ( dBs * vR1 + dBt * vR2 );
			return normalize ( abs( fDet ) * vN - vSurfGrad );
		}


		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float3 ase_worldPos = i.worldPos;
			float3 surf_pos107_g1 = ase_worldPos;
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 surf_norm107_g1 = ase_worldNormal;
			float2 temp_output_15_0_g2 = _brickTiling;
			float2 break26_g2 = ( i.uv_texcoord * temp_output_15_0_g2 );
			float2 appendResult27_g2 = (float2(( ( 0.5 * step( 1.0 , ( break26_g2.y % 2.0 ) ) ) + break26_g2.x ) , break26_g2.y));
			float2 break12_g2 = temp_output_15_0_g2;
			float temp_output_21_0_g2 = sign( ( break12_g2.y - break12_g2.x ) );
			float temp_output_14_0_g2 = 0.65;
			float2 appendResult10_g3 = (float2(( ( ( 1.0 / break12_g2.y ) * max( temp_output_21_0_g2 , 0.0 ) ) + temp_output_14_0_g2 ) , ( temp_output_14_0_g2 + ( ( -1.0 / break12_g2.x ) * min( temp_output_21_0_g2 , 0.0 ) ) )));
			float2 temp_output_11_0_g3 = ( abs( (frac( appendResult27_g2 )*2.0 + -1.0) ) - appendResult10_g3 );
			float2 break16_g3 = ( 1.0 - ( temp_output_11_0_g3 / fwidth( temp_output_11_0_g3 ) ) );
			float temp_output_2_0_g2 = saturate( min( break16_g3.x , break16_g3.y ) );
			float temp_output_17_0 = temp_output_2_0_g2;
			float time23 = 0.0;
			float2 coords23 = i.uv_texcoord * _rockScale;
			float2 id23 = 0;
			float2 uv23 = 0;
			float voroi23 = voronoi23( coords23, time23, id23, uv23, 0 );
			float simplePerlin2D36 = snoise( i.uv_texcoord*_rockNoiseScale );
			simplePerlin2D36 = simplePerlin2D36*0.5 + 0.5;
			float smoothstepResult28 = smoothstep( 0.88 , 0.94 , ( ( 1.0 - voroi23 ) + ( ( simplePerlin2D36 - 0.5 ) * _rockIrregularity ) ));
			float height107_g1 = ( ( temp_output_17_0 * _brickHeight ) + ( smoothstepResult28 * _rockHeigth ) );
			float scale107_g1 = _normalStrength;
			float3 localPerturbNormal107_g1 = PerturbNormal107_g1( surf_pos107_g1 , surf_norm107_g1 , height107_g1 , scale107_g1 );
			float3 ase_worldTangent = WorldNormalVector( i, float3( 1, 0, 0 ) );
			float3 ase_worldBitangent = WorldNormalVector( i, float3( 0, 1, 0 ) );
			float3x3 ase_worldToTangent = float3x3( ase_worldTangent, ase_worldBitangent, ase_worldNormal );
			float3 worldToTangentDir42_g1 = mul( ase_worldToTangent, localPerturbNormal107_g1);
			o.Normal = worldToTangentDir42_g1;
			float simplePerlin2D4 = snoise( i.uv_texcoord*_noiseScale );
			simplePerlin2D4 = simplePerlin2D4*0.5 + 0.5;
			float smoothstepResult9 = smoothstep( 0.35 , 0.65 , simplePerlin2D4);
			float4 lerpResult8 = lerp( _colordark , _colorlight , smoothstepResult9);
			float4 color19 = IsGammaSpace() ? float4(0.4245283,0.3682999,0.3424261,0) : float4(0.1507122,0.1117248,0.09603057,0);
			float4 lerpResult20 = lerp( lerpResult8 , color19 , temp_output_17_0);
			float4 lerpResult21 = lerp( lerpResult8 , lerpResult20 , smoothstepResult9);
			float4 lerpResult30 = lerp( lerpResult21 , _rockColor , smoothstepResult28);
			o.Albedo = lerpResult30.rgb;
			o.Alpha = 1;
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
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
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
363;73;1101;535;2161.934;461.0422;3.94827;False;False
Node;AmplifyShaderEditor.CommentaryNode;45;-1526.478,885.9072;Inherit;False;1851.74;659.8917;RocasIrregulares;13;37;38;26;36;23;42;40;39;27;41;28;33;32;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;1;-2218.34,-178.0285;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;38;-1476.268,1361.799;Inherit;False;Property;_rockNoiseScale;rockNoiseScale;9;0;Create;True;0;0;0;False;0;False;0;35;0;50;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;37;-1476.478,989.628;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;36;-1172.465,1289.223;Inherit;False;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;43;-1295.006,-413.6227;Inherit;False;1112.208;643.6172;TierraBase;6;2;4;9;6;5;8;;1,1,1,1;0;0
Node;AmplifyShaderEditor.WireNode;24;-1511.431,221.8102;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;26;-1126.747,948.5643;Inherit;False;Property;_rockScale;rockScale;5;0;Create;True;0;0;0;False;0;False;0;46;0;50;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;2;-1245.006,113.994;Inherit;False;Property;_noiseScale;noiseScale;0;0;Create;True;0;0;0;False;0;False;3;13.8;0;50;0;1;FLOAT;0
Node;AmplifyShaderEditor.VoronoiNode;23;-744.1031,935.9072;Inherit;False;0;0;1;0;1;False;1;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;3;FLOAT;0;FLOAT2;1;FLOAT2;2
Node;AmplifyShaderEditor.SimpleSubtractOpNode;42;-946.3928,1186.209;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;40;-1181.268,1429.799;Inherit;False;Property;_rockIrregularity;rockIrregularity;10;0;Create;True;0;0;0;False;0;False;0;0.15;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;44;-731.6641,249.3774;Inherit;False;830.4844;605.9926;Ladrillos;4;18;17;19;20;;1,1,1,1;0;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;4;-879.5671,64.58495;Inherit;False;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;27;-506.8842,949.3201;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;39;-805.7826,1319.351;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;5;-779.8945,-363.6227;Inherit;False;Property;_colordark;color dark;1;0;Create;True;0;0;0;False;0;False;0.3301887,0.2521683,0.2227216,0;0.16,0.11,0.07,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;41;-392.7292,1319.875;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;6;-775.9941,-181.6232;Inherit;False;Property;_colorlight;color light;2;0;Create;True;0;0;0;False;0;False;0.5471698,0.452597,0.4155393,0;0.38,0.28,0.18,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SmoothstepOpNode;9;-654.692,41.8204;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.35;False;2;FLOAT;0.65;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;18;-681.6641,691.3694;Inherit;False;Property;_brickTiling;brickTiling;4;0;Create;True;0;0;0;False;0;False;0,0;50,50;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.CommentaryNode;46;265.1415,422.8261;Inherit;False;1311.398;451.4417;Relieve;5;31;34;16;35;15;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SmoothstepOpNode;28;-196.7965,953.4185;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.88;False;2;FLOAT;0.94;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;31;315.1415,645.4425;Inherit;False;Property;_brickHeight;brickHeight;7;0;Create;True;0;0;0;False;0;False;0;0.25;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;32;-186.3929,1323.642;Inherit;False;Property;_rockHeigth;rockHeigth;8;0;Create;True;0;0;0;False;0;False;0;8;0;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;19;-448.3356,432.6603;Inherit;False;Constant;_brickColor;brickColor;7;0;Create;True;0;0;0;False;0;False;0.4245283,0.3682999,0.3424261,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;17;-406.8241,636.2438;Inherit;False;Bricks Pattern;-1;;2;7d219d3a79fd53a48987a86fa91d6bac;0;4;15;FLOAT2;2,4;False;14;FLOAT;0.65;False;16;FLOAT;0.5;False;17;FLOAT2;0,1;False;2;FLOAT;0;FLOAT;3
Node;AmplifyShaderEditor.LerpOp;8;-364.7999,-167.2923;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;33;163.2625,1002.712;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;34;855.5724,472.8261;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;20;-83.18032,299.3774;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;16;922.8971,758.2675;Inherit;False;Property;_normalStrength;normalStrength;3;0;Create;True;0;0;0;False;0;False;0;20;0;50;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;35;1036.611,564.0781;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;29;1004.435,222.2336;Inherit;False;Property;_rockColor;rockColor;6;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.254717,0.254717,0.254717,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;21;499.9153,-300.7415;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;30;1558.545,302.1337;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;15;1266.538,665.7076;Inherit;False;Normal From Height;-1;;1;1942fe2c5f1a1f94881a33d532e4afeb;0;2;20;FLOAT;0;False;110;FLOAT;1;False;2;FLOAT3;40;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;2182.942,522.4045;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;Road;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;37;0;1;0
WireConnection;36;0;37;0
WireConnection;36;1;38;0
WireConnection;24;0;1;0
WireConnection;23;0;24;0
WireConnection;23;2;26;0
WireConnection;42;0;36;0
WireConnection;4;0;1;0
WireConnection;4;1;2;0
WireConnection;27;0;23;0
WireConnection;39;0;42;0
WireConnection;39;1;40;0
WireConnection;41;0;27;0
WireConnection;41;1;39;0
WireConnection;9;0;4;0
WireConnection;28;0;41;0
WireConnection;17;15;18;0
WireConnection;8;0;5;0
WireConnection;8;1;6;0
WireConnection;8;2;9;0
WireConnection;33;0;28;0
WireConnection;33;1;32;0
WireConnection;34;0;17;0
WireConnection;34;1;31;0
WireConnection;20;0;8;0
WireConnection;20;1;19;0
WireConnection;20;2;17;0
WireConnection;35;0;34;0
WireConnection;35;1;33;0
WireConnection;21;0;8;0
WireConnection;21;1;20;0
WireConnection;21;2;9;0
WireConnection;30;0;21;0
WireConnection;30;1;29;0
WireConnection;30;2;28;0
WireConnection;15;20;35;0
WireConnection;15;110;16;0
WireConnection;0;0;30;0
WireConnection;0;1;15;40
ASEEND*/
//CHKSM=080CB8306100F3FD3AB7DFE59131DE55A45F03C1