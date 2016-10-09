open OgamlMath

exception Sprite_error of string

type t = {
  texture : Texture.Texture2D.t ;
  subrect : OgamlMath.FloatRect.t ;
  mutable size    : Vector2f.t ;
  mutable position : Vector2f.t ;
  mutable origin   : Vector2f.t ;
  mutable rotation : float ;
  mutable scale    : Vector2f.t;
}

let error msg = raise (Sprite_error msg)

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

let get_vertices_aux size position origin rotation scale subrect =
  let (w,h) = Vector2f.(
    { x = size.x ; y = 0.     },
    { x = 0.     ; y = size.y }
  ) in
  let {FloatRect.x = uvx; y = uvy; width = uvw; height = uvh} = subrect in
  Vector2f.([ zero ; w ; h ; add w h ])
  |> List.map (apply_transformations position origin rotation scale)
  |> List.combine Vector2f.([
    { x = uvx        ; y = uvy        } ;
    { x = uvx +. uvw ; y = uvy        } ;
    { x = uvx        ; y = uvy +. uvh } ;
    { x = uvx +. uvw ; y = uvy +. uvh } ;
  ])
  |> List.map (fun (coord,pos) ->
    VertexArray.Vertex.create
     ~position:(Vector3f.lift pos)
     ~texcoord:coord ()
  )
  |> function
  | [ a ; b ; c ; d ] -> [a; b; c; c; b; d]
  | _ -> assert false

let get_vertices sprite = 
  get_vertices_aux
    sprite.size
    sprite.position
    sprite.origin
    sprite.rotation
    sprite.scale
    sprite.subrect

let create ~texture
           ?subrect
           ?origin:(origin=Vector2f.zero)
           ?position:(position=Vector2f.zero)
           ?scale:(scale=Vector2f.({ x = 1. ; y = 1.}))
           ?size
           ?rotation:(rotation=0.) () =
  let sizei = Texture.Texture2D.size texture in
  let base_size = Vector2f.from_int sizei in
  let size = 
    match size, subrect with
    | None  , None   -> base_size
    | None  , Some r -> Vector2f.from_int (IntRect.abs_size r)
    | Some s, _      -> s
  in
  let subrect = 
    match subrect with
    | None -> FloatRect.one
    | Some {IntRect.x; y; width; height} -> 
        let {Vector2f.x = sx; y = sy} = base_size in
        let fr = FloatRect.({x = float_of_int x /. sx;
                             y = float_of_int y /. sy;
                             width  = float_of_int width /. sx;
                             height = float_of_int height /. sy}) 
        in
        let open FloatRect in
        if fr.x >= 0. && fr.x <= 1. 
        && fr.y >= 0. && fr.y <= 1.
        && fr.x +. fr.width  >= 0. && fr.x +. fr.width  <= 1.
        && fr.y +. fr.height >= 0. && fr.x +. fr.height <= 1. then fr
        else raise (Sprite_error "invalid texture sub-rectangle")
  in
  {
    texture  = texture ;
    subrect  = subrect ;
    size     = size ;
    position = position ;
    origin   = origin ;
    rotation = rotation ;
    scale    = scale
  }

let map_to_source sprite f src = 
  List.iter (fun v -> VertexArray.Source.add src (f v)) (get_vertices sprite)

let to_source sprite src = 
  List.iter (VertexArray.Source.add src) (get_vertices sprite)

let map_to_custom_source sprite f src = 
  List.iter (fun v -> VertexMap.Source.add src (f v)) (get_vertices sprite)

(*type debug_times = {
  mutable size_get_t : float;
  mutable uniform_create_t : float;
  mutable source_alloc_t : float;
  mutable vertices_create_t : float;
  mutable vao_create_t : float;
  mutable draw_t : float;
}

let debug_t = {
  size_get_t = 0.;
  uniform_create_t = 0.;
  source_alloc_t = 0.;
  vertices_create_t = 0.;
  vao_create_t = 0.;
  draw_t = 0.
}

let tm = Unix.gettimeofday*)

let draw (type s) (module Target : RenderTarget.T with type t = s)
         ?parameters:(parameters = DrawParameter.make
         ~depth_test:DrawParameter.DepthTest.None
         ~blend_mode:DrawParameter.BlendMode.alpha ())
         ~target ~sprite () =
  let context = Target.context target in
  let program = Context.LL.sprite_drawing context in
(*   let t = tm () in *)
  let sizei = Target.size target in
(*   debug_t.size_get_t <- debug_t.size_get_t +. (tm () -. t); *)
  let size = Vector2f.from_int sizei in
(*   let t = tm () in *)
  let uniform =
    Uniform.empty
    |> Uniform.vector2f "size" size
    |> Uniform.texture2D "utexture" sprite.texture
  in
(*   debug_t.uniform_create_t <- debug_t.uniform_create_t +. (tm () -. t); *)
  let vertices = 
(*     let t = tm () in *)
    let src = VertexArray.Source.empty 
      ~position:"position"
      ~texcoord:"uv"
      ~size:6 ()
    in
(*     debug_t.source_alloc_t <- debug_t.source_alloc_t +. (tm () -. t); *)
(*     let t = tm () in *)
    List.iter (VertexArray.Source.add src) (get_vertices sprite);
(*     debug_t.vertices_create_t <- debug_t.vertices_create_t +. (tm () -. t); *)
(*     let t = tm () in *)
    let vao = VertexArray.static (module Target) target src in
(*     debug_t.vao_create_t <- debug_t.vao_create_t +. (tm () -. t); *)
    vao
  in
(*   let t = tm () in *)
  VertexArray.draw (module Target)
        ~target
        ~vertices
        ~program
        ~parameters
        ~uniform ()
(*   ;debug_t.draw_t <- debug_t.draw_t +. (tm () -. t) *)

let set_position sprite position =
  sprite.position <- position 

let set_origin sprite origin =
  sprite.origin <- origin 

let set_rotation sprite rotation =
  sprite.rotation <- rotation 

let set_size sprite size = 
  sprite.size <- size

let set_scale sprite scale =
  sprite.scale <- scale 

let translate sprite delta =
  sprite.position <- Vector2f.(add delta sprite.position) 

let rotate sprite delta =
  mod_float (sprite.rotation +. delta) (2. *. Constants.pi)
  |> set_rotation sprite

let scale sprite scale =
  let mul v w =
    Vector2f.({
      x = v.x *. w.x ;
      y = v.y *. w.y
    })
  in
  set_scale sprite (mul scale sprite.scale)

let position sprite = sprite.position

let origin sprite = sprite.origin

let rotation sprite = sprite.rotation

let size sprite = sprite.size

let get_scale sprite = sprite.scale
