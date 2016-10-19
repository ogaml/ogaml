open OgamlGraphics
open OgamlMath

let () =
  Printf.printf "Beginning vertex array tests...\n%!"

let settings = OgamlCore.ContextSettings.create ()

let window = Window.create ~width:100 ~height:100 ~settings ~title:"" ()

let context = Window.context window

let parameters = DrawParameter.make ()

let mode = DrawMode.Triangles

let uniform = Uniform.empty

let program = Program.from_source_list
    (module Window) 
    ~context:window
    ~vertex_source:[
      (130, `String "#version 130

             in vec3 position;

             void main () {

                gl_Position = vec4(position.x, position.y, position.z, 1.0);

             }");
      (110, `String "#version 110

             attribute vec3 position;

             void main () {

                gl_Position = vec4(position.x, position.y, position.z, 1.0);

             }");
      (150, `String "#version 150

             in vec3 position;

             void main () {

                gl_Position = vec4(position.x, position.y, position.z, 1.0);

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
    ] ()

let test_vao1 () =
  let vsource = VertexArray.(VertexSource.(
    empty ~size:4 ()
    << SimpleVertex.create ~position:Vector3f.unit_z ()
    << SimpleVertex.create ~position:Vector3f.unit_y ()
    << SimpleVertex.create ~position:Vector3f.unit_x ()
  )) in
  let vao = VertexArray.dynamic (module Window) window vsource in
  assert (VertexArray.length vao = 3)

let test_vao2 () =
  let vsource = VertexArray.(VertexSource.(
    empty ~size:4 ()
    << SimpleVertex.create ~position:Vector3f.unit_z ()
    << SimpleVertex.create ~position:Vector3f.unit_y ()
    << SimpleVertex.create ~position:Vector3f.unit_x ()
    << SimpleVertex.create ~position:Vector3f.unit_x ()
    << SimpleVertex.create ~position:Vector3f.unit_x ()
    << SimpleVertex.create ~position:Vector3f.unit_x ()
  )) in
  let vao = VertexArray.dynamic (module Window) window vsource in
  assert (VertexArray.length vao = 6)

let test_vao3 () =
  try
    let vsource = VertexArray.(VertexSource.(
      empty ~size:4 ()
      << SimpleVertex.create ~position:Vector3f.unit_z ()
      << SimpleVertex.create ()
    )) in
    ignore vsource;
    assert false
  with
    |VertexArray.VertexSource.Uninitialized_field _ -> ()

let test_vao4 () =
  try
    let vsource = VertexArray.(VertexSource.(
      empty ~size:4 ()
      << SimpleVertex.create ~position:Vector3f.unit_z ()
      << SimpleVertex.create ~position:Vector3f.unit_z ~color:(`RGB Color.RGB.white) ()
    )) in
    ignore vsource
  with
    |VertexArray.VertexSource.Uninitialized_field _ -> assert false

let test_vao5 () =
  let vsource = VertexArray.(VertexSource.(
    empty ~size:4 ()
    << SimpleVertex.create ~position:Vector3f.unit_z ~uv:Vector2f.({x = 1.; y = 1.}) ~normal:Vector3f.unit_z ~color:(`RGB Color.RGB.white) ()
    << SimpleVertex.create ~position:Vector3f.unit_y ~uv:Vector2f.({x = 1.; y = 1.}) ~normal:Vector3f.unit_z ~color:(`RGB Color.RGB.white) ()
    << SimpleVertex.create ~position:Vector3f.unit_x ~uv:Vector2f.({x = 1.; y = 1.}) ~normal:Vector3f.unit_z ~color:(`RGB Color.RGB.white) ()
    << SimpleVertex.create ~position:Vector3f.unit_x ~uv:Vector2f.({x = 1.; y = 1.}) ~normal:Vector3f.unit_z ~color:(`RGB Color.RGB.white) ()
  )) in
  let vao = VertexArray.dynamic (module Window) window vsource in
  assert (VertexArray.length vao = 4)

