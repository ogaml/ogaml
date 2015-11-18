open OgamlMath

type t = VertexArray.static VertexArray.t

let create_rectangle ~x ~y ~width ~height ~color () =
  let mk_point x y =
    Vector3f.from_int (Vector3i.lift { Vector2i.x = x ; Vector2i.y = y })
  in
  let vertex1 =
    VertexArray.Vertex.create
      ~position:(mk_point x y)
      ~color
      ()
  in
  let vertex2 =
    VertexArray.Vertex.create
      ~position:(mk_point (x+width) y)
      ~color
      ()
  in
  let vertex3 =
    VertexArray.Vertex.create
      ~position:(mk_point (x+width) (y+height))
      ~color
      ()
  in
  let vertex4 =
    VertexArray.Vertex.create
      ~position:(mk_point x (y+height))
      ~color
      ()
  in
  let vertex_source = VertexArray.Source.(
      empty ~position:"position" ~color:"color" ~size:6 ()
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
