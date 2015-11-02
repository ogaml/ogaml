open OgamlWindow
open OgamlMath
open OgamlGL
open OgamlGL.Buffers


let win = Window.create ~width:800 ~height:600

let () =
  Printf.printf "OpenGL version : %s\n%!" (Config.version ());
  Printf.printf "OpenGL Shading Language (GLSL) version : %s\n%!" (Config.glsl_version ());
  Config.enable [Config.DepthTest; Config.CullFace];
  Config.set_culling Config.Back;
  Config.set_front_face Config.CW;
  Config.set_clear_color (`RGB Color.RGB.white)

let initial_time = ref 0.

let frame_count = ref 0




(* Polygons *)
let cube =
  let vertices =
    Poly.cube
      Vector3f.({x = -0.5; y = -0.5; z = -0.5})
      Vector3f.({x = 1.; y = 1.; z = 1.})
  in
  let colors = Array.make (36*3) 0. in
  for i = 0 to 5 do
    for j = 0 to 5 do
      colors.(i*18+j*3+0) <- float_of_int (i/3);
      colors.(i*18+j*3+1) <- float_of_int ((i+1) mod 2);
      colors.(i*18+j*3+2) <- float_of_int (((max i 1) mod 5) mod 2);
    done;
  done;
  Array.concat [vertices; colors]

let axis =
  let vertices = Poly.axis 0. 30. in
  let colors =
    [|
      1.0; 0.0; 0.0;
      1.0; 0.0; 0.0;
      0.0; 1.0; 0.0;
      0.0; 1.0; 0.0;
      0.0; 0.0; 1.0;
      0.0; 0.0; 1.0
    |]
  in
  Array.concat [vertices; colors]


(* VBO creation *)
let vbo_cube = VBO.build (Data.of_float_array cube)

let vbo_axis = VBO.build (Data.of_float_array axis)

(* Compile GL program *)
let vertex_shader   = Shader.create
  ~version:(Shader.recommended_version ())
  (`File "src/test/default_shader.vert")
  Shader.Vertex

