open OgamlCore
open OgamlUtils

type t = {
  context : Context.t;
  internal : LL.Window.t;
  settings : ContextSettings.t;
  mutable min_spf  : float;
  clock : Clock.t
}

let create ?width:(width=800) ?height:(height=600) ?title:(title="") 
           ?settings:(settings=OgamlCore.ContextSettings.create ()) () =
  let internal = LL.Window.create ~width ~height ~title ~settings in
  let context = Context.LL.create () in
  let min_spf = 
    match ContextSettings.framerate_limit settings with
    | None   -> 0.
    | Some i -> 1. /. (float_of_int i)
  in
  Context.LL.set_viewport context OgamlMath.IntRect.({x = 0; y = 0; width; height});
  {
    context;
    internal;
    settings;
    min_spf;
    clock = Clock.create ()
  }

let set_title win title = LL.Window.set_title win.internal title

let set_framerate_limit win i = 
  match i with
  | None   -> win.min_spf <- 0.
  | Some i -> win.min_spf <- 1. /. (float_of_int i)

let settings win = win.settings

let close win = LL.Window.close win.internal

let rect win = LL.Window.rect win.internal

let destroy win = LL.Window.destroy win.internal

let resize win size = LL.Window.resize win.internal size

let toggle_fullscreen win = LL.Window.toggle_fullscreen win.internal

let is_open win = LL.Window.is_open win.internal

let has_focus win = LL.Window.has_focus win.internal

let size win = LL.Window.size win.internal

let poll_event win = LL.Window.poll_event win.internal

let display win = 
  RenderTarget.bind_fbo win.context 0 None;
  LL.Window.display win.internal;
  if win.min_spf <> 0. then begin
    let dt = win.min_spf -. (Clock.time win.clock) in
    if dt > 0. then Thread.delay dt;
    Clock.restart win.clock
  end 

let clear ?color:(color=Some (`RGB Color.RGB.black))
          ?depth:(depth=true) 
          ?stencil:(stencil=true) win =
  let depth = (ContextSettings.depth_bits win.settings > 0) && depth in
  let stencil = (ContextSettings.stencil_bits win.settings > 0) && stencil in
  if depth && not (Context.LL.depth_writing win.context) then begin
    Context.LL.set_depth_writing win.context true;
    GL.Pervasives.depth_mask true
  end;
  RenderTarget.bind_fbo win.context 0 None;
  RenderTarget.clear ?color ~depth ~stencil win.context

let show_cursor win b = LL.Window.show_cursor win.internal b

let context win = win.context

let bind win params = 
  RenderTarget.bind_fbo win.context 0 None;
  RenderTarget.bind_draw_parameters win.context (size win)
    (ContextSettings.aa_level win.settings) params

let internal win = win.internal

