#version 120

varying vec3 out_color;

void main() {

    gl_FragColor = vec4(vec3(out_color), 1.0);

}

