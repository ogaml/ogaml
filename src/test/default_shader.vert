#version 120

uniform mat4 MVPMatrix;

attribute vec3 position;

attribute vec3 in_color;

varying vec3 out_color;

void main() {

    gl_Position = MVPMatrix * vec4(position, 1.0);

    out_color = in_color;

}
