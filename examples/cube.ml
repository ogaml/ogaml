open OgamlGraphics
open OgamlMath
open OgamlUtils

let settings = OgamlCore.ContextSettings.create ~msaa:8 ()

let window =
  Window.create ~width:800 ~height:600 ~title:"Cube Example" ~settings ()

let fps_clock = 
  Clock.create ()

let cube_source =
  let src = VertexArray.VertexSource.empty ~size:36 () in
  let cmod = Model.cube Vector3f.({x = -0.5; y = -0.5; z = -0.5}) Vector3f.({x = 1.; y = 1.; z = 1.}) in
  Model.source cmod ~vertex_source:src ();
  src

let cube = VertexArray.static (module Window) window cube_source

let normal_program =
  Program.from_source_pp (module Window) ~context:window
    ~vertex_source:(`File (OgamlCore.OS.resources_dir ^ "examples/normals_shader.vert"))
    ~fragment_source:(`File (OgamlCore.OS.resources_dir ^ "examples/normals_shader.frag")) ()

(* Display computations *)
let proj = Matrix3D.perspective ~near:0.01 ~far:1000. ~width:800. ~height:600. ~fov:(90. *. 3.141592 /. 180.)

let position = ref Vector3f.({x = 1.; y = 0.6; z = 1.4})

let rot_angle = ref 0.

let view_theta = ref 0.

let view_phi = ref 0.

let msaa = ref true

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
      ~culling:CullingMode.CullClockwise
      ~antialiasing:!msaa ())
  in
  let uniform =
    Uniform.empty
    |> Uniform.matrix3D "MVPMatrix" mvp
    |> Uniform.matrix3D "MVMatrix" mv
    |> Uniform.matrix3D "VMatrix" view
    |> Uniform.vector3f "Light.LightDir" Vector3f.{x = -4.; y = -2.; z = -3.}
    |> Uniform.vector3f "Light.AmbientIntensity" Vector3f.{x = 0.3; y = 0.3; z = 0.3}
    |> Uniform.float    "Light.SunIntensity" 1.6
    |> Uniform.float    "Light.MaxIntensity" 1.9
    |> Uniform.float    "Light.Gamma"  1.2
  in
  VertexArray.draw (module Window) ~target:window
                   ~vertices:cube ~uniform ~program:normal_program ~parameters ~mode:DrawMode.Triangles ()


(* Camera *)
let center = Vector2i.div 2 (Window.size window)

let () =
  Mouse.set_relative_position window center

let rec update_camera () =
  let vmouse = Mouse.relative_position window in
  let dv = Vector2i.sub vmouse center in
  let lim = Constants.pi /. 2. -. 0.1 in
  view_theta := !view_theta -. 0.005 *. (float_of_int dv.OgamlMath.Vector2i.x);
  view_phi   := !view_phi   -. 0.005 *. (float_of_int dv.OgamlMath.Vector2i.y);
  view_phi   := min (max !view_phi (-.lim)) lim;
  Mouse.set_relative_position window center

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
         z = -. 0.15 *. (sin !view_theta)});
    if is_pressed LShift then
      position := Vector3f.(add
        !position
        {x = 0.; y = -0.15; z = 0.});
    if is_pressed Space then
      position := Vector3f.(add
        !position
        {x = 0.; y = 0.15; z = 0.})
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
      | A -> msaa := (not !msaa)
      | P -> Image.save (Window.screenshot window) "screenshot.png"
      | _ -> ()
    )
    | _ -> ()
  end; event_loop ()
  |None -> ()


(* Main loop *)
let rec main_loop () =
  if Window.is_open window then begin
    Window.clear ~color:(Some (`RGB Color.RGB.white)) window;
    display ();
    Window.display window;
    (* We only capture the mouse and listen to the keyboard when focused *)
    if Window.has_focus window then (
      update_camera () ;
      handle_keys ()
    ) ;
    event_loop ();
    Clock.tick fps_clock;
    main_loop ()
  end


(* Start *)
let () =
  Printf.printf "Rendering %i vertices\n%!" (VertexArray.length cube);
  Clock.restart fps_clock;
  main_loop ();
  Printf.printf "Avg FPS: %f\n%!" (Clock.tps fps_clock);
  Window.destroy window
