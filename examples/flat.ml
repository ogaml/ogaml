open OgamlGraphics
open OgamlMath

let settings = ContextSettings.create ~color:(`RGB Color.RGB.white) ()
let window = Window.create ~width:800 ~height:600 ~settings

(* Setting the clear color to white *)
let () = GL.Pervasives.color 1.0 1.0 1.0 1.0

(* Things you don't understand yet *)
let vertex_shader_source = "
  in vec3 position;

  void main() {

    gl_Position = vec4(position, 1.0);

  }
"

let fragment_shader_source = "
  out vec4 out_color;

  void main() {

    out_color = vec4(1.0, 0.0, 0.0, 1.0);

  }
"

let program =
  Program.from_source_pp
    (Window.state window)
    ~vertex_source:(`String vertex_shader_source)
    ~fragment_source:(`String fragment_shader_source)

let parameters = DrawParameter.make ()

let uniform = Uniform.empty

(* Drawing a rectangle *)
let draw_rectangle w h x y color =
  let vertex1 =
    VertexArray.Vertex.create
      ~position:Vector3f.({x = -0.75 ; y = -0.75 ; z = 0.}) ()
  in
  let vertex2 =
    VertexArray.Vertex.create
      ~position:(Vector3f.({x = 0.75 ; y = -0.75 ; z = 0.})) ()
  in
  let vertex3 =
    VertexArray.Vertex.create
      ~position:Vector3f.({x = 0.75 ; y = 0.75 ; z = 0.}) ()
  in
  let vertex4 =
    VertexArray.Vertex.create
      ~position:Vector3f.({x = -0.75 ; y = 0.75 ; z = 0.})
  in
  let vertex_source = VertexArray.Source.(
      empty ~position:"position" ~size:3 ()
      << vertex1
      << vertex2
      << vertex3
      (* << vertex4 *)
  )
  in
  let vertices = VertexArray.static vertex_source in
  Window.draw ~window
              ~vertices
              ~program
              ~parameters
              ~uniform
              ~mode:DrawMode.Triangles ()

let draw () =
  draw_rectangle 400 300 200 150 (`RGB Color.RGB.blue)

let rec handle_events () =
  match Window.poll_event window with
  | Some e -> OgamlCore.Event.(
      match e with
      | Closed -> Window.close window
      | _      -> ()
    ) ; handle_events ()
  | None -> ()

let rec each_frame () =
  if Window.is_open window then begin
    Window.clear window ;
    draw () ;
    Window.display window ;
    handle_events () ;
    each_frame ()
  end

let () = each_frame ()
