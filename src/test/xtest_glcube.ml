open Xlib
open Tgl4
open OgamlMath

let () = 
  (* Create display and window *)
  let d = Display.create () in
  let rwin = Window.root_of d in
  let win = Window.create_simple
    ~display:d ~parent:rwin ~size:(800,600) ~origin:(50,50) ~background:(0)
  in
  let atom = Atom.intern d "WM_DELETE_WINDOW" false in
  begin 
    match atom with
    |None -> assert false
    |Some(a) -> Atom.set_wm_protocols d win [a]
  end;
  Window.map d win;
  Event.set_mask d win [Event.ExposureMask; Event.KeyPressMask; Event.ButtonPressMask; Event.PointerMotionMask];
  Display.flush d;

  (* Create and attach gl context *)
  let vi = VisualInfo.choose d [VisualInfo.RGBA; VisualInfo.DepthSize 24; VisualInfo.DoubleBuffer] in
  let ctx = GLContext.create d vi in
  Window.attach d win ctx;
  Gl.enable (Gl.depth_test);
  Gl.clear_color 1.0 1.0 1.0 1.0;

  (* Create matrices *)
  let proj = Matrix3f.perspective ~near:0.001 ~far:2000. ~width:800. ~height:600. ~fov:(90. *. 3.141592 /. 180.) in
  let view = Matrix3f.look_at 
    ~from:Vector3f.({x = 3.; y = 3.; z = 3.}) 
    ~at:Vector3f.({x = 0.; y = 0.; z = 0.})
    ~up:Vector3f.unit_y
  in
  let mvp = Matrix3f.product proj view in
   

  (* Display *)
  let display () = ()
  in


  (* Event loop *)
  let rec event_loop () = 
    match Event.next d win with
    |Some e -> begin
      match Event.data e with
      | Event.ClientMessage _ -> print_endline "Window closed"; true
      | _ -> event_loop ()
    end
    |None -> false
  in

  (* Main loop *)
  let rec loop () = 
    Gl.clear (Gl.color_buffer_bit lor Gl.depth_buffer_bit);
    display ();
    Window.swap d win;
    if event_loop () then ()
    else loop ()
  in

  loop ();
  Window.destroy d win


