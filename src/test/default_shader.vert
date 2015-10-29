uniform mat4 MVPMatrix;

in vec3 position;

in vec3 in_color;

out vec3 out_color;

void main() {

    gl_Position = MVPMatrix * vec4(position, 1.0);

    out_color = in_color;//(vec3(1.0, 1.0, 1.0) + in_color) / 2.0;

}