let test_vao6 () =
  let vsource = VertexArray.(VertexSource.(
    empty ~size:4 ()
    << SimpleVertex.create ~position:Vector3f.unit_z ()
    << SimpleVertex.create ~position:Vector3f.unit_y ()
    << SimpleVertex.create ~position:Vector3f.unit_x ()
  )) in
  let vao = VertexArray.dynamic (module Window) window vsource in
  VertexArray.draw (module Window) ~target:window 
                   ~vertices:vao ~program ~parameters ~mode ~uniform ()

let test_vao7 () =
  let vsource = VertexArray.(VertexSource.(
    empty ~size:4 ()
    << SimpleVertex.create ~normal:Vector3f.unit_z ()
    << SimpleVertex.create ~normal:Vector3f.unit_y ()
    << SimpleVertex.create ~normal:Vector3f.unit_x ()
  )) in
  let vao = VertexArray.dynamic (module Window) window vsource in
  try
    VertexArray.draw (module Window) ~target:window ~vertices:vao ~program ~parameters ~mode ~uniform ();
    assert false
  with
    VertexArray.Missing_attribute _ -> ()


let test_vao8 () =
  let vsource = VertexArray.(VertexSource.(
    empty ~size:4 ()
    << SimpleVertex.create ~position:Vector3f.unit_z ~color:(`RGB Color.RGB.white) ()
    << SimpleVertex.create ~position:Vector3f.unit_y ~color:(`RGB Color.RGB.white) ()
    << SimpleVertex.create ~position:Vector3f.unit_x ~color:(`RGB Color.RGB.white) ()
  )) in
  let vao = VertexArray.dynamic (module Window) window vsource in
  try
    VertexArray.draw (module Window) ~target:window ~vertices:vao ~program ~parameters ~mode ~uniform ();
  with
    VertexArray.Invalid_attribute _ -> assert false

let test_vao9 () = 
  let vsource = VertexArray.(VertexSource.(
    empty ~size:4 ()
    << SimpleVertex.create ~normal:Vector3f.unit_z ()
    << SimpleVertex.create ~normal:Vector3f.unit_y ()
    << SimpleVertex.create ~normal:Vector3f.unit_x ()
  )) in
  let vsource = 
    VertexArray.VertexSource.map vsource 
      (fun vtx -> 
        VertexArray.SimpleVertex.create 
          ~position:(VertexArray.Vertex.Attribute.get vtx VertexArray.SimpleVertex.normal)
          ()
      )
  in
  let vao = VertexArray.dynamic (module Window) window vsource in
  try
    VertexArray.draw (module Window) ~target:window ~vertices:vao ~program ~parameters ~mode ~uniform ();
  with
    VertexArray.Missing_attribute _ -> ()

let test_vao10 () = 
  let vsource = VertexArray.(VertexSource.(
    empty ~size:4 ()
    << SimpleVertex.create ~position:Vector3f.unit_z ~normal:Vector3f.unit_y ()
    << SimpleVertex.create ~position:Vector3f.unit_z ~normal:Vector3f.unit_y ~color:(`RGB Color.RGB.black) ()
  )) in
  VertexArray.VertexSource.iter vsource
    (fun vtx ->
      let open VertexArray in
      assert (Vertex.Attribute.get vtx SimpleVertex.position = Vector3f.unit_z);
      assert (Vertex.Attribute.get vtx SimpleVertex.normal   = Vector3f.unit_y);
      begin try
        Vertex.Attribute.get vtx SimpleVertex.color |> ignore;
        assert false
      with
        Vertex.Unbound_attribute _ -> ()
      end
    )

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
  test_vao9 ();
  Printf.printf "\tTest 9 passed\n%!";
  test_vao10 ();
  Printf.printf "\tTest 10 passed\n%!";
