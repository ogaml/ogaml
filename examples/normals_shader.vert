uniform mat4 MVPMatrix;

in vec3 in_position;

in vec3 in_normal;

uniform vec4 in_color;

out vec3 out_normal;

out vec4 out_color;


void main() {

  gl_Position = MVPMatrix * vec4(in_position, 1.0);

  out_normal = in_normal;

  out_color = in_color;

}
