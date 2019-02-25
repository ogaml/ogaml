uniform mat4 MVPMatrix;

in vec3 position;
in vec3 normal;
in vec2 uv;

out vec3 out_normal;
out vec2 out_uv;


void main() {

  gl_Position = MVPMatrix * vec4(position, 1.0);

  out_normal = normal;

  out_uv = uv;

}
