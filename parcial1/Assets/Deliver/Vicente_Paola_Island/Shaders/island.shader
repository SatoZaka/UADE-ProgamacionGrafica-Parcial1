// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "island"
{
	Properties
	{
		_colortexture("color texture", 2D) = "white" {}
		_heighttexture("height texture", 2D) = "white" {}
		_maxHeight("maxHeight", Range( 0 , 50)) = 1
		_tessFactor("tessFactor", Float) = 8
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGPROGRAM
		#pragma target 4.6
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows vertex:vertexDataFunc tessellate:tessFunction 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform sampler2D _heighttexture;
		uniform float4 _heighttexture_ST;
		uniform float _maxHeight;
		uniform sampler2D _colortexture;
		uniform float4 _colortexture_ST;
		uniform float _tessFactor;

		float4 tessFunction( appdata_full v0, appdata_full v1, appdata_full v2 )
		{
			float4 temp_cast_0 = (_tessFactor).xxxx;
			return temp_cast_0;
		}

		void vertexDataFunc( inout appdata_full v )
		{
			float2 uv_heighttexture = v.texcoord * _heighttexture_ST.xy + _heighttexture_ST.zw;
			v.vertex.xyz += ( tex2Dlod( _heighttexture, float4( uv_heighttexture, 0, 0.0) ).r * float3(0,1,0) * _maxHeight );
			v.vertex.w = 1;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_colortexture = i.uv_texcoord * _colortexture_ST.xy + _colortexture_ST.zw;
			o.Albedo = tex2D( _colortexture, uv_colortexture ).rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18900
363;73;1101;535;1336.271;144.0735;1.6;False;False
Node;AmplifyShaderEditor.TexturePropertyNode;3;-961.4784,176.2899;Inherit;True;Property;_heighttexture;height texture;1;0;Create;True;0;0;0;False;0;False;427d0548a86e08c459e82bb7b189c695;427d0548a86e08c459e82bb7b189c695;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TexturePropertyNode;1;-887.274,-32.45105;Inherit;True;Property;_colortexture;color texture;0;0;Create;True;0;0;0;False;0;False;a04e65ea8642ed34bac4bb2083b6d830;a04e65ea8642ed34bac4bb2083b6d830;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SamplerNode;4;-637.5,178.5;Inherit;True;Property;_TextureSample1;Texture Sample 1;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector3Node;6;-654.1645,383.6655;Inherit;False;Constant;_Vector0;Vector 0;2;0;Create;True;0;0;0;False;0;False;0,1,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;7;-716.981,535.5034;Inherit;False;Property;_maxHeight;maxHeight;2;0;Create;True;0;0;0;False;0;False;1;50;0;50;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;9;-87.64381,453.0562;Inherit;False;Property;_tessFactor;tessFactor;3;0;Create;True;0;0;0;False;0;False;8;5.4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;5;-310.5658,258.409;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;2;-636.8655,-35.22858;Inherit;True;Property;_TextureSample0;Texture Sample 0;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NormalVertexDataNode;10;-595.95,872.9312;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;243.131,1.66893E-06;Float;False;True;-1;6;ASEMaterialInspector;0;0;Standard;island;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;True;1;15;10;25;False;0.685;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;4;0;3;0
WireConnection;5;0;4;1
WireConnection;5;1;6;0
WireConnection;5;2;7;0
WireConnection;2;0;1;0
WireConnection;0;0;2;0
WireConnection;0;11;5;0
WireConnection;0;14;9;0
ASEEND*/
//CHKSM=BD08136423F6F2325D63FA1A5D9247B6B766307E