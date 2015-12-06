(** Shader types enumeration *)
module ShaderType : sig

  type t = 
    | Fragment
    | Vertex

end

(** GLSL types enumeration *)
module GlslType : sig

  type t =
    | Int
    | Int2
    | Int3
    | Int4
    | Float
    | Float2
    | Float3
    | Float4
    | Float2x2
    | Float2x3
    | Float2x4
    | Float3x2
    | Float3x3
    | Float3x4
    | Float4x2
    | Float4x3
    | Float4x4
    | Sampler1D
    | Sampler2D
    | Sampler3D

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
    | Depth
    | DepthStencil

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

(** VBO kinds enumeration *)
module VBOKind : sig

  type t = 
    | StaticDraw
    | DynamicDraw

end

(** GL float types *)
module GlFloatType : sig

  type t = 
    | Byte
    | UByte
    | Short
    | UShort
    | Int
    | UInt
    | Float
    | Double

end

(** GL int types *)
module GlIntType : sig

  type t  =
    | Byte
    | UByte
    | Short
    | UShort
    | Int
    | UInt

end

(** GL errors *)
module GlError : sig

  type t = 
    | Invalid_enum
    | Invalid_value
    | Invalid_op
    | Invalid_fbop
    | Out_of_memory
    | Stack_underflow
    | Stack_overflow

end

