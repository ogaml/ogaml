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

let get_vertices size position origin rotation scale =
  let vertex1 =
    VertexArray.Vertex.create
      ~position:Vector3f.({x = -0.75; y = 0.75; z = 0.0})
      ~texcoord:Vector2f.({x = 0.; y = 1.}) ()
  in
  let vertex2 =
    VertexArray.Vertex.create
      ~position:Vector3f.({x = 0.75; y = 0.75; z = 0.0})
      ~texcoord:Vector2f.({x = 1.; y = 1.}) ()
  in
  let vertex3 =
    VertexArray.Vertex.create
      ~position:Vector3f.({x = -0.75; y = -0.75; z = 0.0})
      ~texcoord:Vector2f.({x = 0.; y = 0.}) ()
  in
  let vertex4 =
    VertexArray.Vertex.create
      ~position:Vector3f.({x = 0.75; y = -0.75; z = 0.0})
      ~texcoord:Vector2f.({x = 1.; y = 0.}) ()
  in
  let vertex_source = VertexArray.Source.(
      empty ~position:"position" ~texcoord:"uv" ~size:4 ()
      << vertex1
      << vertex2
      << vertex3
      << vertex4
  )
  in
  VertexArray.static vertex_source

let create_sprite ~texture
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

let draw ~window ~sprite = ()
