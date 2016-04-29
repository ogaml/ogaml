open OgamlGraphics
open OgamlMath

let () =
  Printf.printf "Beginning vertex array tests...\n%!"

let settings = OgamlCore.ContextSettings.create ()

let window = Window.create ~width:100 ~height:100 ~settings ~title:"" ()

let state = Window.state window

let parameters = DrawParameter.make ()

let mode = DrawMode.Triangles

let uniform = Uniform.empty

let program = Program.from_source_list
    state
    ~vertex_source:[
      (130, `String "#version 130

             in vec3 pos;

             void main () {

                gl_Position = vec4(pos.x, pos.y, pos.z, 1.0);

             }");
      (110, `String "#version 110

             attribute vec3 pos;

             void main () {

                gl_Position = vec4(pos.x, pos.y, pos.z, 1.0);

             }");
      (150, `String "#version 130

             in vec3 pos;

             void main () {

                gl_Position = vec4(pos.x, pos.y, pos.z, 1.0);

             }");
    ]
    ~fragment_source:[
      (130, `String "#version 130

             out vec4 color;

             void main () {

               color = vec4(1.0, 1.0, 1.0, 1.0);

             }");
      (110, `String "#version 110

             void main () {

               gl_FragColor = vec4(1.0, 1.0, 1.0, 1.0);

             }");
      (150, `String "#version 150

             out vec4 color;

             void main () {

               color = vec4(1.0, 1.0, 1.0, 1.0);

             }");
    ]

let test_vao1 () =
  let vsource = VertexArray.(Source.(
    empty ~position:"pos" ~size:4 ()
    << Vertex.create ~position:Vector3f.unit_z ()
    << Vertex.create ~position:Vector3f.unit_y ()
    << Vertex.create ~position:Vector3f.unit_x ()
  )) in
  let vao = VertexArray.dynamic vsource in
  assert (VertexArray.length vao = 3)

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
  assert (VertexArray.length vao = 6)

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
    ignore vsource
  with
    |VertexArray.Invalid_vertex _ -> assert false

let test_vao5 () =
  let vsource = VertexArray.(Source.(
    empty ~position:"pos" ~color:"col" ~texcoord:"uv" ~normal:"normal" ~size:4 ()
    << Vertex.create ~position:Vector3f.unit_z ~texcoord:Vector2f.({x = 1.; y = 1.}) ~normal:Vector3f.unit_z ~color:(`RGB Color.RGB.white) ()
    << Vertex.create ~position:Vector3f.unit_y ~texcoord:Vector2f.({x = 1.; y = 1.}) ~normal:Vector3f.unit_z ~color:(`RGB Color.RGB.white) ()
    << Vertex.create ~position:Vector3f.unit_x ~texcoord:Vector2f.({x = 1.; y = 1.}) ~normal:Vector3f.unit_z ~color:(`RGB Color.RGB.white) ()
    << Vertex.create ~position:Vector3f.unit_x ~texcoord:Vector2f.({x = 1.; y = 1.}) ~normal:Vector3f.unit_z ~color:(`RGB Color.RGB.white) ()
  )) in
  let vao = VertexArray.dynamic vsource in
  assert (VertexArray.length vao = 4)

let test_vao6 () =
  let vsource = VertexArray.(Source.(
    empty ~position:"pos" ~size:4 ()
    << Vertex.create ~position:Vector3f.unit_z ()
    << Vertex.create ~position:Vector3f.unit_y ()
    << Vertex.create ~position:Vector3f.unit_x ()
  )) in
  let vao = VertexArray.dynamic vsource in
  VertexArray.draw ~window ~vertices:vao ~program ~parameters ~mode ~uniform ()

let test_vao7 () =
  let vsource = VertexArray.(Source.(
    empty ~position:"foo" ~size:4 ()
    << Vertex.create ~position:Vector3f.unit_z ()
    << Vertex.create ~position:Vector3f.unit_y ()
    << Vertex.create ~position:Vector3f.unit_x ()
  )) in
  let vao = VertexArray.dynamic vsource in
  try
    VertexArray.draw ~window ~vertices:vao ~program ~parameters ~mode ~uniform ();
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
    VertexArray.draw ~window ~vertices:vao ~program ~parameters ~mode ~uniform ();
  with
    VertexArray.Invalid_attribute _ -> assert false

let () =
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
