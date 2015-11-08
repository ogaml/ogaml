open OgamlGraphics

let () =
  Printf.printf "Beginning program tests...\n%!"

let window = Window.create ~width:100 ~height:100

let state = Window.state window

let test_program1 () = 
  let prog = Program.from_source_list
    state
    ~vertex_source:[
      (130, (`String "#version 130
              
             uniform vec2 param1;

             uniform float param2;

             in vec2 param3;

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
      (130, (`String "#version 130

             out vec4 color;
      
             void main () {

               color = vec4(1.0, 1.0, 1.0, 1.0);

             }"));
      (150, (`String "#version 150

             out vec4 color;
      
             void main () {

               color = vec4(1.0, 1.0, 1.0, 1.0);

             }"))
    ]
  in
  Program.iter_attributes prog (fun att ->
    assert ((Program.Attribute.name att) = "param3");
    assert ((Program.Attribute.kind att) = Enum.GlslType.Float2);
  );
  Program.iter_uniforms prog (fun att ->
    let n = Program.Uniform.name att in
    let k = Program.Uniform.kind att in
    assert ((n = "param1" && k = Enum.GlslType.Float2) ||
            (n = "param2" && k = Enum.GlslType.Float));
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
  test_program1 ();
  Printf.printf "\tTest 1 passed\n%!";
  test_program2 ();
  Printf.printf "\tTest 2 passed\n%!";
