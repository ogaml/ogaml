open OgamlMath

type shape_vals = {
  mutable points    : Vector2f.t list ;
  mutable bisectors : Vector2f.t list ;
  mutable position  : Vector2f.t ;
  mutable origin    : Vector2f.t ;
  mutable rotation  : float ;
  mutable scale     : Vector2f.t ;
  mutable thickness : float ;
  mutable color     : Color.t ;
  mutable out_color : Color.t
}

type t = {
  mutable vertices : VertexArray.static VertexArray.t ;
  mutable outline  : (VertexArray.static VertexArray.t) option ;
  shape_vals       : shape_vals
}

(* Utility *)

(* foreachtwo : ('a -> 'b -> 'b -> 'a) -> 'a -> 'b list -> 'a *)
let rec foreachtwo f res = function
  | a :: b :: r -> foreachtwo f (f res a b) (b :: r)
  | _ -> res

(* foralltwo : ('a -> 'b -> 'b -> 'a) -> 'a -> 'b list -> 'a *)
let foralltwo f res =
  let rec aux first res = function
    | a :: b :: r -> aux first (f res a b) (b :: r)
    | a :: []     -> f res a first
    | []          -> res
  in
  function
  | [] -> res
  | first :: r -> aux first res (first :: r)


(* Producing bisectors *)
let bisectors_of_points points =
  (* First compute the normals *)
  let v = Vector3f.({ x = 0. ; y = 0. ; z = 1. }) in
  foralltwo
    (fun l a b ->
      let a3 = Vector3f.lift a
      and b3 = Vector3f.lift b in
      let ab = Vector3f.direction a3 b3 in
      (Vector3f.project (Vector3f.cross ab v)) :: l
    )
    []
    points
  (* Then we can finally get the bisectors *)
  |>
  foralltwo
    (fun l n1 n2 ->
      Vector2f.(
        prop 0.5 (add n1 n2)
      ) :: l
    )
    []
  (* The last thing is to put all that in order *)
  (* |> List.rev
  |> function
     | []     -> []
     | a :: r -> a :: (List.rev r) *)

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

(* Computes the actual points of a shape from its vals *)
let actual_points vals =
  List.map
    (apply_transformations
      vals.position vals.origin vals.rotation vals.scale)
    vals.points
  |> List.map Vector3f.lift

(* Computes the actual bisectors *)
let actual_bisectors vals =
  (* Apply the scale TODO *)
  (* List.map
    (fun vec ->
      Vector2f.({
        x = vec.x *. vals.scale.x /. vals.scale.y ;
        y = vec.y *. vals.scale.y /. vals.scale.x
      })
    ) *)
    vals.bisectors
  (* |> List.map Vector2f.normalize *)
  (* Apply the rotation *)
  |>
  List.map
    (fun vec ->
      let theta = vals.rotation *. Constants.pi /. 180. in
      Vector2f.({
        Vector3f.x = cos(theta) *. vec.x -. sin(theta) *. vec.y ;
        Vector3f.y = sin(theta) *. vec.x +. cos(theta) *. vec.y ;
        Vector3f.z = 0.
      })
    )

(* Turns actual points to a VertexArray for the shape *)
let vertices_of_points points color =
  List.map (fun v ->
    VertexArray.Vertex.create ~position:v ~color ()
  ) points
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
                                ~size:(3 * ((List.length vertices) - 1)) ())
      vertices
    |> VertexArray.static

(* Takes the actual points and their bisectors and computes the outline *)
let outline_of_points points bisectors thickness color =
  match points with
  | [] -> None
  | head :: _ ->
    if thickness = 0. then None
    (* We'll deal with thickness of 1 later *)
    (* In the last case, we just draw a rectangle for each line *)
    else begin
      let tovtx v =
        VertexArray.Vertex.create ~position:v ~color ()
      in
      (* Then we compute the outline *)
      foralltwo
        (
          let open Vector3f in
          let v = { x = 0. ; y = 0. ; z = 1. } in
          fun source (a,ba) (b,bb) ->
            (* Normal to the direction (a b) *)
            let n =
              let u = direction a b in
              cross u v
            in
            (* The local thickness *)
            let xa = thickness /. (dot n ba)
            and xb = thickness /. (dot n bb) in
            (* The vector for this thickness *)
            let vxa = prop xa ba
            and vxb = prop xb bb in
            (* Finally the vertices *)
            let v1 = tovtx (add a vxa)
            and v2 = tovtx (add b vxb)
            and v3 = tovtx b
            and v4 = tovtx a in
            VertexArray.Source.(
              (* Fist triangle *)
              source << v1
                     << v2
                     << v3
                     (* Then the second *)
                     << v3
                     << v4
                     << v1
            )
        )
        VertexArray.Source.(empty ~position:"position"
                                  ~color:"color"
                                  ~size:(6 * (List.length points)) ())
        (* It shouldn't raise Invalid_argument *)
        (List.combine points bisectors)
      |> fun x -> Some (VertexArray.static x)
    end

let create_polygon ~points
                   ~color
                   ?origin:(origin=Vector2f.zero)
                   ?position:(position=Vector2i.zero)
                   ?scale:(scale=Vector2f.({ x = 1. ; y = 1.}))
                   ?rotation:(rotation=0.)
                   ?thickness:(thickness=0.)
                   ?border_color:(out_color=(`RGB Color.RGB.black)) () =
  let points = List.map Vector2f.from_int points in
  let bisectors = bisectors_of_points points in
  let position = Vector2f.from_int position in
  let vals = {
    points    = points ;
    bisectors = bisectors ;
    position  = position ;
    origin    = origin ;
    rotation  = rotation ;
    scale     = scale ;
    thickness = thickness ;
    color     = color ;
    out_color = out_color
  }
  in
  let points    = actual_points vals in
  let bisectors = actual_bisectors vals in
  {
    vertices   = vertices_of_points points color ;
    outline    = outline_of_points points bisectors thickness out_color ;
    shape_vals = vals
  }

let create_rectangle ~position
                     ~size
                     ~color
                     ?origin:(origin=Vector2f.zero)
                     ?scale:(scale=Vector2f.({ x = 1. ; y = 1.}))
                     ?rotation:(rotation=0.)
                     ?thickness:(thickness=0.)
                     ?border_color:(border_color=(`RGB Color.RGB.black)) () =
  let w = Vector2i.({ x = size.x ; y = 0 })
  and h = Vector2i.({ x = 0 ; y = size.y }) in
  create_polygon ~points:Vector2i.([zero ; w ; size ; h])
                 ~color
                 ~origin
                 ~position
                 ~scale
                 ~rotation
                 ~thickness
                 ~border_color ()

let create_regular ~position
                   ~radius
                   ~amount
                   ~color
                   ?origin:(origin=Vector2f.zero)
                   ?scale:(scale=Vector2f.({ x = 1. ; y = 1.}))
                   ?rotation:(rotation=0.)
                   ?thickness:(thickness=0.)
                   ?border_color:(border_color=(`RGB Color.RGB.black)) () =
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
  create_polygon ~points:(List.map Vector2f.floor (List.rev (vertices 0 [])))
                 ~color
                 ~origin
                 ~position
                 ~scale
                 ~rotation
                 ~thickness
                 ~border_color ()

(* Applies the modifications to shape_vals *)
let update shape =
  let color     = shape.shape_vals.color
  and thickness = shape.shape_vals.thickness in
  let points    = actual_points shape.shape_vals in
  let bisectors = actual_bisectors shape.shape_vals in
  let out_color = shape.shape_vals.out_color in
  shape.vertices <- vertices_of_points points color ;
  shape.outline  <- outline_of_points points bisectors thickness out_color

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

let set_border_color shape color =
  shape.shape_vals.out_color <- color ;
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

let get_border_color shape = shape.shape_vals.out_color

let get_vertex_array shape = shape.vertices

let get_outline shape = shape.outline
