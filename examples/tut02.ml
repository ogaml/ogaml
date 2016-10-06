(******************************************************************)
(*                                                                *)
(*                     Ogaml Tutorial n°02                        *)
(*                                                                *)
(*                       Hello Triangle                           *)
(*                                                                *)
(******************************************************************)

open OgamlGraphics
open OgamlMath
open OgamlUtils

(* Default context settings *)
let settings = OgamlCore.ContextSettings.create ()

(* Window creation with default settings *)
let window =
  Window.create ~width:800 ~height:600 ~settings ~title:"Tutorial n°02" ()

(* Source of GLSL vertex shader.
 * We do not add a version number as the program preprocessor will
 * add it for us. *)
let vertex_shader_source = "
  in vec3 position;

  void main() {

    gl_Position = vec4(position, 1.0);

  }
"

(* Source of GLSL fragment shader *)
let fragment_shader_source = "
  out vec4 out_color;

  void main() {

    out_color = vec4(1.0, 0.0, 0.0, 1.0);

  }
"

(* Compile the GLSL program from the sources.
 * from_source_pp includes a preprocessor that automatically preprends
 * the best version number to the GLSL sources.
 * We provide a standard log (as an optional parameter) to get compilation errors. *)
let program =
  Program.from_source_pp
    (module Window)
    ~context:window
    ~log:Log.stdout
    ~vertex_source:(`String vertex_shader_source)
    ~fragment_source:(`String fragment_shader_source) ()

(* Create three vertices *)
let vertex1 =
  VertexArray.Vertex.create
    ~position:Vector3f.({x = -0.75; y = -0.75; z = 0.0}) ()

let vertex2 =
  VertexArray.Vertex.create
    ~position:(Vector3f.({x = 0.; y = 0.75; z = 0.0})) ()

let vertex3 =
  VertexArray.Vertex.create
    ~position:Vector3f.({x = 0.75; y = -0.75; z = 0.0}) ()

(* Put the vertices in a vertex source *)
let vertex_source = VertexArray.Source.(
    empty ~position:"position" ~size:3 ()
    << vertex1
    << vertex2
    << vertex3
)

(* Compute and load the VAO (Vertex Array Object)
 * VAOs need a valid GL context to be properly initialized, which
 * is encapsulated inside any render target (window, render texture, ...).
 * Hence the use of first-class modules to provide some polymorphism. *)
let vertices = VertexArray.static (module Window) window vertex_source

(* Event-listening loop *)
let rec event_loop () =
  (* Polling the window *)
  match Window.poll_event window with
  |Some e -> OgamlCore.Event.(
    match e with
    (* Close the window if requested *)
    |Closed -> Window.close window
    | _     -> event_loop ()
  )
  |None -> ()

(* Main loop *)
let rec main_loop () =
  (* Run while the window is open *)
  if Window.is_open window then begin

    (* Clear the window using white.
     * We do not clear the depth/stencil buffers for such a simple app. *)
    Window.clear
      ~color:(Some (`RGB Color.RGB.white))
      window;

    (* Draw our triangle on the window.
     * The drawing function is polymorphic and the render target must
     * be specified using first-class modules. *)
    VertexArray.draw (module Window)
      ~target:window
      ~vertices
      ~program
      ~mode:DrawMode.Triangles ();

    (* Update the window renderbuffer *)
    Window.display window;
    (* Get events *)
    event_loop ();
    (* Recursion ! *)
    main_loop ();
  end

(* Let's launch the main loop and admire the result :o) *)
let () =
  Log.info Log.stdout "Hello triangle !";
  main_loop ()
