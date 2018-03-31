(** Shader types enumeration *)
module ShaderType = struct

  type t = 
    | Fragment
    | Vertex

end

(** GLSL types enumeration *)
module GlslType = struct

  type t =
    | Unknown
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
    | Sampler2DArray
    | Sampler3D
    | SamplerCube

end

(** Texture targets enumeration *)
module TextureTarget = struct

  type t = 
    | Texture1D
    | Texture2D
    | Texture2DArray
    | Texture3D
    | CubemapTexture
    | CubemapPositiveX
    | CubemapPositiveY
    | CubemapPositiveZ
    | CubemapNegativeX
    | CubemapNegativeY
    | CubemapNegativeZ

end

(** Pixel format enumeration *)
module PixelFormat = struct

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
module TextureFormat = struct

  type t = 
    | R8
    | RG8
    | RGB8
    | RGBA8
    | Depth16
    | Depth24
    | Depth32
    | Depth24Stencil8
    | Stencil8

end

(** Texture minify filter values *)
module MinifyFilter = struct

  type t = 
    | Nearest
    | Linear
    | NearestMipmapNearest
    | LinearMipmapNearest
    | NearestMipmapLinear
    | LinearMipmapLinear

end

(** Texture magnify filter values *)
module MagnifyFilter = struct

  type t = 
    | Nearest
    | Linear

end

(** Texture wrap function *)
module WrapFunction = struct

  type t =
    | ClampEdge
    | ClampBorder
    | MirrorRepeat
    | Repeat
    | MirrorClamp

end

(** VBO kinds enumeration *)
module VBOKind = struct

  type t = 
    | StaticDraw
    | DynamicDraw

end

(** GL float types *)
module GlFloatType = struct

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
module GlIntType = struct

  type t  =
    | Byte
    | UByte
    | Short
    | UShort
    | Int
    | UInt

end

(** GL errors *)
module GlError = struct

  type t = 
    | Invalid_enum
    | Invalid_value
    | Invalid_op
    | Invalid_fbop
    | Out_of_memory
    | Stack_underflow
    | Stack_overflow

end

(** Texture attachements *)
module GlAttachment = struct

  type t = 
    | Color of int
    | Depth
    | Stencil
    | DepthStencil

end

(** Parameters *)
module Parameter = struct

  type t = 
    | Max3DTextureSize
    | MaxArrayTextureLayers
    | MaxColorTextureSamples
    | MaxCubeMapTextureSize
    | MaxDepthTextureSamples
    | MaxElementsIndices
    | MaxElementsVertices
    | MaxIntegerSamples
    | MaxRenderbufferSize
    | MaxTextureBufferSize
    | MaxTextureImageUnits
    | MaxTextureSize
    | MaxColorAttachments
    | MaxDrawBuffers

end

(** Window output buffers *)
module WindowOutputBuffer = struct
   
  type t = 
    | FrontLeft
    | FrontRight
    | BackLeft
    | BackRight
    | None

end

(** FBO output buffers *)
module FBOOutputBuffer = struct

  type t = 
    | Color of int
    | None
            
end
