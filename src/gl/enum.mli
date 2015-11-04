(** This module defines all GL enumerations *)

(** Backface culling enumeration *)
module CullingMode : sig

  type t = 
    | CullNone
    | CullClockwise
    | CullCounterClockwise
    | CullAll

end


(** Polygon drawing mode enumeration *)
module PolygonMode : sig

  type t = 
    | DrawVertices
    | DrawLines
    | DrawFill

end


(** Texture targets enumeration *)
module TextureTarget : sig

  type t = 
    | Texture1D
    | Texture2D
    | Texture3D

end


(** Pixel format enumeration *)
module PixelFormat : sig

  type t = 
    | R
    | RG
    | RGB
    | BGR
    | RGBA
    | BGRA
    | Depth
    | DepthStencil

end


(** Texture format enumeration *)
module TextureFormat : sig

  type t = 
    | RGB
    | RGBA
    | Depth16
    | Depth24
    | Depth32

end


(** Texture minify filter values *)
module MinifyFilter : sig

  type t = 
    | Nearest
    | Linear
    | NearestMipmap
    | LinearMipmap

end


(** Texture magnify filter values *)
module MagnifyFilter : sig

  type t = 
    | Nearest
    | Linear

end


