open OgamlGL

let context = 
  OgamlWindow.Window.create ~width:100 ~height:100

let opengl_state = 
  State.create ()

let test_program1 () = 
  let prog = Program.from_source_list opengl_state
    ~vertex_source:[
      (130, "#version 130
              
             uniform vec2 param1;

             uniform float param2;

             in vec2 param3;

             void main () {

                gl_Position = vec4(param1.x, param1.y, param2, param3.x);

             }");
      (150, "#version 150
              
             uniform vec2 param1;

             uniform float param2;

             void main () {

                gl_Position = vec4(param1.x, param1.y, param2, 0.);

             }")
    ]
    ~fragment_source:[
      (130, "#version 130

             out vec4 color;
      
             void main () {

               color = vec4(1.0, 1.0, 1.0, 1.0);

             }");
      (150, "#version 150

             out vec4 color;
      
             void main () {

               color = vec4(1.0, 1.0, 1.0, 1.0);

             }")
    ]
  in
  let string_of_type = function
    | Enum.GlslType.Float -> "float"
    | Enum.GlslType.Float2 -> "vec2"
    | Enum.GlslType.Float4 -> "vec4"
    | _ -> assert false
  in
  Program.iter_attributes prog (fun att ->
    Printf.printf "Program attribute : %s, type : %s, location : %i\n%!"
      (Program.Attribute.name att) 
      (string_of_type (Program.Attribute.kind att))
      (Program.Attribute.location att)
  );
  Program.iter_uniforms prog (fun att ->
    Printf.printf "Program uniform : %s, type : %s, location : %i\n%!"
      (Program.Uniform.name att) 
      (string_of_type (Program.Uniform.kind att))
      (Program.Uniform.location att)
  )

let () = 
  test_program1 ()
