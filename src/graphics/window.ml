open OgamlCore

exception Missing_uniform of string

exception Invalid_uniform of string

type t = {state : State.t; internal : Core.Window.t}

let create ~width ~height = 
  let internal = Core.Window.create ~width ~height in
  {
    state = State.create ();
    internal
  }

let close win = Core.Window.close win.internal

let destroy win = Core.Window.destroy win.internal

let is_open win = Core.Window.is_open win.internal

let has_focus win = Core.Window.has_focus win.internal

let size win = Core.Window.size win.internal

let poll_event win = Core.Window.poll_event win.internal

let display win = Core.Window.display win.internal

let draw ~window ~vertices ~program ~uniform ~parameters =
  let cull_mode = DrawParameter.culling parameters in
  if State.culling_mode window.state <> cull_mode then begin
    State.set_culling_mode window.state cull_mode;
    Internal.Pervasives.culling cull_mode
  end;
  let poly_mode = DrawParameter.polygon parameters in
  if State.polygon_mode window.state <> poly_mode then begin
    State.set_polygon_mode window.state poly_mode;
    Internal.Pervasives.polygon poly_mode
  end;
  Program.use window.state (Some program);
  Program.iter_uniforms program (fun unif -> Uniform.bind uniform unif);
  VertexArray.draw window.state vertices program

let clear win ~color ~depth ~stencil = 
  Internal.Pervasives.clear color depth stencil

let state win = win.state

let internal win = win.internal

