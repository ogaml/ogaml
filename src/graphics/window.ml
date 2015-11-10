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

let draw ~window ~vertices ~program ~uniform ~parameters =
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
  VertexArray.LL.draw window.state vertices program

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

end

