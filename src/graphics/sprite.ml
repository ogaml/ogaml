open OgamlMath

type t = {
  texture : Texture.Texture2D.t ;
  size    : Vector2f.t ;
  mutable vertices : VertexArray.static VertexArray.t ;
  mutable position : Vector2f.t ;
  mutable origin   : Vector2f.t ;
  mutable rotation : float ;
  mutable scale    : Vector2f.t
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

let get_vertices size position origin rotation scale =
  let (w,h) = Vector2f.(
    { x = size.x ; y = 0.     },
    { x = 0.     ; y = size.y }
  ) in
  Vector2f.([ zero ; w ; h ; add w h ])
  |> List.map (apply_transformations position origin rotation scale)
  |> List.combine Vector2f.([
    { x = 1. ; y = 1. } ;
    { x = 0. ; y = 1. } ;
    { x = 1. ; y = 0. } ;
    { x = 0. ; y = 0. }
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
           ?origin:(origin=Vector2f.zero)
           ?position:(position=Vector2i.zero)
           ?scale:(scale=Vector2f.({ x = 1. ; y = 1.}))
           ?rotation:(rotation=0.) () =
  let (w,h) = Texture.Texture2D.size texture in
  let size = Vector2f.({ x = float_of_int w ; y = float_of_int h }) in
  let position = Vector2f.from_int position in
  let vertices = get_vertices size position origin rotation scale in
  {
    texture  = texture ;
    size     = size ;
    vertices = vertices ;
    position = position ;
    origin   = origin ;
    rotation = rotation ;
    scale    = scale
  }

let draw ~window ~sprite =
  let program = Window.LL.sprite_program window in
  let parameters = DrawParameter.make () in
  let (sx,sy) = Window.size window in
  let uniform =
    Uniform.empty
    |> Uniform.vector2f "size" OgamlMath.(
         Vector2f.from_int Vector2i.({ x = sx ; y = sy })
       )
    |> Uniform.texture2D "my_texture" sprite.texture
  in
  let vertices = sprite.vertices in
  VertexArray.draw
        ~window
        ~vertices
        ~program
        ~parameters
        ~uniform
        ~mode:DrawMode.TriangleStrip ()
