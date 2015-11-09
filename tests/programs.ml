open OgamlGraphics

let () =
  Printf.printf "Beginning program tests...\n%!"

let window = Window.create ~width:100 ~height:100

let state = Window.state window

let test_program0 () =
  let (a,b) = State.version state in
  Printf.printf "GL version : %i.%i\n" a b;
  Printf.printf "GLSL version : %i\n%!" (State.glsl_version state)

let test_program1 () = 
  let prog = Program.from_source_list
    state
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
  in
  Program.LL.iter_attributes prog (fun att ->
    assert ((Program.Attribute.name att) = "param3");
    assert ((Program.Attribute.kind att) = GL.Types.GlslType.Float2);
  );
  Program.LL.iter_uniforms prog (fun att ->
    let n = Program.Uniform.name att in
    let k = Program.Uniform.kind att in
    assert ((n = "param1" && k = GL.Types.GlslType.Float2) ||
            (n = "param2" && k = GL.Types.GlslType.Float));
  )

let test_program2 () = 
  let prog = Program.from_source_pp
    state
    ~vertex_source: (`String
             "uniform vec2 param1;

             uniform float param2;

             in vec2 param3;

             void main () {

                gl_Position = vec4(param1.x, param1.y, param2, param3.x);

             }")
    ~fragment_source: (`String 
             "out vec4 color;
      
             void main () {

               color = vec4(1.0, 1.0, 1.0, 1.0);

             }")
  in
  ignore prog

let () = 
  test_program0 ();
  test_program1 ();
  Printf.printf "\tTest 1 passed\n%!";
  test_program2 ();
  Printf.printf "\tTest 2 passed\n%!";
