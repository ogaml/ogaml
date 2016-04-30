
type t = 
  {
    shape  : Program.t;
    sprite : Program.t;
    text   : Program.t
  }

(** 2D drawing program *)
let vertex_shader_source_130 = "
  uniform vec2 size;

  in vec3 position;
  in vec4 color;

  out vec4 frag_color;

  void main() {

    gl_Position.x = 2.0 * position.x / size.x - 1.0;
    gl_Position.y = 2.0 * (size.y - position.y) / size.y - 1.0;
    gl_Position.z = 0.0;
    gl_Position.w = 1.0;

    frag_color = color;

  }
"

let fragment_shader_source_130 = "
  in vec4 frag_color;

  out vec4 pixel_color;

  void main() {

    pixel_color = frag_color;

  }
"

let vertex_shader_source_110 = "
  #version 110

  uniform vec2 size;

  attribute vec3 position;
  attribute vec4 color;

  varying vec4 frag_color;

  void main() {

    gl_Position.x = 2.0 * position.x / size.x - 1.0;
    gl_Position.y = 2.0 * (size.y - position.y) / size.y - 1.0;
    gl_Position.z = 0.0;
    gl_Position.w = 1.0;

    frag_color = color;

  }
"

let fragment_shader_source_110 = "
  #version 110

  varying vec4 frag_color;

  void main() {

    gl_FragColor = frag_color;

  }
"

(* Sprite drawing program *)
let vertex_shader_source_tex_130 = "
  uniform vec2 size;

  in vec3 position;
  in vec2 uv;

  out vec2 frag_uv;

  void main() {

    gl_Position.x = 2.0 * position.x / size.x - 1.0;
    gl_Position.y = 2.0 * (size.y - position.y) / size.y - 1.0;
    gl_Position.z = 0.0;
    gl_Position.w = 1.0;

    frag_uv = vec2(uv.x, 1.0 - uv.y);

  }
"

let fragment_shader_source_tex_130 = "
  uniform sampler2D utexture;

  in vec2 frag_uv;

  out vec4 out_color;

  void main() {

    out_color = texture(utexture, frag_uv);

  }
"

let vertex_shader_source_tex_110 = "
  #version 110

  uniform vec2 size;

  attribute vec3 position;
  attribute vec2 uv;

  varying vec2 frag_uv;

  void main() {

    gl_Position.x = 2.0 * position.x / size.x - 1.0;
    gl_Position.y = 2.0 * (size.y - position.y) / size.y - 1.0;
    gl_Position.z = 0.0;
    gl_Position.w = 1.0;

    frag_uv = vec2(uv.x, 1.0 - uv.y);

  }
"

let fragment_shader_source_tex_110 = "
  #version 110

  uniform sampler2D utexture;

  varying vec2 frag_uv;

  void main() {

    gl_FragColor = texture2D(utexture, frag_uv);

  }
"

(* Text drawing program *)
let vertex_shader_source_text_130 = "
  uniform vec2 window_size;
  uniform vec2 atlas_size;

  in vec3 position;
  in vec2 uv;
  in vec4 color;

  out vec2 frag_uv;
  out vec4 frag_color;

  void main() {

    gl_Position.x = 2.0 * position.x / window_size.x - 1.0;
    gl_Position.y = 2.0 * (window_size.y - position.y) / window_size.y - 1.0;
    gl_Position.z = 0.0;
    gl_Position.w = 1.0;

    frag_uv.x = uv.x / atlas_size.x;
    frag_uv.y = uv.y / atlas_size.y;

    frag_color = color;

  }
"

let fragment_shader_source_text_130 = "
  uniform sampler2D atlas;

  in vec2 frag_uv;
  in vec4 frag_color;

  out vec4 color;

  void main() {

    color = texture(atlas, frag_uv) * frag_color;

  }
"


let vertex_shader_source_text_110 = "
  #version 110

  uniform vec2 window_size;
  uniform vec2 atlas_size;

  attribute vec3 position;
  attribute vec2 uv;

  varying vec2 frag_uv;

  void main() {

    gl_Position.x = 2.0 * position.x / window_size.x - 1.0;
    gl_Position.y = 2.0 * (window_size.y - position.y) / window_size.y - 1.0;
    gl_Position.z = 0.0;
    gl_Position.w = 1.0;

    frag_uv.x = uv.x / atlas_size.x;
    frag_uv.y = uv.y / atlas_size.y;

  }
"

let fragment_shader_source_text_110 = "
  #version 110

  uniform sampler2D atlas;

  varying vec2 frag_uv;

  void main() {

    gl_FragColor = texture2D(atlas, frag_uv);

  }
"

let create state = 
  let shape =
    if State.is_glsl_version_supported state 130 then
      Program.from_source_pp state
        ~vertex_source:(`String vertex_shader_source_130)
        ~fragment_source:(`String fragment_shader_source_130)
    else
      Program.from_source state
        ~vertex_source:(`String vertex_shader_source_110)
        ~fragment_source:(`String fragment_shader_source_110)
  in
  let sprite =
    if State.is_glsl_version_supported state 130 then
      Program.from_source_pp state
        ~vertex_source:(`String vertex_shader_source_tex_130)
        ~fragment_source:(`String fragment_shader_source_tex_130)
    else
      Program.from_source state
        ~vertex_source:(`String vertex_shader_source_tex_110)
        ~fragment_source:(`String fragment_shader_source_tex_110)
  in
  let text =
    if State.is_glsl_version_supported state 130 then
      Program.from_source_pp state
        ~vertex_source:(`String vertex_shader_source_text_130)
        ~fragment_source:(`String fragment_shader_source_text_130)
    else
      Program.from_source state
        ~vertex_source:(`String vertex_shader_source_text_110)
        ~fragment_source:(`String fragment_shader_source_text_110)
  in
  {shape; sprite; text}

let shape_drawing t = t.shape

let sprite_drawing t = t.sprite

let atlas_drawing t = t.text
