uniform mat4 MVPMatrix;

in vec3 in_position;

in vec4 in_color;

out vec4 out_color;

void main() {

  gl_Position = MVPMatrix * vec4(in_position, 1.0);

  out_color = in_color;

}
