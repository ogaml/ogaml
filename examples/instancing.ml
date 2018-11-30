open OgamlGraphics
open OgamlMath
open OgamlUtils
open Result.Operators

let fail ?msg err = 
  Log.fatal Log.stdout "%s" err;
  begin match msg with
  | None -> ()
  | Some e -> Log.fatal Log.stderr "%s" e
  end;
  exit 2

let settings = OgamlCore.ContextSettings.create ~msaa:8 ()

let window =
  match Window.create ~width:800 ~height:600 ~title:"Cube Instancing Example" ~settings () with
  | Ok win -> win
  | Error (`Context_initialization_error msg) -> 
    fail ~msg "Failed to create context"
  | Error (`Window_creation_error msg) -> 
    fail ~msg "Failed to create window"

let fps_clock = 
  Clock.create ()

(* Create the VBO for one cube *)
let cube_source =
  let src = VertexArray.Source.empty ~size:36 () in
  let cmod = Model.cube Vector3f.({x = -0.5; y = -0.5; z = -0.5}) Vector3f.({x = 1.; y = 1.; z = 1.}) in
  Model.source cmod ~vertex_source:src ()
  |> Result.assert_ok;
  src

let cube_vbo = 
  VertexArray.Buffer.static (module Window) window cube_source

(* Create instanced data for the position of each cube *)
module InstancedData = (val VertexArray.Vertex.make ())

let cube_position =
  let open VertexArray.Vertex in
  InstancedData.attribute "cube_position" ~divisor:1 AttributeType.vector3f
  |> Result.assert_ok

let () = InstancedData.seal () |> Result.assert_ok

(* Create the instanced VBO *)
let () = Random.self_init ()

let random_position () = 
  let v = Vector3f.({x = Random.float 400. -. 200.; 
                     y = Random.float 400. -. 200.; 
                     z = Random.float 400. -. 200.})
  in
  let vtx = InstancedData.create () |> Result.assert_ok in
  VertexArray.Vertex.Attribute.set vtx cube_position v;
  vtx
  
let instanced_source =
  let src = VertexArray.Source.empty ~size:36 () in
  for i = 0 to 10000 do
    VertexArray.Source.add src (random_position ())
    |> Result.assert_ok
  done;
  src

let instanced_vbo = 
  VertexArray.Buffer.static (module Window) window instanced_source

(* Create the VAO that contains both VBOs *)
let cube = 
  VertexArray.create (module Window) window 
    [VertexArray.Buffer.unpack cube_vbo;
     VertexArray.Buffer.unpack instanced_vbo]


let vertex_shader = "
  uniform mat4 MMatrix;

  uniform mat4 VPMatrix;

  in vec3 cube_position;

  in vec3 position;
  
  in vec3 normal;
  
  in vec4 color;
  
  out vec3 out_normal;
  
  out vec4 out_color;
  
  
  void main() {
  
    gl_Position = VPMatrix * (MMatrix * vec4(position, 1.0) + vec4(cube_position, 1.0));
  
    out_normal = normal;
  
    out_color = color;
  
  }
"

let normal_program =
  let res = Program.from_source_pp (module Window) ~context:window
    ~vertex_source:(`String vertex_shader)
    ~fragment_source:(`File (OgamlCore.OS.resources_dir ^ "examples/normals_shader.frag"))
  in
  match res with
  | Ok prog -> prog
  | Error `Fragment_compilation_error msg -> fail ~msg "Failed to compile fragment shader"
  | Error `Vertex_compilation_error msg -> fail ~msg "Failed to compile vertex shader"
  | Error `Context_failure -> fail "GL context failure"
  | Error `Unsupported_GLSL_version -> fail "Unsupported GLSL version"
  | Error `Unsupported_GLSL_type -> fail "Unsupported GLSL type"
  | Error `Linking_failure -> fail "GLSL linking failure"


(* Display computations *)
let proj = 
  Matrix3D.perspective ~near:0.01 ~far:1000. ~width:800. ~height:600. ~fov:(90. *. 3.141592 /. 180.)
  |> Result.assert_ok

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
  let model = Matrix3D.rotation rot_vector !rot_angle |> Result.assert_ok in
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
    Ok (Uniform.empty)
    >>= Uniform.matrix3D "MVPMatrix" mvp
    >>= Uniform.matrix3D "MMatrix"   model
    >>= Uniform.matrix3D "VPMatrix"  vp
    >>= Uniform.matrix3D "MVMatrix" mv
    >>= Uniform.matrix3D "VMatrix" view
    >>= Uniform.vector3f "Light.LightDir" Vector3f.{x = -4.; y = -2.; z = -3.}
    >>= Uniform.vector3f "Light.AmbientIntensity" Vector3f.{x = 0.3; y = 0.3; z = 0.3}
    >>= Uniform.float    "Light.SunIntensity" 1.6
    >>= Uniform.float    "Light.MaxIntensity" 1.9
    >>= Uniform.float    "Light.Gamma"  1.2
    |> Result.assert_ok
  in
  VertexArray.draw (module Window) ~target:window
                   ~vertices:cube ~uniform ~program:normal_program ~parameters ~mode:DrawMode.Triangles ()
  |> Result.assert_ok


(* Camera *)
let center = Vector2i.div 2 (Window.size window) |> Result.assert_ok

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
    Window.clear ~color:(Some (`RGB Color.RGB.white)) window |> Result.assert_ok;
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
