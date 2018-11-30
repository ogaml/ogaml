open OgamlCore
open OgamlUtils
open OgamlMath
open Result.Operators

module OutputBuffer = struct

  include GLTypes.WindowOutputBuffer

  let index_of_buffer = function
    | FrontLeft -> 0
    | FrontRight -> 1
    | BackLeft -> 2
    | BackRight -> 3
    | None -> 4

end

type t = {
  context : Context.t;
  internal : LL.Window.t;
  settings : ContextSettings.t;
  mutable min_spf  : float;
  bound_buffers : OutputBuffer.t array;
  mutable n_bound_buffers : int;
  clock : Clock.t
}

let create ?width:(width=800) ?height:(height=600) ?title:(title="") 
           ?settings:(settings=OgamlCore.ContextSettings.create ()) () =
  let internal =
    try Ok (LL.Window.create ~width ~height ~title ~settings)
    with Failure s -> Error (`Window_creation_error s)
  in
  internal >>= fun internal ->
  Context.LL.create () >>>= fun context ->
  let min_spf = 
    match ContextSettings.framerate_limit settings with
    | None   -> 0.
    | Some i -> 1. /. (float_of_int i)
  in
  let maxbufs = (Context.capabilities context).Context.max_draw_buffers in
  let bound_buffers = Array.make maxbufs OutputBuffer.None in
  bound_buffers.(0) <- OutputBuffer.BackLeft;
  Context.LL.set_viewport context OgamlMath.IntRect.({x = 0; y = 0; width; height});
  {
    context;
    internal;
    settings;
    min_spf;
    bound_buffers;
    n_bound_buffers = 1;
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

let activate_buffers win buffers = 
  let max_buffers = Array.length win.bound_buffers in
  let active_buffers = Array.make 5 false in
  Result.List.fold_left (fun (idx, changed) buf ->
    (if idx >= max_buffers then
      Error `Too_many_draw_buffers
    else Ok ()) >>= fun () ->
    let changed = changed 
      || win.bound_buffers.(idx) <> buf 
      || idx >= win.n_bound_buffers
    in
    (if buf <> OutputBuffer.None then begin
      let i = OutputBuffer.index_of_buffer buf in
      if active_buffers.(i) then
        Error `Duplicate_draw_buffer
      else begin
        active_buffers.(i) <- true;
        Ok ()
      end
    end else Ok ()) >>>= fun () ->
    win.bound_buffers.(idx) <- buf;
    (idx + 1, changed)
  ) (0, false) buffers
  >>>= fun (length, changed) ->
  if changed || length <> win.n_bound_buffers then begin
    win.n_bound_buffers <- length;
    GL.FBO.draw_default_buffers length win.bound_buffers
  end

let clear ?buffers:(buffers = [OutputBuffer.BackLeft])
          ?color:(color=Some (`RGB Color.RGB.black))
          ?depth:(depth=true) 
          ?stencil:(stencil=true) win =
  let depth = (ContextSettings.depth_bits win.settings > 0) && depth in
  let stencil = (ContextSettings.stencil_bits win.settings > 0) && stencil in
  if depth && not (Context.LL.depth_writing win.context) then begin
    Context.LL.set_depth_writing win.context true;
    GL.Pervasives.depth_mask true
  end;
  RenderTarget.bind_fbo win.context 0 None;
  activate_buffers win buffers >>>= (fun () -> 
  RenderTarget.clear ?color ~depth ~stencil win.context)

let show_cursor win b = LL.Window.show_cursor win.internal b

let context win = win.context

let bind win ?buffers:(buffers = [OutputBuffer.BackLeft]) params = 
  RenderTarget.bind_fbo win.context 0 None;
  activate_buffers win buffers >>>= (fun () ->
  RenderTarget.bind_draw_parameters win.context (size win)
    (ContextSettings.aa_level win.settings) params)

let internal win = win.internal

let screenshot win = 
  let size = size win in 
  RenderTarget.bind_fbo win.context 0 None;
  let data = 
    GL.Pervasives.read_pixels (0,0) (size.Vector2i.x, size.Vector2i.y) GLTypes.PixelFormat.RGBA
  in
  let rev_data = 
    Bytes.create (Bytes.length data) 
  in
  for i = 0 to size.Vector2i.y - 1 do
    Bytes.blit data (i * size.Vector2i.x * 4) rev_data ((size.Vector2i.y - 1 - i) * size.Vector2i.x * 4) (size.Vector2i.x * 4)
  done;
  Image.create (`Data (size, rev_data)) |> Result.assert_ok

