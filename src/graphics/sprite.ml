open OgamlMath

exception Sprite_error of string

type t = {
  texture : Texture.Texture2D.t ;
  subrect : OgamlMath.FloatRect.t ;
  mutable size    : Vector2f.t ;
  mutable vertices : VertexArray.static VertexArray.t ;
  mutable position : Vector2f.t ;
  mutable origin   : Vector2f.t ;
  mutable rotation : float ;
  mutable scale    : Vector2f.t
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

let get_vertices size position origin rotation scale subrect =
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
  | [ a ; b ; c ; d ] ->
    VertexArray.Source.(
        empty ~position:"position" ~texcoord:"uv" ~size:4 ()
        << a
        << b
        << c
        << d
    )
    |> VertexArray.static
  | _ -> assert false

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
    match size with
    | None   -> base_size
    | Some s -> s
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
  let vertices = get_vertices size position origin rotation scale subrect in
  {
    texture  = texture ;
    subrect  = subrect ;
    size     = size ;
    vertices = vertices ;
    position = position ;
    origin   = origin ;
    rotation = rotation ;
    scale    = scale
  }

let draw ?parameters:(parameters = DrawParameter.make
                                    ~depth_test:false 
                                    ~blend_mode:DrawParameter.BlendMode.alpha ())
         ~window ~sprite () =
  let program = Window.LL.sprite_program window in
  let sizei = Window.size window in
  let size = Vector2f.from_int sizei in
  let uniform =
    Uniform.empty
    |> Uniform.vector2f "size" size
    |> Uniform.texture2D "utexture" sprite.texture
  in
  let vertices = sprite.vertices in
  VertexArray.draw
        ~window
        ~vertices
        ~program
        ~parameters
        ~uniform
        ~mode:DrawMode.TriangleStrip ()

let update sprite =
  let vertices =
    get_vertices
      sprite.size
      sprite.position
      sprite.origin
      sprite.rotation
      sprite.scale
      sprite.subrect
  in
  sprite.vertices <- vertices

let set_position sprite position =
  sprite.position <- position ;
  update sprite

let set_origin sprite origin =
  sprite.origin <- origin ;
  update sprite

let set_rotation sprite rotation =
  sprite.rotation <- rotation ;
  update sprite

let set_size sprite size = 
  sprite.size <- size;
  update sprite

let set_scale sprite scale =
  sprite.scale <- scale ;
  update sprite

let translate sprite delta =
  sprite.position <- Vector2f.(add delta sprite.position) ;
  update sprite

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
