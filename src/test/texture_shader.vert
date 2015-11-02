uniform mat4 MVPMatrix;

in vec3 position;

in vec3 normal;

out vec2 frag_UV;

vec2 extract_UV() {

  if(normal.x != 0.)
    return vec2((position.y > 0.)? 1. : 0.,
                (position.z > 0.)? 1. : 0.);

  if(normal.y != 0.)
    return vec2((position.z > 0.)? 1. : 0.,
                (position.x > 0.)? 1. : 0.);

  return vec2((position.x > 0.)? 1. : 0.,
              (position.y > 0.)? 1. : 0.);

}


void main() {

    gl_Position = MVPMatrix * vec4(position, 1.0);

    frag_UV = extract_UV();

}
