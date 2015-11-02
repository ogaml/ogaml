uniform sampler2D MyTex;

in vec2 frag_UV;

out vec4 frag_color;

void main() {

    frag_color = vec4(texture(MyTex, frag_UV).rgb, 1.0);

}
