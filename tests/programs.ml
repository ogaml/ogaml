open OgamlGraphics

let () =
  Printf.printf "Beginning program tests...\n%!"

let settings = OgamlCore.ContextSettings.create ()

let window = Window.create ~width:100 ~height:100 ~settings ~title:"" ()

let context = Window.context window

let test_program0 () =
  let (a,b) = Context.version context in
  Printf.printf "GL version : %i.%i\n" a b;
  Printf.printf "GLSL version : %i\n%!" (Context.glsl_version context)

let test_program1 () =
  let prog = Program.from_source_list
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
    ] ()
  in
  ignore prog

let test_program2 () =
  let prog = Program.from_source_list
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

             }")] ()
  in
  ignore prog

let () =
  test_program0 ();
  test_program1 ();
  Printf.printf "\tTest 1 passed\n%!";
  test_program2 ();
  Printf.printf "\tTest 2 passed\n%!";
