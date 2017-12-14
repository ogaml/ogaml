open OgamlGraphics
open OgamlMath
open OgamlUtils

let () = 
  Log.info Log.stdout "Beginning vertex array tests..."

let settings = OgamlCore.ContextSettings.create ()

let window = 
  Window.create ~width:100 ~height:100 ~settings ~title:"" ()
  |> Utils.handle_window_creation

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
    ]
  |> Utils.handle_program_creation

let test_vao1 () =
  let vsource = VertexArray.(Source.(
    Ok (empty ~size:4 ())
    <<< SimpleVertex.create ~position:Vector3f.unit_z ()
    <<< SimpleVertex.create ~position:Vector3f.unit_y ()
    <<< SimpleVertex.create ~position:Vector3f.unit_x ())) 
    |> Utils.assert_ok 
  in
  let vbo = VertexArray.Buffer.dynamic (module Window) window vsource in
  let vao = VertexArray.(create (module Window) window [Buffer.unpack vbo]) in
  assert (VertexArray.length vao = 3)

let test_vao2 () =
  let vsource = VertexArray.(Source.(
    Ok (empty ~size:4 ())
    <<< SimpleVertex.create ~position:Vector3f.unit_z ()
    <<< SimpleVertex.create ~position:Vector3f.unit_y ()
    <<< SimpleVertex.create ~position:Vector3f.unit_x ()
    <<< SimpleVertex.create ~position:Vector3f.unit_x ()
    <<< SimpleVertex.create ~position:Vector3f.unit_x ()
    <<< SimpleVertex.create ~position:Vector3f.unit_x ())) 
    |> Utils.assert_ok
  in
  let vbo = VertexArray.Buffer.dynamic (module Window) window vsource in
  let vao = VertexArray.(create (module Window) window [Buffer.unpack vbo]) in
  assert (VertexArray.length vao = 6)

let test_vao3 () =
  let vsource = VertexArray.(Source.(
    Ok (empty ~size:4 ())
    <<< SimpleVertex.create ~position:Vector3f.unit_z ()
    <<< SimpleVertex.create ())) 
  in
  match vsource with
  | Ok _ -> assert false
  | Error (`Missing_attribute s) -> assert (s = "position")

let test_vao4 () =
  let vsource = VertexArray.(Source.(
    Ok (empty ~size:4 ())
    <<< SimpleVertex.create ~position:Vector3f.unit_z ()
    <<< SimpleVertex.create ~position:Vector3f.unit_z ~color:(`RGB Color.RGB.white) ())) 
  in
  match vsource with
  | Ok _ -> ()
  | Error _ -> assert false

let test_vao5 () =
  let vsource = VertexArray.(Source.(
    Ok (empty ~size:4 ())
    <<< SimpleVertex.create ~position:Vector3f.unit_z ~uv:Vector2f.({x = 1.; y = 1.}) ~normal:Vector3f.unit_z ~color:(`RGB Color.RGB.white) ()
    <<< SimpleVertex.create ~position:Vector3f.unit_y ~uv:Vector2f.({x = 1.; y = 1.}) ~normal:Vector3f.unit_z ~color:(`RGB Color.RGB.white) ()
    <<< SimpleVertex.create ~position:Vector3f.unit_x ~uv:Vector2f.({x = 1.; y = 1.}) ~normal:Vector3f.unit_z ~color:(`RGB Color.RGB.white) ()
    <<< SimpleVertex.create ~position:Vector3f.unit_x ~uv:Vector2f.({x = 1.; y = 1.}) ~normal:Vector3f.unit_z ~color:(`RGB Color.RGB.white) ())) 
    |> Utils.assert_ok
  in
  let vbo = VertexArray.Buffer.dynamic (module Window) window vsource in
  let vao = VertexArray.(create (module Window) window [Buffer.unpack vbo]) in
  assert (VertexArray.length vao = 4)

let test_vao6 () =
  let vsource = VertexArray.(Source.(
    Ok (empty ~size:4 ())
    <<< SimpleVertex.create ~position:Vector3f.unit_z ()
    <<< SimpleVertex.create ~position:Vector3f.unit_y ()
    <<< SimpleVertex.create ~position:Vector3f.unit_x ())) 
    |> Utils.assert_ok
  in
  let vbo = VertexArray.Buffer.dynamic (module Window) window vsource in
  let vao = VertexArray.(create (module Window) window [Buffer.unpack vbo]) in
  VertexArray.draw (module Window) ~target:window 
                   ~vertices:vao ~program ~parameters ~mode ~uniform ()
  |> Utils.assert_ok

