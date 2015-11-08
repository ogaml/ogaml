open OgamlGraphics
open OgamlMath

let window = Window.create ~width:800 ~height:600

let () = Internal.Pervasives.color 1. 1. 1. 1.

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
    ~color:"in_color" 
    ~size:36 () 
  in
  Poly.cube src Vector3f.({x = -0.5; y = -0.5; z = -0.5}) Vector3f.({x = 1.; y = 1.; z = 1.})

let axis = VertexArray.static axis_source Enum.DrawMode.Lines

let cube = VertexArray.static cube_source Enum.DrawMode.Triangles

let program = 
  Program.from_source_pp (Window.state window)
    ~vertex_source:(`File "examples/default_shader.vert")
    ~fragment_source:(`File "examples/default_shader.frag")

(* Display computations *)
let proj = Matrix3D.perspective ~near:0.01 ~far:1000. ~width:800. ~height:600. ~fov:(90. *. 3.141592 /. 180.)

let position = ref Vector3f.({x = 1.; y = 0.6; z = 1.4})

let rot_angle = ref 0.

let view_theta = ref 0.

let view_phi = ref 0.

let display () =
  (* Compute model matrix *)
  let t = Unix.gettimeofday () in
  let view =
    Matrix3D.translation (Vector3f.prop (-1.) !position)
    |> Matrix3D.product
      (Matrix3D.from_quaternion
        (Quaternion.times
          (Quaternion.rotation Vector3f.unit_y !view_theta)
          (Quaternion.rotation Vector3f.unit_x !view_phi)
        ))
  in
  let rot_vector = Vector3f.({x = (cos t); y = (sin t); z = (cos t) *. (sin t)}) in
  let model = Matrix3D.rotation rot_vector !rot_angle in
  let vp = Matrix3D.product proj view in
  let mvp = Matrix3D.product vp model in
  rot_angle := !rot_angle +. (abs_float (cos (Unix.gettimeofday ()) /. 10.));
  let uniform =
    Uniform.empty
    |> Uniform.matrix3D "MVPMatrix" mvp
  in
  let parameters =
    DrawParameter.(make 
      ~depth_test:true 
      ~culling:CullingMode.CullCounterClockwise ())
  in
  Window.draw ~window ~vertices:cube ~uniform ~program ~parameters;
  let uniform =
    Uniform.empty
    |> Uniform.matrix3D "MVPMatrix" vp
  in
  Window.draw ~window ~vertices:axis ~uniform ~program ~parameters


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
    Window.clear window ~color:true ~depth:true ~stencil:false;
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
  Printf.printf "Rendering %i vertices\n%!" (VertexArray.length cube / 7);
  initial_time := Unix.gettimeofday ();
  main_loop ();
  Printf.printf "Avg FPS: %f\n%!" (float_of_int (!frame_count) /. (Unix.gettimeofday () -. !initial_time));
  Window.destroy window
