open OgamlGraphics
open OgamlMath

let settings = ContextSettings.create ~color:(`RGB Color.RGB.white) ()

let window = Window.create ~width:800 ~height:600 ~settings

let () = GL.Pervasives.color 1. 1. 1. 1.

let initial_time = ref 0.

let frame_count  = ref 0

let axis_source = 
  let src = VertexArray.Source.empty
    ~position:"in_position"
    ~color:"in_color"
    ~size:6 ()
  in
  Poly.axis src Vector3f.({x = -1.; y = -1.; z = -1.}) Vector3f.({x = 5.; y = 5.; z = 5.})

let cube_source = 
  let src = VertexArray.Source.empty 
    ~position:"in_position" 
    ~normal:"in_normal"
    ~size:36 () 
  in
(*   Poly.cube src Vector3f.({x = -0.5; y = -0.5; z = -0.5}) Vector3f.({x = 1.; y = 1.; z = 1.}) *)
  src

let cube_model = Model.empty ()

let () = 
  let pt0 = Model.add_point cube_model ~vertex:Vector3f.({x = -1.; y = -1.; z = -1.}) () in
  let pt1 = Model.add_point cube_model ~vertex:Vector3f.({x = -1.; y = -1.; z =  1.}) () in
  let pt2 = Model.add_point cube_model ~vertex:Vector3f.({x =  1.; y = -1.; z = -1.}) () in
  let pt3 = Model.add_point cube_model ~vertex:Vector3f.({x =  1.; y = -1.; z =  1.}) () in
  let pt4 = Model.add_point cube_model ~vertex:Vector3f.({x = -1.; y =  1.; z = -1.}) () in
  let pt5 = Model.add_point cube_model ~vertex:Vector3f.({x = -1.; y =  1.; z =  1.}) () in
  let pt6 = Model.add_point cube_model ~vertex:Vector3f.({x =  1.; y =  1.; z = -1.}) () in
  let pt7 = Model.add_point cube_model ~vertex:Vector3f.({x =  1.; y =  1.; z =  1.}) () in
  Model.make_face cube_model (pt4,pt5,pt6); Model.make_face cube_model (pt6,pt5,pt7);
  Model.make_face cube_model (pt5,pt1,pt7); Model.make_face cube_model (pt7,pt1,pt3);
  Model.make_face cube_model (pt7,pt3,pt6); Model.make_face cube_model (pt6,pt3,pt2);
  Model.make_face cube_model (pt4,pt0,pt5); Model.make_face cube_model (pt5,pt0,pt1);
  Model.make_face cube_model (pt6,pt2,pt4); Model.make_face cube_model (pt4,pt2,pt0);
  Model.make_face cube_model (pt1,pt0,pt3); Model.make_face cube_model (pt3,pt0,pt2);
  Model.scale cube_model 0.5;
  Model.compute_normals cube_model;
  Model.source cube_model ~vertex_source:cube_source ()



let axis = VertexArray.static axis_source 

let cube = VertexArray.static cube_source 

let default_program = 
  Program.from_source_pp (Window.state window)
    ~vertex_source:(`File "examples/default_shader.vert")
    ~fragment_source:(`File "examples/default_shader.frag")

let normal_program =
  Program.from_source_pp (Window.state window)
    ~vertex_source:(`File "examples/normals_shader.vert")
    ~fragment_source:(`File "examples/normals_shader.frag")

(* Display computations *)
let proj = Matrix3D.perspective ~near:0.01 ~far:1000. ~width:800. ~height:600. ~fov:(90. *. 3.141592 /. 180.)

let position = ref Vector3f.({x = 1.; y = 0.6; z = 1.4})

let rot_angle = ref 0.

let view_theta = ref 0.

let view_phi = ref 0.

let display () =
  (* Compute model matrix *)
  let t = Unix.gettimeofday () in
  let view = Matrix3D.look_at_eulerian ~from:!position ~theta:!view_theta ~phi:!view_phi in
  let rot_vector = Vector3f.({x = (cos t); y = (sin t); z = (cos t) *. (sin t)}) in
  let model = Matrix3D.rotation rot_vector !rot_angle in
  let vp = Matrix3D.product proj view in
  let mv = Matrix3D.product view model in
  let mvp = Matrix3D.product vp model in
  rot_angle := !rot_angle +. (abs_float (cos t /. 10.)) /. 3.;
  let parameters =
    DrawParameter.(make 
      ~depth_test:true 
      ~culling:CullingMode.CullClockwise ())
  in
  let uniform =
    Uniform.empty
    |> Uniform.matrix3D "MVPMatrix" mvp
    |> Uniform.matrix3D "MVMatrix" mv
    |> Uniform.matrix3D "VMatrix" view
  in
  Window.draw ~window ~vertices:cube ~uniform ~program:normal_program ~parameters ~mode:DrawMode.Triangles ();
  let uniform =
    Uniform.empty
    |> Uniform.matrix3D "MVPMatrix" vp
  in
  Window.draw ~window ~vertices:axis ~uniform ~program:default_program ~parameters ~mode:DrawMode.Lines ()


(* Camera *)
let centerx, centery =
  let (x,y) = Window.size window in
  (x / 2, y / 2)

let () =
  Mouse.set_relative_position window (centerx, centery)

let rec update_camera () =
  let x,y = Mouse.relative_position window in
  let dx, dy = x - centerx, y - centery in
  let lim = Constants.pi /. 2. -. 0.1 in
  view_theta := !view_theta -. 0.005 *. (float_of_int dx);
  view_phi   := !view_phi   -. 0.005 *. (float_of_int dy);
  view_phi   := min (max !view_phi (-.lim)) lim;
  Mouse.set_relative_position window (centerx, centery)

(* Handle keys directly by polling the keyboard *)
let handle_keys () =
  OgamlCore.Keycode.(Keyboard.(
    if is_pressed Z || is_pressed Up then
      position := Vector3f.(add
        !position
        {x = -. 0.15 *. (sin !view_theta);
         y = 0.;
         z = -. 0.15 *. (cos !view_theta)}) ;
    if is_pressed S || is_pressed Down then
      position := Vector3f.(add
        !position
        {x = 0.15 *. (sin !view_theta);
         y = 0.;
         z = 0.15 *. (cos !view_theta)}) ;
    if is_pressed Q || is_pressed Left then
      position := Vector3f.(add
        !position
        {x = -. 0.15 *. (cos !view_theta);
         y = 0.;
         z = 0.15 *. (sin !view_theta)}) ;
    if is_pressed D || is_pressed Right then
      position := Vector3f.(add
        !position
        {x = 0.15 *. (cos !view_theta);
         y = 0.;
         z = -. 0.15 *. (sin !view_theta)})
  ))


(* Event loop *)
let rec event_loop () =
  let open OgamlCore in
  match Window.poll_event window with
  |Some e -> begin
    match e with
    |Event.Closed ->
      Window.close window
    |Event.KeyPressed k -> Keycode.(
      match k.Event.KeyEvent.key with
      | Escape -> Window.close window
      | Q when k.Event.KeyEvent.control -> Window.close window
      | _ -> ()
    )
    | _ -> ()
  end; event_loop ()
  |None -> ()


(* Main loop *)
let rec main_loop () =
  if Window.is_open window then begin
    Window.clear window;
    display ();
    Window.display window;
    (* We only capture the mouse and listen to the keyboard when focused *)
    if Window.has_focus window then (
      update_camera () ;
      handle_keys ()
    ) ;
    event_loop ();
    incr frame_count;
    main_loop ()
  end


(* Start *)
let () =
  Printf.printf "Rendering %i vertices\n%!" (VertexArray.length cube);
  initial_time := Unix.gettimeofday ();
  main_loop ();
  Printf.printf "Avg FPS: %f\n%!" (float_of_int (!frame_count) /. (Unix.gettimeofday () -. !initial_time));
  Window.destroy window