let test_vao7 () =
  let vsource = VertexArray.(Source.(
    Ok (empty ~size:4 ())
    <<< SimpleVertex.create ~normal:Vector3f.unit_z ()
    <<< SimpleVertex.create ~normal:Vector3f.unit_y ()
    <<< SimpleVertex.create ~normal:Vector3f.unit_x ())) 
    |> Utils.assert_ok
  in
  let vbo = VertexArray.Buffer.dynamic (module Window) window vsource in
  let vao = VertexArray.(create (module Window) window [Buffer.unpack vbo]) in
  let res = 
    VertexArray.draw (module Window) ~target:window ~vertices:vao ~program ~parameters ~mode ~uniform ()
  in
  match res with
  | Error (`Missing_attribute s) -> assert (s = "position")
  | _ -> assert false


let test_vao8 () =
  let vsource = VertexArray.(Source.(
    Ok (empty ~size:4 ())
    <<< SimpleVertex.create ~position:Vector3f.unit_z ~color:(`RGB Color.RGB.white) ()
    <<< SimpleVertex.create ~position:Vector3f.unit_y ~color:(`RGB Color.RGB.white) ()
    <<< SimpleVertex.create ~position:Vector3f.unit_x ~color:(`RGB Color.RGB.white) ())) 
    |> Utils.assert_ok
  in
  let vbo = VertexArray.Buffer.dynamic (module Window) window vsource in
  let vao = VertexArray.(create (module Window) window [Buffer.unpack vbo]) in
  VertexArray.draw (module Window) ~target:window ~vertices:vao ~program ~parameters ~mode ~uniform ()
  |> Utils.assert_ok

let test_vao9 () = 
  let vsource = VertexArray.(Source.(
    Ok (empty ~size:4 ())
    <<< SimpleVertex.create ~normal:Vector3f.unit_z ()
    <<< SimpleVertex.create ~normal:Vector3f.unit_y ()
    <<< SimpleVertex.create ~normal:Vector3f.unit_x ())) 
    |> Utils.assert_ok
  in
  let vsource = 
    VertexArray.Source.map vsource 
      (fun vtx -> 
        let position = 
          VertexArray.Vertex.Attribute.get vtx VertexArray.SimpleVertex.normal
          |> Utils.assert_ok
        in
        VertexArray.SimpleVertex.create ~position ()
      )
    |> Utils.assert_ok
  in
  let vbo = VertexArray.Buffer.dynamic (module Window) window vsource in
  let vao = VertexArray.(create (module Window) window [Buffer.unpack vbo]) in
  VertexArray.draw (module Window) ~target:window ~vertices:vao ~program ~parameters ~mode ~uniform ()
  |> Utils.assert_ok

let test_vao10 () = 
  let vsource = VertexArray.(Source.(
    Ok (empty ~size:4 ())
    <<< SimpleVertex.create ~position:Vector3f.unit_z ~normal:Vector3f.unit_y ()
    <<< SimpleVertex.create ~position:Vector3f.unit_z ~normal:Vector3f.unit_y 
          ~color:(`RGB Color.RGB.black) ())) 
    |> Utils.assert_ok
  in
  VertexArray.Source.iter vsource
    (fun vtx ->
      let open VertexArray in
      assert (Vertex.Attribute.get vtx SimpleVertex.position = Ok Vector3f.unit_z);
      assert (Vertex.Attribute.get vtx SimpleVertex.normal   = Ok Vector3f.unit_y);
      assert (Vertex.Attribute.get vtx SimpleVertex.color = Error (`Unbound_attribute "color"))
    )

let () =
  test_vao1 ();
  Log.info Log.stdout "Test 1 passed";
  test_vao2 ();
  Log.info Log.stdout "Test 2 passed";
  test_vao3 ();
  Log.info Log.stdout "Test 3 passed";
  test_vao4 ();
  Log.info Log.stdout "Test 4 passed";
  test_vao5 ();
  Log.info Log.stdout "Test 5 passed";
  test_vao6 ();
  Log.info Log.stdout "Test 6 passed";
  test_vao7 ();
  Log.info Log.stdout "Test 7 passed";
  test_vao8 ();
  Log.info Log.stdout "Test 8 passed";
  test_vao9 ();
  Log.info Log.stdout "Test 9 passed";
  test_vao10 ();
  Log.info Log.stdout "Test 10 passed";
