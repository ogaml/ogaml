open OgamlMath

type shape_vals = {
  points    : Vector2f.t list ;
  mutable position  : Vector2f.t ;
  mutable origin    : Vector2f.t ;
  mutable rotation  : float ;
  mutable scale     : Vector2f.t ;
  mutable thickness : float ;
  mutable color     : Color.t ;
  mutable out_color : Color.t
}

type t = {
  mutable vertices : VertexArray.Vertex.t list option ;
  mutable outline  : VertexArray.Vertex.t list option ;
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


(* Applies transformations to a point *)
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
  Vector2f.({
    x = cos(rotation) *. (point.x-.position.x) -.
        sin(rotation) *. (point.y-.position.y) +. position.x ;
    y = sin(rotation) *. (point.x-.position.x) +.
        cos(rotation) *. (point.y-.position.y) +. position.y
  })

(* Computes the actual points of a shape from its vals *)
let actual_points vals =
  List.map
    (apply_transformations
      vals.position vals.origin vals.rotation vals.scale)
    vals.points
  |> List.map Vector3f.lift

(* Turns actual points to a vertices for the shape *)
let vertices_of_points points color =
  List.map (fun v ->
    VertexArray.Vertex.create ~position:v ~color ()
  ) points
  |> function
  | [] -> []
  | edge :: vertices ->
    foreachtwo
      (fun l a b -> edge :: a :: b :: l) [] vertices

(* Producing bisectors out of actual points *)
let bisectors_of_points points =
  (* First compute the normals *)
  let v = Vector3f.({ x = 0. ; y = 0. ; z = 1. }) in
  foralltwo
    (fun l a b ->
      let open Vector3f in
      let ab = direction a b in
      (cross ab v) :: l
    )
    []
    points
  (* Then we can finally get the bisectors *)
  |>
  foralltwo
    (fun l n1 n2 ->
      Vector3f.(
        prop 0.5 (add n1 n2)
      ) :: l
    )
    []
  (* The last thing is to put all that in order *)
  (* |> List.rev
  |> function
     | []     -> []
     | a :: r -> a :: (List.rev r) *)

(* Takes the actual points and computes the outline *)
let outline_of_points points thickness color =
  match points with
  | [] -> None
  | head :: _ ->
    if thickness = 0. then None
    (* We'll deal with thickness of 1 later *)
    (* In the last case, we just draw a rectangle for each line *)
    else begin
      (* First the bisectors *)
      let bisectors = bisectors_of_points points in
      (* Then the outline *)
      let tovtx v =
        VertexArray.Vertex.create ~position:v ~color ()
      in
      (* Then we compute the outline *)
      foralltwo
        (
          let open Vector3f in
          let v = { x = 0. ; y = 0. ; z = 1. } in
          fun lst (a,ba) (b,bb) ->
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
            v1 :: v2 :: v3 :: v3 :: v4 :: v1 :: lst
        )
        []
        (* It shouldn't raise Invalid_argument *)
        (List.combine points bisectors)
      |> fun x -> Some (x)
    end

let compute_vertices poly = 
  match poly.vertices with
  | None -> 
    let points = actual_points poly.shape_vals in
    let vertices = vertices_of_points points poly.shape_vals.color in
    let outline = outline_of_points points poly.shape_vals.thickness poly.shape_vals.out_color in
    poly.vertices <- Some vertices;
    poly.outline  <- outline;
    (vertices, outline)
  | Some v -> (v, poly.outline)

let create_polygon ~points
                   ~color
                   ?origin:(origin=Vector2f.zero)
                   ?position:(position=Vector2f.zero)
                   ?scale:(scale=Vector2f.({ x = 1. ; y = 1.}))
                   ?rotation:(rotation=0.)
                   ?thickness:(thickness=0.)
                   ?border_color:(out_color=(`RGB Color.RGB.black)) () =
  let vals = {
   points    = points ;
   position  = position ;
   origin    = origin ;
   rotation  = rotation ;
   scale     = scale ;
   thickness = thickness ;
   color     = color ;
   out_color = out_color
  }
  in
  {
   vertices   = None;
   outline    = None;
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
  let w = Vector2f.({ x = size.x ; y = 0. })
  and h = Vector2f.({ x = 0. ; y = size.y }) in
  create_polygon ~points:Vector2f.([zero ; w ; size ; h])
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
    if k >= amount then l
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
  create_polygon ~points:(List.rev (vertices 0 []))
               ~color
               ~origin
               ~position
               ~scale
               ~rotation
               ~thickness
               ~border_color ()

let create_line ~thickness
                ~color
                ?top:(top=Vector2f.zero)
                ~tip
                ?position:(position=Vector2f.zero)
                ?origin:(origin=Vector2f.zero)
                ?rotation:(rotation=0.) () =
  let a3 = Vector3f.lift top 
  and b3 = Vector3f.lift tip in
  let n = Vector3f.(
    let u = direction a3 b3 in
    let v = { x = 0. ; y = 0. ; z = 1. } in
    let n = cross u v in
    project n
  ) in
  let points = Vector2f.(
    let delta = prop (thickness /. 2.) n in
    [
      add top delta ;
      add tip delta ;
      sub tip delta ;
      sub top delta
    ]
  ) in
  create_polygon ~points
               ~color
               ~origin
               ~position
               ~rotation
                 ()

(* Applies the modifications to shape_vals *)
let update shape =
  shape.vertices <- None;
  shape.outline  <- None

let set_position shape position =
  shape.shape_vals.position <- position ;
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
    <- Vector2f.(add delta shape.shape_vals.position) ;
  update shape

let rotate shape delta =
  mod_float (shape.shape_vals.rotation +. delta) (2. *. Constants.pi)
  |> set_rotation shape

let scale shape scale =
  let mul v w =
    Vector2f.({
      x = v.x *. w.x ;
      y = v.y *. w.y
    })
  in
  set_scale shape (mul scale shape.shape_vals.scale)

let position shape = shape.shape_vals.position

let origin shape = shape.shape_vals.origin

let rotation shape = shape.shape_vals.rotation

let get_scale shape = shape.shape_vals.scale

let thickness shape = shape.shape_vals.thickness

let color shape = shape.shape_vals.color

let border_color shape = shape.shape_vals.out_color

let draw (type s) (module M : RenderTarget.T with type t = s)
         ?parameters:(parameters = DrawParameter.make
         ~depth_test:DrawParameter.DepthTest.None
         ~blend_mode:DrawParameter.BlendMode.alpha ())
         ~target ~shape () =
  let state = M.state target in
  let program = State.LL.shape_drawing state in
  let size = M.size target in
  let uniform =
    Uniform.empty
    |> Uniform.vector2f "size" (Vector2f.from_int size)
  in
  let vertices = 
    let src = VertexArray.Source.empty
      ~position:"position"
      ~color:"color"
      ~size:8 ()
    in
    let vtcs, outline = compute_vertices shape in
    List.iter (VertexArray.Source.add src) vtcs;
    begin match outline with
    | None -> ()
    | Some vtcs -> List.iter (VertexArray.Source.add src) vtcs
    end;
    VertexArray.static (module M) target src
  in
  VertexArray.draw (module M)
        ~target
        ~vertices
        ~program
        ~parameters
        ~uniform
        ~mode:DrawMode.Triangles () 

let map_to_source shape f src = 
  let vtcs, outline = compute_vertices shape in
  List.iter (fun v -> VertexArray.Source.add src (f v)) vtcs;
  begin match outline with
  | None -> ()
  | Some vtcs -> List.iter (fun v -> VertexArray.Source.add src (f v)) vtcs
  end

let to_source shape src = 
  let vtcs, outline = compute_vertices shape in
  List.iter (VertexArray.Source.add src) vtcs;
  begin match outline with
  | None -> ()
  | Some vtcs -> List.iter (VertexArray.Source.add src) vtcs
  end

let map_to_custom_source shape f src = 
  let vtcs, outline = compute_vertices shape in
  List.iter (fun v -> VertexMap.Source.add src (f v)) vtcs;
  begin match outline with
  | None -> ()
  | Some vtcs -> List.iter (fun v -> VertexMap.Source.add src (f v)) vtcs
  end


