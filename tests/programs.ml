open OgamlGraphics
open OgamlUtils

let () =
  Log.info Log.stdout "Beginning program tests..."

let settings = OgamlCore.ContextSettings.create ()

let window = 
  Window.create ~width:100 ~height:100 ~settings ~title:"" ()
  |> Utils.handle_window_creation

let context = Window.context window

let test_program0 () =
  let (a,b) = Context.version context in
  Log.info Log.stdout "GL version : %i.%i\n" a b;
  Log.info Log.stdout "GLSL version : %i" (Context.glsl_version context)

let test_program1 () =
  Program.from_source_list
    (module Window) 
    ~context:window
    ~vertex_source:[
      (110, (`String "#version 110

             uniform vec2 param1;

             uniform float param2;

             attribute vec2 param3;

             void main () {

                gl_Position = vec4(param1.x, param1.y, param2, param3.x);

             }"));
      (150, (`String "#version 150

             uniform vec2 param1;

             uniform float param2;

             in vec2 param3;

             void main () {

                gl_Position = vec4(param1.x, param1.y, param2, param3.x);

             }"))
    ]
    ~fragment_source:[
      (110, (`String "#version 110

             void main () {

               gl_FragColor = vec4(1.0, 1.0, 1.0, 1.0);

             }"));
      (150, (`String "#version 150

             out vec4 color;

             void main () {

               color = vec4(1.0, 1.0, 1.0, 1.0);

             }"))
    ]
  |> Utils.handle_program_creation
  |> ignore

let test_program2 () =
  Program.from_source_list
    (module Window)
    ~context:window
    ~vertex_source: [
      (130, `String
             "#version 130

             uniform vec2 param1;

             uniform float param2;

             in vec2 param3;

             void main () {

                gl_Position = vec4(param1.x, param1.y, param2, param3.x);

             }");
      (150, `String
             "#version 150

             uniform vec2 param1;

             uniform float param2;

             in vec2 param3;

             void main () {

                gl_Position = vec4(param1.x, param1.y, param2, param3.x);

             }");
      (110, `String
             "#version 110

             uniform vec2 param1;

             uniform float param2;

             attribute vec2 param3;

             void main () {

                gl_Position = vec4(param1.x, param1.y, param2, param3.x);

             }");

      ]
    ~fragment_source: [
      (130, `String
             "#version 130

             out vec4 color;

             void main () {

               color = vec4(1.0, 1.0, 1.0, 1.0);

             }");
      (110, `String
             "#version 110

             void main () {

               gl_FragColor = vec4(1.0, 1.0, 1.0, 1.0);

             }");
      (150, `String
             "#version 150

             out vec4 color;

             void main () {

               color = vec4(1.0, 1.0, 1.0, 1.0);

             }")] 
  |> Utils.handle_program_creation
  |> ignore

let () =
  test_program0 ();
  test_program1 ();
  Log.info Log.stdout "Test 1 passed";
  test_program2 ();
  Log.info Log.stdout "Test 2 passed";
