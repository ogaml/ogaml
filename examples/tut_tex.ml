open OgamlGraphics
open OgamlMath
 
let window = Window.create ~width:800 ~height:600 

let () = GL.Pervasives.color 1.0 1.0 1.0 1.0

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
    (Window.state window)
    ~vertex_source:(`String vertex_shader_source)
    ~fragment_source:(`String fragment_shader_source)

let vertex1 = 
  VertexArray.Vertex.create 
    ~position:Vector3f.({x = -0.75; y = 0.75; z = 0.0}) 
    ~texcoord:(0.,1.) ()

let vertex2 = 
  VertexArray.Vertex.create
    ~position:Vector3f.({x = 0.75; y = 0.75; z = 0.0}) 
    ~texcoord:(1.,1.) ()

let vertex3 =
  VertexArray.Vertex.create
    ~position:Vector3f.({x = -0.75; y = -0.75; z = 0.0}) 
    ~texcoord:(0.,0.) ()

let vertex4 =
  VertexArray.Vertex.create
    ~position:Vector3f.({x = 0.75; y = -0.75; z = 0.0}) 
    ~texcoord:(1.,0.) ()

let vertex_source = VertexArray.Source.(
    empty ~position:"position" ~texcoord:"uv" ~size:4 ()
    << vertex1 
    << vertex2 
    << vertex3
    << vertex4
)

let vertices = VertexArray.static vertex_source DrawMode.TriangleStrip

let texture = Texture.Texture2D.create (Window.state window) (`File "examples/mario-block.bmp")

let parameters = DrawParameter.make ()

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
    Window.clear window ~color:true ~stencil:false ~depth:false;
    Window.draw ~window ~vertices ~program ~parameters ~uniform;
    Window.display window;
    event_loop ();
    main_loop ();
  end

let () = main_loop ()




