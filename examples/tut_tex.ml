open OgamlGraphics
open OgamlMath

let settings = OgamlCore.ContextSettings.create ()

let window =
  Window.create ~width:800 ~height:600 ~settings ~title:"Texture Tutorial" ()

let vertex_shader_source = "
  in vec3 position;

  in vec2 uv;

  out vec2 frag_uv;

  void main() {

    gl_Position = vec4(position, 1.0);

    frag_uv = uv;

  }
"

let fragment_shader_source = "

  uniform sampler2D my_texture;

  in vec2 frag_uv;

  out vec4 out_color;

  void main() {

    out_color = vec4(texture(my_texture, frag_uv).rgb, 1.0);

  }
"

let program =
  Program.from_source_pp
    (module Window)
    ~context:window
    ~vertex_source:(`String vertex_shader_source)
    ~fragment_source:(`String fragment_shader_source) ()

let vertex1 =
  VertexArray.SimpleVertex.create
    ~position:Vector3f.({x = -0.75; y = 0.75; z = 0.0})
    ~uv:Vector2f.({x = 0.; y = 1.}) ()

let vertex2 =
  VertexArray.SimpleVertex.create
    ~position:Vector3f.({x = 0.75; y = 0.75; z = 0.0})
    ~uv:Vector2f.({x = 1.; y = 1.}) ()

let vertex3 =
  VertexArray.SimpleVertex.create
    ~position:Vector3f.({x = -0.75; y = -0.75; z = 0.0})
    ~uv:Vector2f.({x = 0.; y = 0.}) ()

let vertex4 =
  VertexArray.SimpleVertex.create
    ~position:Vector3f.({x = 0.75; y = -0.75; z = 0.0})
    ~uv:Vector2f.({x = 1.; y = 0.}) ()

let vertex_source = VertexArray.VertexSource.(
    empty ~size:4 ()
    << vertex1
    << vertex2
    << vertex3
    << vertex4
)

let vertices = VertexArray.static (module Window) window vertex_source

let texture = Texture.Texture2D.create (module Window) window (`File "examples/mario-block.bmp")

let uniform =
  Uniform.empty
  |> Uniform.texture2D "my_texture" texture

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
    VertexArray.draw (module Window) ~target:window ~vertices ~program ~uniform ~mode:DrawMode.TriangleStrip ();
    Window.display window;
    event_loop ();
    main_loop ();
  end

let () = main_loop ()
