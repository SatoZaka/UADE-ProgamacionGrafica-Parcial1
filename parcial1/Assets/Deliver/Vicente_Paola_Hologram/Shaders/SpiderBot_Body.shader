// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "SpiderBot_Body"
{
	Properties
	{
		_bodyColor("bodyColor", Color) = (0.3015308,0.3154664,0.5283019,0)
		_smoothness("smoothness", Range( 1 , 1.3)) = 0.65
		_metallic("metallic", Range( 2 , 5)) = 0.7
		_energyColor("energyColor", Color) = (0.3372549,0.6784314,0.8,0)
		_energyStrength("energyStrength", Range( 0 , 2)) = 2
		_pulseSpeed("pulseSpeed", Range( 0 , 50)) = 3
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows 
		struct Input
		{
			half filler;
		};

		uniform float4 _bodyColor;
		uniform float _pulseSpeed;
		uniform float _energyStrength;
		uniform float4 _energyColor;
		uniform float _metallic;
		uniform float _smoothness;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			o.Albedo = _bodyColor.rgb;
			o.Emission = ( ( (0.2 + (sin( ( _Time.y * _pulseSpeed ) ) - -1.0) * (1.0 - 0.2) / (1.0 - -1.0)) * _energyStrength ) * _energyColor ).rgb;
			o.Metallic = _metallic;
			o.Smoothness = _smoothness;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18900
7;1;1906;1005;1132.294;129.65;1;False;False
Node;AmplifyShaderEditor.RangedFloatNode;9;-1189.034,320.3624;Inherit;False;Property;_pulseSpeed;pulseSpeed;5;0;Create;True;0;0;0;False;0;False;3;20;0;50;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;6;-1015.161,236.0637;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;8;-728.3247,273.0446;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;7;-577.0383,281.262;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;14;-426.9113,287.7344;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;-1;False;2;FLOAT;1;False;3;FLOAT;0.2;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-534.2819,494.6465;Inherit;False;Property;_energyStrength;energyStrength;4;0;Create;True;0;0;0;False;0;False;2;1.5;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;4;-174.7538,501.0054;Inherit;False;Property;_energyColor;energyColor;3;0;Create;True;0;0;0;False;0;False;0.3372549,0.6784314,0.8,0;0.1215686,0.4339623,0.5450981,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;11;-199.4115,251.55;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;1;-675.7745,-21.0199;Inherit;False;Property;_bodyColor;bodyColor;0;0;Create;True;0;0;0;False;0;False;0.3015308,0.3154664,0.5283019,0;0.2078431,0.2196078,0.372549,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;12;43.0961,263.2573;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;3;-462.0489,96.33305;Inherit;False;Property;_metallic;metallic;2;0;Create;True;0;0;0;False;0;False;0.7;3;2;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;2;-524.644,189.8728;Inherit;False;Property;_smoothness;smoothness;1;0;Create;True;0;0;0;False;0;False;0.65;1.26;1;1.3;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;293.3427,-12.27946;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;SpiderBot_Body;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;8;0;6;0
WireConnection;8;1;9;0
WireConnection;7;0;8;0
WireConnection;14;0;7;0
WireConnection;11;0;14;0
WireConnection;11;1;5;0
WireConnection;12;0;11;0
WireConnection;12;1;4;0
WireConnection;0;0;1;0
WireConnection;0;2;12;0
WireConnection;0;3;3;0
WireConnection;0;4;2;0
ASEEND*/
//CHKSM=9511024395CC56E8EA5A0569842218739F5CB617