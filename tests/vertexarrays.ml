open OgamlGraphics
open OgamlMath

let window = Window.create ~width:100 ~height:100

let state = Window.state window

let prog = Program.from_source_list 
    state
    ~vertex_source:[
      (130, "#version 130
              
             in vec3 pos;

             void main () {

                gl_Position = vec4(pos.x, pos.y, pos.z, 1.0);

             }");
      (150, "#version 150
              
             in vec3 pos;

             void main () {

                gl_Position = vec4(pos.x, pos.y, pos.z, 1.0); 

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

let test_vao1 () =
  let vsource = VertexArray.(Source.(
    empty ~position:"pos" ~size:4 ()
    << Vertex.create ~position:Vector3f.unit_z ()
    << Vertex.create ~position:Vector3f.unit_y ()
    << Vertex.create ~position:Vector3f.unit_x ()
  )) in
  let vao = VertexArray.dynamic vsource in
  assert (VertexArray.length vao = 9)

let test_vao2 () = 
  let vsource = VertexArray.(Source.(
    empty ~position:"pos" ~size:4 ()
    << Vertex.create ~position:Vector3f.unit_z ()
    << Vertex.create ~position:Vector3f.unit_y ()
    << Vertex.create ~position:Vector3f.unit_x ()
    << Vertex.create ~position:Vector3f.unit_x ()
    << Vertex.create ~position:Vector3f.unit_x ()
    << Vertex.create ~position:Vector3f.unit_x ()
  )) in
  let vao = VertexArray.dynamic vsource in
  assert (VertexArray.length vao = 18)

let test_vao3 () = 
  try
    let vsource = VertexArray.(Source.(
      empty ~position:"pos" ~color:"col" ~size:4 ()
      << Vertex.create ~position:Vector3f.unit_z ()
    )) in
    ignore vsource;
    assert false
  with
    |VertexArray.Invalid_vertex _ -> ()

let test_vao4 () = 
  try
    let vsource = VertexArray.(Source.(
      empty ~position:"pos" ~size:4 ()
      << Vertex.create ~position:Vector3f.unit_z ~color:(`RGB Color.RGB.white) ()
    )) in
    ignore vsource;
    assert false
  with
    |VertexArray.Invalid_vertex _ -> ()

let test_vao5 () = 
  let vsource = VertexArray.(Source.(
    empty ~position:"pos" ~color:"col" ~texcoord:"uv" ~normal:"normal" ~size:4 ()
    << Vertex.create ~position:Vector3f.unit_z ~texcoord:(1.,1.) ~normal:Vector3f.unit_z ~color:(`RGB Color.RGB.white) ()
    << Vertex.create ~position:Vector3f.unit_y ~texcoord:(1.,1.) ~normal:Vector3f.unit_z ~color:(`RGB Color.RGB.white) ()
    << Vertex.create ~position:Vector3f.unit_x ~texcoord:(1.,1.) ~normal:Vector3f.unit_z ~color:(`RGB Color.RGB.white) ()
    << Vertex.create ~position:Vector3f.unit_x ~texcoord:(1.,1.) ~normal:Vector3f.unit_z ~color:(`RGB Color.RGB.white) ()
  )) in
  let vao = VertexArray.dynamic vsource in
  assert (VertexArray.length vao = 48)

let test_vao6 () = 
  let vsource = VertexArray.(Source.(
    empty ~position:"pos" ~size:4 ()
    << Vertex.create ~position:Vector3f.unit_z ()
    << Vertex.create ~position:Vector3f.unit_y ()
    << Vertex.create ~position:Vector3f.unit_x ()
  )) in
  let vao = VertexArray.dynamic vsource in
  VertexArray.draw state vao prog

let test_vao7 () = 
  let vsource = VertexArray.(Source.(
    empty ~position:"foo" ~size:4 ()
    << Vertex.create ~position:Vector3f.unit_z ()
    << Vertex.create ~position:Vector3f.unit_y ()
    << Vertex.create ~position:Vector3f.unit_x ()
  )) in
  let vao = VertexArray.dynamic vsource in
  try 
    VertexArray.draw state vao prog;
    assert false
  with
    VertexArray.Missing_attribute _ -> ()


let test_vao8 () = 
  let vsource = VertexArray.(Source.(
    empty ~position:"pos" ~color:"foo" ~size:4 ()
    << Vertex.create ~position:Vector3f.unit_z ~color:(`RGB Color.RGB.white) ()
    << Vertex.create ~position:Vector3f.unit_y ~color:(`RGB Color.RGB.white) ()
    << Vertex.create ~position:Vector3f.unit_x ~color:(`RGB Color.RGB.white) ()
  )) in
  let vao = VertexArray.dynamic vsource in
  try 
    VertexArray.draw state vao prog;
    assert false
  with
    VertexArray.Invalid_attribute _ -> ()

let () = 
  Printf.printf "Beginning vertex array tests...\n%!";
  test_vao1 ();
  Printf.printf "\tTest 1 passed\n%!";
  test_vao2 ();
  Printf.printf "\tTest 2 passed\n%!";
  test_vao3 ();
  Printf.printf "\tTest 3 passed\n%!";
  test_vao4 ();
  Printf.printf "\tTest 4 passed\n%!";
  test_vao5 ();
  Printf.printf "\tTest 5 passed\n%!";
  test_vao6 ();
  Printf.printf "\tTest 6 passed\n%!";
  test_vao7 ();
  Printf.printf "\tTest 7 passed\n%!";
  test_vao8 ();
  Printf.printf "\tTest 8 passed\n%!";








