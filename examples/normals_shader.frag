uniform mat4 MVMatrix;

uniform mat4 VMatrix;

in vec3 out_normal;

in vec4 out_color;

out vec4 frag_color;

vec3 LightDir = vec3(-4., -2., -3.);
vec3 AmbientIntensity = vec3(0.30, 0.30, 0.30);
float SunIntensity = 1.6;
float MaxIntensity = 1.0;
float Gamma = 1.2;

void main() {

  vec4 NormalCameraSpace = normalize(MVMatrix * vec4(out_normal,0.));
  vec4 LightCameraSpace  = normalize(VMatrix * vec4(-LightDir,0.));

  float CosIncidence = dot(NormalCameraSpace.xyz, LightCameraSpace.xyz);
	CosIncidence = CosIncidence < 0.001 ? 0.0 : CosIncidence;
	CosIncidence = clamp(CosIncidence, 0., 1.);

  vec3 AccumulatedLight = out_color.rgb * CosIncidence * SunIntensity + out_color.rgb * AmbientIntensity;
       AccumulatedLight = AccumulatedLight / MaxIntensity;

  vec3 InvGamma = vec3(1./Gamma, 1./Gamma, 1./Gamma);

  frag_color = vec4(pow(AccumulatedLight, InvGamma), 1.);

}
