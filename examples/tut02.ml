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
open Utils

(* Default context settings *)
let settings = OgamlCore.ContextSettings.create ()

(* Window creation with default settings *)
let window =
  match Window.create ~width:800 ~height:600 ~settings ~title:"Tutorial n°02" () with
  | Ok win -> win
  | Error (`Context_initialization_error msg) -> 
    fail ~msg "Failed to create context"
  | Error (`Window_creation_error msg) -> 
    fail ~msg "Failed to create window"

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


(* Create three vertices *)
let vertex1 =
  VertexArray.SimpleVertex.create
    ~position:Vector3f.({x = -0.75; y = -0.75; z = 0.0}) ()

let vertex2 =
  VertexArray.SimpleVertex.create
    ~position:(Vector3f.({x = 0.; y = 0.75; z = 0.0})) ()

let vertex3 =
  VertexArray.SimpleVertex.create
    ~position:Vector3f.({x = 0.75; y = -0.75; z = 0.0}) ()

(* Put the vertices in a vertex source *)
let vertex_source = VertexArray.Source.(
    Ok (empty ~size:3 ())
    <<< vertex1
    <<< vertex2
    <<< vertex3
    |> assert_ok
)

(* Compute and load the VBO (Vertex Buffer Object)
 * VBOs need a valid GL context to be properly initialized, which
 * is encapsulated inside any render target (window, render texture, ...).
 * Hence the use of first-class modules to provide some polymorphism. *)
let vbo = VertexArray.Buffer.static (module Window) window vertex_source

(* Compute the VAO (Vertex Array Object)
 * A VAO encapsulates a collection of VBOs. Since VBOs can have different
 * types depending on the data they contain, we first need to unpack the
 * VBO to be able to construct a heterogeneous list of VBOs. *)
let unpacked_vbo = VertexArray.Buffer.unpack vbo 

let vertices = VertexArray.create (module Window) window [unpacked_vbo]

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
      window
    |> assert_ok;

    (* Draw our triangle on the window.
     * The drawing function is polymorphic and the render target must
     * be specified using first-class modules. *)
    VertexArray.draw (module Window)
      ~target:window
      ~vertices
      ~program
      ~mode:DrawMode.Triangles ()
    |> assert_ok;

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
