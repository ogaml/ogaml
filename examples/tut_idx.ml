
open OgamlGraphics
open OgamlMath

let settings = OgamlCore.ContextSettings.create ()

let window =
  Window.create ~width:800 ~height:600 ~settings ~title:"Indexing Tutorial" ()

let vertex_shader_source = "

  uniform mat4 MVP;

  in vec3 position;

  void main() {

    gl_Position = MVP * vec4(position, 1.0);

  }
"

let fragment_shader_source = "
  uniform vec4 color;

  out vec4 out_color;

  void main() {

    out_color = color;

  }
"

let log = OgamlUtils.Log.create ()

let program =
  Program.from_source_pp
    (module Window)
    ~log
    ~context:window
    ~vertex_source:(`String vertex_shader_source)
    ~fragment_source:(`String fragment_shader_source) ()

let vertex0 =
  VertexArray.SimpleVertex.create
    ~position:Vector3f.({x = -0.5; y = -0.5; z = -0.5}) ()

let vertex1 =
  VertexArray.SimpleVertex.create
    ~position:(Vector3f.({x = -0.5; y = -0.5; z = 0.5})) ()

let vertex2 =
  VertexArray.SimpleVertex.create
    ~position:(Vector3f.({x = -0.5; y =  0.5; z = -0.5})) ()

let vertex3 =
  VertexArray.SimpleVertex.create
    ~position:(Vector3f.({x = -0.5; y =  0.5; z = 0.5})) ()

let vertex4 =
  VertexArray.SimpleVertex.create
    ~position:(Vector3f.({x =  0.5; y = -0.5; z = -0.5})) ()

let vertex5 =
  VertexArray.SimpleVertex.create
    ~position:(Vector3f.({x =  0.5; y = -0.5; z = 0.5})) ()

let vertex6 =
  VertexArray.SimpleVertex.create
    ~position:(Vector3f.({x =  0.5; y =  0.5; z = -0.5})) ()

let vertex7 =
  VertexArray.SimpleVertex.create
    ~position:(Vector3f.({x =  0.5; y =  0.5; z = 0.5})) ()

let vertex_source = VertexArray.VertexSource.(
    empty ~size:8 ()
    << vertex0 << vertex1 << vertex2
    << vertex3 << vertex4 << vertex5
    << vertex6 << vertex7
)

let index_source = IndexArray.Source.(
    empty 36
    << 0 << 1 << 5 << 0 << 5 << 4
    << 3 << 2 << 6 << 3 << 6 << 7
    << 1 << 3 << 7 << 1 << 7 << 5
    << 5 << 7 << 6 << 5 << 6 << 4
    << 0 << 2 << 3 << 0 << 3 << 1
    << 4 << 6 << 2 << 4 << 2 << 0
)

let vertices = VertexArray.static (module Window) window vertex_source

let indices  = IndexArray.static (module Window) window index_source

(* Displaying *)
let proj = Matrix3D.perspective ~near:0.01 ~far:1000. ~width:800. ~height:600. ~fov:(90. *. 3.141592 /. 180.)

let view = Matrix3D.look_at ~from:Vector3f.({x = 1.5; y = 0.5; z = 0.9}) ~up:Vector3f.unit_y ~at:Vector3f.zero

let matrixVP = Matrix3D.product proj view

let rot_angle = ref 0.

let display () =
  let t = Unix.gettimeofday () in
  rot_angle := !rot_angle +. (abs_float (cos t /. 10.)) /. 3.;
  let rot_vector = Vector3f.({x = (cos t); y = (sin t); z = (cos t) *. (sin t)}) in
  let model = Matrix3D.rotation rot_vector !rot_angle in
  let matrixMVP = Matrix3D.product matrixVP model in
  (* Cube *)
  let parameters = DrawParameter.(make ~culling:CullingMode.CullCounterClockwise ()) in
  let uniform = Uniform.(empty |> matrix3D "MVP" matrixMVP |> color "color" (`RGB Color.RGB.red)) in
  VertexArray.draw (module Window) ~target:window ~indices ~vertices ~program ~parameters ~uniform ~mode:DrawMode.Triangles ();
  (* Edges *)
  let parameters = DrawParameter.(make ~polygon:PolygonMode.DrawLines ()) in
  let uniform = Uniform.(empty |> matrix3D "MVP" matrixMVP |> color "color" (`RGB Color.RGB.black)) in
  VertexArray.draw (module Window) ~target:window ~indices ~vertices ~program ~parameters ~uniform ~mode:DrawMode.Triangles ()

let rec event_loop () =
  match Window.poll_event window with
  |Some e -> OgamlCore.Event.(
    match e with
    |Closed -> Window.close window
    | _     -> event_loop ()
  )
  |None -> ()

let rec main_loop () =
  if Window.is_open window then begin
    Window.clear ~color:(Some (`RGB Color.RGB.white)) window;
    display ();
    Window.display window;
    event_loop ();
    main_loop ();
  end

let () = main_loop ()
