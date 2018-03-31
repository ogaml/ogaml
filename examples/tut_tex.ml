open OgamlGraphics
open OgamlMath
open OgamlUtils
open OgamlUtils.Result

let fail ?msg err = 
  Log.fatal Log.stdout "%s" err;
  begin match msg with
  | None -> ()
  | Some e -> Log.fatal Log.stderr "%s" e
  end;
  exit 2

let settings = OgamlCore.ContextSettings.create ()

let window =
  match Window.create ~width:800 ~height:600 ~settings ~title:"Texture Tutorial" () with
  | Ok win -> win
  | Error (`Context_initialization_error msg) -> 
    fail ~msg "Failed to create context"
  | Error (`Window_creation_error msg) -> 
    fail ~msg "Failed to create window"

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
  let res = Program.from_source_pp
    (module Window)
    ~context:window
    ~vertex_source:(`String vertex_shader_source)
    ~fragment_source:(`String fragment_shader_source) 
  in
  match res with
  | Ok prog -> prog
  | Error `Fragment_compilation_error msg -> fail ~msg "Failed to compile fragment shader"
  | Error `Vertex_compilation_error msg -> fail ~msg "Failed to compile vertex shader"
  | Error `Context_failure -> fail "GL context failure"
  | Error `Unsupported_GLSL_version -> fail "Unsupported GLSL version"
  | Error `Unsupported_GLSL_type -> fail "Unsupported GLSL type"
  | Error `Linking_failure -> fail "GLSL linking failure"

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

let vertex_source = VertexArray.Source.(
    Ok (empty ~size:4 ())
    <<< vertex1
    <<< vertex2
    <<< vertex3
    <<< vertex4
    |> assert_ok
)

let vbo = VertexArray.Buffer.static (module Window) window vertex_source

let vertices = 
  VertexArray.(create (module Window) window [Buffer.unpack vbo])

let texture = 
  let res = 
    Texture.Texture2D.create (module Window) window (`File "examples/mario-block.bmp")
  in
  match res with
  | Ok tex -> tex
  | Error `File_not_found s -> fail ("Cannot find texture " ^ s)
  | Error `Loading_error msg -> fail ~msg "Error loading texture"
  | Error `Texture_too_large -> fail "Texture too large"

let uniform =
  Uniform.empty
  |> Uniform.texture2D "my_texture" texture
  |> assert_ok

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
    Window.clear ~color:(Some (`RGB Color.RGB.white)) window |> assert_ok;
    VertexArray.draw (module Window) ~target:window ~vertices ~program ~uniform ~mode:DrawMode.TriangleStrip () 
    |> assert_ok;
    Window.display window;
    event_loop ();
    main_loop ();
  end

let () = main_loop ()
