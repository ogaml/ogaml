open OgamlMath
open OgamlUtils
open Result.Operators

type t = {
  vertices : VertexArray.SimpleVertex.T.s VertexArray.Source.t;
  mutable vao : VertexArray.t option;
}

let fold_pairs f acc l = 
  let rec aux first = function
    | [] -> acc
    | [e] -> f acc e first
    | e1::e2::tail -> f (aux first (e2::tail)) e1 e2
  in
  match l with
  | [] -> acc
  | [_] -> acc
  | e::_::_ -> aux e l

let fold_triplets f acc l = 
  let rec aux first second = function
    | [] -> acc
    | [e] -> f acc e first second
    | [e1; e2] -> f (aux first second [e2]) e1 e2 first
    | e1::e2::e3::tail -> f (aux first second (e2::e3::tail)) e1 e2 e3
  in
  match l with
  | [] -> acc
  | [_] -> acc
  | [_;_] -> acc
  | e1::e2::_::_ -> aux e1 e2 l

(* Computes the outline vertex corresponding to a vertex of the shape
 * given its two neighbours *)
let extrude point ngh1 ngh2 distance = 
  let d1, d2 = Vector2f.sub ngh1 point, Vector2f.sub ngh2 point in
  let nd1, nd2 = Vector2f.norm d1, Vector2f.norm d2 in
  let ud1, ud2 = 
    (if nd1 = 0. then Vector2f.zero
    else Vector2f.div nd1 d1 |> Result.assert_ok),
    (if nd2 = 0. then Vector2f.zero
    else Vector2f.div nd2 d2 |> Result.assert_ok)
  in
  let bisector = Vector2f.add ud1 ud2 in
  let length = Vector2f.norm bisector in
  if length = 0. then point
  else begin
    Vector2f.prop (distance /. length) bisector
    |> Vector2f.sub point
  end

let outline points thickness = 
  fold_triplets 
    (fun outline prev cur next -> extrude cur prev next thickness :: outline)
    [] points

let add_points source center points color = 
  let barycenter = 
    VertexArray.SimpleVertex.create ~position:(Vector3f.lift center) ~color ()
  in
  fold_pairs (fun _ cur next ->
    let pos_cur, pos_next = Vector3f.lift cur, Vector3f.lift next in
    let cur_vertex, next_vertex = 
      VertexArray.SimpleVertex.create ~position:pos_cur ~color (),
      VertexArray.SimpleVertex.create ~position:pos_next ~color ()
    in
    VertexArray.Source.add source barycenter |> Result.assert_ok;
    VertexArray.Source.add source cur_vertex |> Result.assert_ok;
    VertexArray.Source.add source next_vertex |> Result.assert_ok)
    () points

let create_polygon 
  ~points
  ~color
  ?(transform=Transform2D.create ())
  ?thickness
  ?(border_color=`RGB Color.RGB.black) () =
  let size = List.length points in
  let points = List.map (Transform2D.apply transform) points in
  let barycenter = 
    List.fold_left Vector2f.add Vector2f.zero points 
    |> Vector2f.div (float (max size 1))
    |> Result.assert_ok
  in
  let vertices = VertexArray.Source.empty ~size () in
  begin match thickness with
  | None -> ()
  | Some thickness ->
    add_points vertices barycenter (outline points thickness) border_color
  end;
  add_points vertices barycenter points color;
  {vertices; vao = None}

let create_rectangle 
  ~size
  ~color
  ?transform
  ?thickness
  ?border_color () =
  let w = Vector2f.({x = size.x; y = 0.})
  and h = Vector2f.({x = 0.; y = size.y}) in
  create_polygon ~points:Vector2f.([zero; w; size; h]) ~color ?transform
                 ?thickness ?border_color ()

let create_regular
  ~radius
  ~amount
  ~color
  ?transform
  ?thickness
  ?border_color () =
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
  create_polygon ~points:(vertices 0 []) ~color ?transform ?thickness
                 ?border_color ()

let create_segment
  ~thickness
  ~color
  ~segment
  ?transform () =
  let length = Vector2f.norm segment in
  let segment3D = Vector3f.lift segment in
  let points = 
    if length <> 0. then begin
      let open Vector3f in
      let normal = 
        let u = normalize segment3D |> Result.assert_ok in
        let v = { x = 0. ; y = 0. ; z = 1. } in
        let n = cross u v in
        project n
      in
      let open Vector2f in
      let delta = prop (thickness /. 2.) normal in
      [delta ; add segment delta ; sub segment delta ; prop (-1.) delta]
    end else 
     []
  in
  create_polygon ~points ~color ?transform ()

let draw (type s) (module M : RenderTarget.T with type t = s)
         ?parameters:(parameters = DrawParameter.make
         ~depth_test:DrawParameter.DepthTest.None
         ~blend_mode:DrawParameter.BlendMode.alpha ())
         ~target ~shape () =
  let context = M.context target in
  let program = Context.LL.shape_drawing context in
  let size = M.size target in
  let uniform =
    Uniform.empty
    |> Uniform.vector2f "size" (Vector2f.from_int size)
    |> Result.assert_ok
  in
  let vertices = 
    match shape.vao with
    | None ->
      let vbo = VertexArray.Buffer.(unpack (static (module M) target shape.vertices)) in
      let vao = VertexArray.create (module M) target [vbo] in
      shape.vao <- Some vao;
      vao
    | Some v -> v
  in
  VertexArray.draw (module M)
        ~target
        ~vertices
        ~program
        ~parameters
        ~uniform
        ~mode:DrawMode.Triangles ()
  |> Result.assert_ok

let source shape = 
  shape.vertices
