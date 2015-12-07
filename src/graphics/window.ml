open OgamlCore

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

let create ~width ~height ~title ~settings =
  let internal = LL.Window.create ~width ~height ~title ~settings in
  let state = State.LL.create () in
  State.LL.set_viewport state OgamlMath.IntRect.({x = 0; y = 0; width; height});
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
  if ContextSettings.aa_level settings > 0 then begin
    State.LL.set_msaa state true;
    GL.Pervasives.msaa true;
  end;
  {
    state;
    internal;
    settings;
    program2D;
    programTex;
  }

let set_title win title = LL.Window.set_title win.internal title

let close win = LL.Window.close win.internal

let rect win = LL.Window.rect win.internal

let destroy win = LL.Window.destroy win.internal

let resize win size = LL.Window.resize win.internal size

let is_open win = LL.Window.is_open win.internal

let has_focus win = LL.Window.has_focus win.internal

let size win = LL.Window.size win.internal

let poll_event win = LL.Window.poll_event win.internal

let display win = LL.Window.display win.internal

let clear ?color:(color=`RGB Color.RGB.black) win =
  if State.LL.clear_color win.state <> color then begin
    let crgb = Color.rgb color in
    State.LL.set_clear_color win.state color;
    Color.RGB.(GL.Pervasives.color crgb.r crgb.g crgb.b crgb.a)
  end;
  let depth = ContextSettings.depth_bits win.settings > 0 in
  let stencil = ContextSettings.stencil_bits win.settings > 0 in
  GL.Pervasives.clear true depth stencil

let state win = win.state


module LL = struct

  let internal win = win.internal

  let program win = win.program2D

  let sprite_program win = win.programTex

  let bind_draw_parameters win parameters = 
    let state = win.state in
    let cull_mode = DrawParameter.culling parameters in
    if State.LL.culling_mode state <> cull_mode then begin
      State.LL.set_culling_mode state cull_mode;
      GL.Pervasives.culling cull_mode
    end;
    let poly_mode = DrawParameter.polygon parameters in
    if State.LL.polygon_mode state <> poly_mode then begin
      State.LL.set_polygon_mode state poly_mode;
      GL.Pervasives.polygon poly_mode
    end;
    let depth_testing = DrawParameter.depth_test parameters in
    if State.LL.depth_test state <> depth_testing then begin
      State.LL.set_depth_test state depth_testing;
      GL.Pervasives.depthtest depth_testing
    end;
    let viewport = 
      DrawParameter.Viewport.(
        let open OgamlMath in
        let sizei = size win in
        let sizef = Vector2f.from_int sizei in
        match DrawParameter.viewport parameters with
        |Full -> 
          IntRect.({x = 0; y = 0; 
                    width  = sizei.Vector2i.x; 
                    height = sizei.Vector2i.y})
        |Relative r -> 
          FloatRect.(floor 
            {x = sizef.Vector2f.x *. r.x; 
             y = sizef.Vector2f.y *. r.y;
             width  = sizef.Vector2f.x *. r.width;
             height = sizef.Vector2f.y *. r.height})
        |Absolute r -> r
      )
    in
    if State.LL.viewport state <> viewport then begin
      let open OgamlMath.IntRect in
      State.LL.set_viewport state viewport;
      GL.Pervasives.viewport viewport.x viewport.y viewport.width viewport.height;
    end;
    let blend_mode = DrawParameter.blend_mode parameters in
    DrawParameter.BlendMode.(
      let blending = (blend_mode.alpha <> Equation.None) || (blend_mode.color <> Equation.None) in
      if State.LL.blending state <> blending then begin
        State.LL.set_blending state blending;
        GL.Blending.enable blending
      end;
      let blend_alpha = 
        match blend_mode.alpha with
        |Equation.None -> Equation.Add (Factor.One, Factor.Zero)
        | eq -> eq
      in
      let blend_color = 
        match blend_mode.color with
        |Equation.None -> Equation.Add (Factor.One, Factor.Zero)
        | eq -> eq
      in
      let tag_alpha = Obj.tag (Obj.repr (State.LL.blend_equation state).alpha) in
      let tag_color = Obj.tag (Obj.repr (State.LL.blend_equation state).color) in
      let extract_sd = function
        |Equation.Add (s,d) -> (s,d)
        |Equation.Sub (s,d) -> (s,d)
        | _ -> assert false
      in
      if (extract_sd blend_alpha <> extract_sd (State.LL.blend_equation state).alpha)
      || (extract_sd blend_color <> extract_sd (State.LL.blend_equation state).color)
      then begin
        let (s_rgb, d_rgb), (s_alp, d_alp) = extract_sd blend_color, extract_sd blend_alpha in
        State.LL.set_blend_equation state {alpha = blend_alpha; color = blend_color};
        GL.Blending.blend_func_separate s_rgb d_rgb s_alp d_alp;
      end;
      if ((Obj.tag (Obj.repr blend_color)) <> tag_alpha)
      || ((Obj.tag (Obj.repr blend_alpha)) <> tag_color)
      then begin
        State.LL.set_blend_equation state {alpha = blend_alpha; color = blend_color};
        GL.Blending.blend_equation_separate blend_color blend_alpha
      end
    )


end
