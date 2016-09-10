uniform mat4 MVMatrix;

uniform mat4 VMatrix;

in vec3 out_normal;

in vec4 out_color;

out vec4 frag_color;

struct LightData 
{
  vec3 LightDir;
  vec3 AmbientIntensity;
  float SunIntensity;
  float MaxIntensity;
  float Gamma;
};

uniform LightData Light;

void main() {

  vec4 NormalCameraSpace = normalize(MVMatrix * vec4(out_normal,0.));
  vec4 LightCameraSpace  = normalize(VMatrix * vec4(-Light.LightDir,0.));

  float CosIncidence = dot(NormalCameraSpace.xyz, LightCameraSpace.xyz);
	CosIncidence = CosIncidence < 0.001 ? 0.0 : CosIncidence;
	CosIncidence = clamp(CosIncidence, 0., 1.);

  vec3 AccumulatedLight = out_color.rgb * CosIncidence * Light.SunIntensity + out_color.rgb * Light.AmbientIntensity;
       AccumulatedLight = AccumulatedLight / Light.MaxIntensity;

  vec3 InvGamma = vec3(1./Light.Gamma, 1./Light.Gamma, 1./Light.Gamma);

  frag_color = vec4(pow(AccumulatedLight, InvGamma), 1.);

}
