uniform mat4 MVPMatrix;

in vec3 in_position;

in vec3 in_normal;

vec4 in_color = vec4(1.0, 0.0, 0.0, 1.0);

out vec3 out_normal;

out vec4 out_color;


void main() {

  gl_Position = MVPMatrix * vec4(in_position, 1.0);

  out_normal = in_normal;

  out_color = in_color;

}
