uniform mat4 MVPMatrix;

in vec3 position;

in vec3 normal;

out vec3 out_normal;

out vec4 out_color;


void main() {

  gl_Position = MVPMatrix * vec4(position, 1.0);

  out_normal = normal;

  out_color = vec4(1.0, 0, 1.0, 1.0);

}
