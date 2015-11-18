type t = VertexArray.static VertexArray.t

let create_rectangle ~x ~y ~width ~height ~color () =
  (* TODO Stop ignoring the arguments *)
  let vertex1 =
    VertexArray.Vertex.create
      ~position:Vector3f.({x = -0.75 ; y = -0.75 ; z = 0.0}) ()
  in
  let vertex2 =
    VertexArray.Vertex.create
      ~position:(Vector3f.({x = 0.75 ; y = -0.75 ; z = 0.0})) ()
  in
  let vertex3 =
    VertexArray.Vertex.create
      ~position:Vector3f.({x = 0.75 ; y = 0.75 ; z = 0.0}) ()
  in
  let vertex4 =
    VertexArray.Vertex.create
      ~position:Vector3f.({x = -0.75 ; y = 0.75 ; z = 0.0}) ()
  in
  let vertex_source = VertexArray.Source.(
      empty ~position:"position" ~size:6 ()
      << vertex1
      << vertex2
      << vertex3
      << vertex3
      << vertex4
      << vertex1
  )
  in
  VertexArray.static vertex_source

let get_vertex_array shape = shape
