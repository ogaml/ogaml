open OgamlMath

type shape_vals = {
  mutable points    : Vector2f.t list ;
  mutable position  : Vector2f.t ;
  mutable origin    : Vector2f.t ;
  mutable rotation  : float ;
  mutable scale     : Vector2f.t ;
  mutable thickness : int ;
  mutable color     : Color.t
}

type t = {
  mutable vertices : VertexArray.static VertexArray.t ;
  mutable outline  : VertexArray.static VertexArray.t ;
  shape_vals       : shape_vals
}

(* Applys transformations to a point *)
let apply_transformations position origin rotation scale point =
  (* Position offset *)
  Vector2f.({
    x = point.x +. position.x -. origin.x ;
    y = point.y +. position.y -. origin.y
  })
  |> fun point ->
  (* Scale *)
  Vector2f.({
    x = (point.x -. position.x) *. scale.x +. position.x ;
    y = (point.y -. position.y) *. scale.y +. position.y
  })
  |> fun point ->
  (* Rotation *)
  let theta = rotation *. Constants.pi /. 180. in
  Vector2f.({
    x = cos(theta) *. (point.x-.position.x) -.
        sin(theta) *. (point.y-.position.y) +. position.x ;
    y = sin(theta) *. (point.x-.position.x) +.
        cos(theta) *. (point.y-.position.y) +. position.y
  })

let rec foreachtwo f res = function
  | a :: b :: r -> foreachtwo f (f res a b) (b :: r)
  | _ -> res

(* Turns a shape_vals to a VertexArray *)
let vertices_of_vals vals =
  List.map
    (apply_transformations
      vals.position vals.origin vals.rotation vals.scale)
    vals.points
  |> List.map Vector3f.lift
  |> List.map (fun v ->
    VertexArray.Vertex.create ~position:v ~color:vals.color ()
  )
  |> function
  | [] -> VertexArray.static
            VertexArray.Source.(empty ~position:"position"
                                      ~color:"color"
                                      ~size:0 ())
  | edge :: vertices ->
    foreachtwo
      (fun source a b -> VertexArray.Source.(source << edge << a << b))
      VertexArray.Source.(empty ~position:"position"
                                ~color:"color"
                                ~size:(3 * (List.length vertices)) ())
      vertices
  |> VertexArray.static

let create_polygon ~points
                   ~color
                   ?origin:(origin=Vector2f.zero)
                   ?position:(position=Vector2i.zero)
                   ?scale:(scale=Vector2f.({ x = 1. ; y = 1.}))
                   ?rotation:(rotation=0.)
                   ?thickness:(thickness=0) () =
  let points = List.map Vector2f.from_int points in
  let position = Vector2f.from_int position in
  let vals = {
    points    = points ;
    position  = position ;
    origin    = origin ;
    rotation  = rotation ;
    scale     = scale ;
    thickness = thickness ;
    color     = color
  }
  in
  {
    vertices   = vertices_of_vals vals ;
    outline    = VertexArray.static
                   VertexArray.Source.(empty ~position:"position"
                                             ~color:"color"
                                             ~size:0 ()) ;
    shape_vals = vals
  }

let create_rectangle ~position
                     ~size
                     ~color
                     ?origin:(origin=Vector2f.zero)
                     ?scale:(scale=Vector2f.({ x = 1. ; y = 1.}))
                     ?rotation:(rotation=0.)
                     ?thickness:(thickness=0) () =
  let w = Vector2i.({ x = size.x ; y = 0 })
  and h = Vector2i.({ x = 0 ; y = size.y }) in
  create_polygon ~points:Vector2i.([zero ; w ; size ; h])
                 ~color
                 ~origin
                 ~position
                 ~scale
                 ~rotation
                 ~thickness ()

let create_regular ~position
                   ~radius
                   ~amount
                   ~color
                   ?origin:(origin=Vector2f.zero)
                   ?scale:(scale=Vector2f.({ x = 1. ; y = 1.}))
                   ?rotation:(rotation=0.)
                   ?thickness:(thickness=0) () =
  let rec vertices k l =
    if k > amount then l
    else begin
      let fk = float_of_int k in
      let fn = float_of_int amount in
      Vector2f.({
        x = radius *. (cos (2. *. fk *. Constants.pi /. fn)) +. radius ;
        y = radius *. (sin (2. *. fk *. Constants.pi /. fn)) +. radius
      }) :: l
      |> vertices (k+1)
    end
  in
  create_polygon ~points:(List.map Vector2f.floor (vertices 0 []))
                 ~color
                 ~origin
                 ~position
                 ~scale
                 ~rotation
                 ~thickness ()

(* Applies the modifications to shape_vals *)
let update shape =
  shape.vertices <- vertices_of_vals shape.shape_vals

let set_position shape position =
  shape.shape_vals.position <- Vector2f.from_int position ;
  update shape

let set_origin shape origin =
  shape.shape_vals.origin <- origin ;
  update shape

let set_rotation shape rotation =
  shape.shape_vals.rotation <- rotation ;
  update shape

let set_scale shape scale =
  shape.shape_vals.scale <- scale ;
  update shape

let set_thickness shape thickness =
  shape.shape_vals.thickness <- thickness ;
  update shape

let set_color shape color =
  shape.shape_vals.color <- color ;
  update shape

let translate shape delta =
  shape.shape_vals.position
    <- Vector2f.(add (from_int delta) shape.shape_vals.position) ;
  update shape

let rotate shape delta =
  mod_float (shape.shape_vals.rotation +. delta) 360.
  |> set_rotation shape

let scale shape scale =
  let mul v w =
    Vector2f.({
      x = v.x *. w.x ;
      y = v.y *. w.y
    })
  in
  set_scale shape (mul scale shape.shape_vals.scale)

let get_position shape = Vector2f.floor shape.shape_vals.position

let get_origin shape = shape.shape_vals.origin

let get_rotation shape = shape.shape_vals.rotation

let get_scale shape = shape.shape_vals.scale

let get_thickness shape = shape.shape_vals.thickness

let get_color shape = shape.shape_vals.color

let get_vertex_array shape = shape.vertices
