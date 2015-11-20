open OgamlMath

type t = VertexArray.static VertexArray.t

let create_rectangle ~x ~y ~width ~height ~color ?origin ?rotation:(rot=0.) () =
  (* If the origin is not specified, we choose the center of the rectangle *)
  let ori = match origin with
    | Some ori -> ori
    | None     -> let f = float_of_int in
                  (f x) +. (f width) /. 2. , (f y) +. (f height) /. 2.
  in
  (* Angle in rad *)
  let theta = rot *. Constants.pi /. 180. in
  (* Creates a vector from ints *)
  let mk_point x y =
    let px = float_of_int x
    and py = float_of_int y in
    let (ox,oy) = ori in
    Vector3f.lift Vector2f.({
      x = cos(theta) *. (px-.ox) -. sin(theta) *. (py-.oy) +. ox ;
      y = sin(theta) *. (px-.ox) +. cos(theta) *. (py-.oy) +. oy
    })
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
