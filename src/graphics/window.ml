open OgamlCore

exception Missing_uniform of string

exception Invalid_uniform of string

type t = {
  state : State.t;
  internal : LL.Window.t;
  settings : ContextSettings.t;
  program2D : Program.t;
  programTex : Program.t
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

    frag_uv = uv;

  }
"

let fragment_shader_source_tex_130 = "
  uniform sampler2D my_texture;

  in vec2 frag_uv;

  out vec4 out_color;

  void main() {

    out_color = texture(my_texture, frag_uv);

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

    frag_uv = uv;

  }
"

let fragment_shader_source_tex_110 = "
  #version 110

  uniform sampler2D my_texture;

  varying vec2 frag_uv;

  void main() {

    gl_FragColor = texture2D(my_texture, frag_uv);

  }
"

let create ~width ~height ~settings =
  let internal = LL.Window.create ~width ~height in
  let state = State.LL.create () in
  let program2D =
    if State.is_glsl_version_supported state 130 then
      Program.from_source_pp state
        ~vertex_source:(`String vertex_shader_source_130)
        ~fragment_source:(`String fragment_shader_source_130)
    else
      Program.from_source
        ~vertex_source:(`String vertex_shader_source_110)
        ~fragment_source:(`String fragment_shader_source_110)
  in
  let programTex =
    if State.is_glsl_version_supported state 130 then
      Program.from_source_pp state
        ~vertex_source:(`String vertex_shader_source_tex_130)
        ~fragment_source:(`String fragment_shader_source_tex_130)
    else
      Program.from_source
        ~vertex_source:(`String vertex_shader_source_tex_110)
        ~fragment_source:(`String fragment_shader_source_tex_110)
  in
  {
    state;
    internal;
    settings;
    program2D;
    programTex;
  }

let close win = LL.Window.close win.internal

let destroy win = LL.Window.destroy win.internal

let is_open win = LL.Window.is_open win.internal

let has_focus win = LL.Window.has_focus win.internal

let size win = LL.Window.size win.internal

let poll_event win = LL.Window.poll_event win.internal

let display win = LL.Window.display win.internal

let clear win =
  let cc = ContextSettings.color win.settings in
  if State.clear_color win.state <> cc then begin
    let crgb = Color.rgb cc in
    State.LL.set_clear_color win.state cc;
    Color.RGB.(GL.Pervasives.color crgb.r crgb.g crgb.b crgb.a)
  end;
  let color = ContextSettings.color_clearing win.settings in
  let depth = ContextSettings.depth_testing  win.settings in
  let stencil = ContextSettings.stenciling   win.settings in
  GL.Pervasives.clear color depth stencil

let state win = win.state


module LL = struct

  let internal win = win.internal

  let program win = win.program2D

  let sprite_program win = win.programTex

end