let fragment_shader = Shader.create
  ~version:(Shader.recommended_version ())
  (`File "src/test/default_shader.frag")
  Shader.Fragment

let program = Program.build
  ~shaders:[vertex_shader; fragment_shader]
  ~attributes:["position"; "in_color"]
  ~uniforms:["MVPMatrix"]


(* VAO creation *)
let vao_cube = VAO.create ()

let () =
  VAO.bind (Some vao_cube);
  VBO.bind (Some vbo_cube);
  (* Position attribute *)
  VAO.enable_attrib (Program.attribute program "position");
  VAO.set_attrib
    ~attribute:(Program.attribute program "position")
    ~size:3
    ~kind:VAO.Float
    ~offset:0 ();
  (* color attribute *)
  VAO.enable_attrib (Program.attribute program "in_color");
  VAO.set_attrib
    ~attribute:(Program.attribute program "in_color")
    ~size:3
    ~kind:VAO.Float
    ~offset:((Array.length cube / 6) * 12) ();
  VBO.bind None;
  VAO.bind None


let vao_axis = VAO.create ()

let () =
  VAO.bind (Some vao_axis);
  VBO.bind (Some vbo_axis);
  (* Position attribute *)
  VAO.enable_attrib (Program.attribute program "position");
  VAO.set_attrib
    ~attribute:(Program.attribute program "position")
    ~size:3
    ~kind:VAO.Float
    ~offset:0 ();
  (* color attribute *)
  VAO.enable_attrib (Program.attribute program "in_color");
  VAO.set_attrib
    ~attribute:(Program.attribute program "in_color")
    ~size:3
    ~kind:VAO.Float
    ~offset:(18 * 4) ();
  VAO.bind None;
  VBO.bind None


(* Create matrices *)
let proj = Matrix3D.perspective ~near:0.01 ~far:1000. ~width:800. ~height:600. ~fov:(90. *. 3.141592 /. 180.)
(* let proj = Matrix3D.orthographic ~near:(-20.) ~far:(20.) ~left:(-2.) ~right:(2.) ~top:(1.5) ~bottom:(-1.5) *)

let view = Matrix3D.look_at
  ~from:Vector3f.({x = 1.; y = 0.6; z = 1.4})
  ~at:Vector3f.({x = 0.; y = 0.; z = 0.})
  ~up:Vector3f.unit_y

let position = ref Vector3f.({x = 1.; y = 0.6; z = 1.4})

let rot_angle = ref 0.

let view_theta = ref 0.

let view_phi = ref 0.


(* Display *)
let display () =
  Program.use (Some program);
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
  (* Display the cube *)
  Uniform.set (Uniform.Matrix3D mvp)
              (Program.uniform program "MVPMatrix");
  VAO.bind (Some vao_cube);
  VAO.draw VAO.Triangles 0 (Array.length cube / 6);
  (* Display the axis *)
  Uniform.set (Uniform.Matrix3D vp)
              (Program.uniform program "MVPMatrix");
  VAO.bind (Some vao_axis);
  VAO.draw VAO.Lines 0 6;
  VAO.bind None;
  Program.use None


(* Camera *)
let begin_log = Unix.gettimeofday ()

let centerx, centery =
  let (x,y) = Window.size win in
  (x / 2, y / 2)

let () =
  Mouse.set_relative_position win (centerx, centery)

let rec update_camera () =
  let x,y = Mouse.relative_position win in
  let dx, dy = x - centerx, y - centery in
  let lim = Constants.pi /. 2. -. 0.1 in
  view_theta := !view_theta -. 0.005 *. (float_of_int dx);
  view_phi   := !view_phi   -. 0.005 *. (float_of_int dy);
  view_phi   := min (max !view_phi (-.lim)) lim;
  if (Unix.gettimeofday () -. begin_log >= 1. && Unix.gettimeofday () -. begin_log <= 1.1) then
    Printf.printf "Deltas : %i,%i\nAngles : %f,%f\nLimit : %f\nPosition : %i,%i\n%!"
      dx dy !view_theta !view_phi lim centerx centery;
  Mouse.set_relative_position win (centerx, centery)

(* Event loop *)
let rec event_loop () =
  match Window.poll_event win with
  |Some e -> begin
    match e with
    |Event.Closed ->
      Window.close win
    |Event.KeyPressed k -> Keycode.(
      match k.Event.KeyEvent.key with
      | Escape -> Window.close win
      | Q when k.Event.KeyEvent.control -> Window.close win
      | Z | Up ->
          position := Vector3f.(add
            !position
            {x = -. 0.15 *. (sin !view_theta);
             y = 0.;
             z = -. 0.15 *. (cos !view_theta)})
      | S | Down ->
          position := Vector3f.(add
            !position
            {x = 0.15 *. (sin !view_theta);
             y = 0.;
             z = 0.15 *. (cos !view_theta)})
      | Q | Left ->
          position := Vector3f.(add
            !position
            {x = -. 0.15 *. (cos !view_theta);
             y = 0.;
             z = 0.15 *. (sin !view_theta)})
      | D | Right ->
          position := Vector3f.(add
            !position
            {x = 0.15 *. (cos !view_theta);
             y = 0.;
             z = -. 0.15 *. (sin !view_theta)})
      | _ -> ()
    )
    | _ -> ()
  end; event_loop ()
  |None -> ()


(* Main loop *)
let rec main_loop () =
  if Window.is_open win then begin
    Window.clear win ~color:true ~depth:true ~stencil:false;
    display ();
    Window.display win;
    update_camera ();
    event_loop ();
    incr frame_count;
    main_loop ()
  end


(* Start *)
let () =
  Printf.printf "Rendering %i vertices\n%!" (Array.length cube / 2);
  initial_time := Unix.gettimeofday ();
  main_loop ();
  Printf.printf "Avg FPS : %f\n%!" (float_of_int (!frame_count) /. (Unix.gettimeofday () -. !initial_time));
  Window.destroy win
