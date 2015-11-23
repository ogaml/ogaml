open OgamlCore

exception Missing_uniform of string

exception Invalid_uniform of string

type t = {state : State.t; internal : LL.Window.t; settings : ContextSettings.t}

let create ~width ~height ~settings =
  let internal = LL.Window.create ~width ~height in
  {
    state = State.LL.create ();
    internal;
    settings
  }

let close win = LL.Window.close win.internal

let destroy win = LL.Window.destroy win.internal

let is_open win = LL.Window.is_open win.internal

let has_focus win = LL.Window.has_focus win.internal

let size win = LL.Window.size win.internal

let poll_event win = LL.Window.poll_event win.internal

let display win = LL.Window.display win.internal

let draw ~window ?indices ~vertices ~program ~uniform ~parameters ~mode () =
  let cull_mode = DrawParameter.culling parameters in
  if State.culling_mode window.state <> cull_mode then begin
    State.LL.set_culling_mode window.state cull_mode;
    GL.Pervasives.culling cull_mode
  end;
  let poly_mode = DrawParameter.polygon parameters in
  if State.polygon_mode window.state <> poly_mode then begin
    State.LL.set_polygon_mode window.state poly_mode;
    GL.Pervasives.polygon poly_mode
  end;
  let depth_testing = DrawParameter.depth_test parameters in
  if State.depth_test window.state <> depth_testing then begin
    State.LL.set_depth_test window.state depth_testing;
    GL.Pervasives.depthtest depth_testing
  end;
  Program.LL.use window.state (Some program);
  Program.LL.iter_uniforms program (fun unif -> Uniform.LL.bind window.state uniform unif);
  VertexArray.LL.bind window.state vertices program;
  match indices with
  |None -> GL.VAO.draw mode 0 (VertexArray.length vertices)
  |Some ebo ->
    IndexArray.LL.bind window.state ebo;
    GL.VAO.draw_elements mode (IndexArray.length ebo)

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

let draw_shape =
  let vertex_shader_source = "
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
  in
  let fragment_shader_source = "
    in vec4 frag_color;

    out vec4 pixel_color;

    void main() {

      pixel_color = frag_color;

    }
  "
  in
  fun window shape ->
    let program =
      Program.from_source_pp
        (state window)
        ~vertex_source:(`String vertex_shader_source)
        ~fragment_source:(`String fragment_shader_source)
    in
    let parameters = DrawParameter.make () in
    let (sx,sy) = size window in
    let uniform =
      Uniform.empty
      |> Uniform.vector2f "size" OgamlMath.(
           Vector2f.from_int Vector2i.({ x = sx ; y = sy })
         )
    in
    let vertices = Shape.get_vertex_array shape in
    draw ~window
         ~vertices
         ~program
         ~parameters
         ~uniform
         ~mode:DrawMode.Triangles ()


module LL = struct

  let internal win = win.internal

end
