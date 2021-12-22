
module type T = sig

  type t

  (* System only *)
  val bind : t -> int -> unit

end


module MinifyFilter = GLTypes.MinifyFilter


module MagnifyFilter = GLTypes.MagnifyFilter


module WrapFunction = GLTypes.WrapFunction


module CompareFunction = GLTypes.CompareFunction


module DepthFormat : sig

  type t = 
    | Int16
    | Int24
    | Int32

end


module TextureFormat : sig

  type t = 
    | R8
    | RG8
    | RGB8
    | RGBA8
    | R16
    | RG16
    | RGB16
    | RGBA16
    | R16F
    | RG16F
    | RGB16F
    | RGBA16F
    | R32F
    | RG32F
    | RGB32F
    | RGBA32F

end


module Texture2DMipmap : sig

  type t

  val size : t -> OgamlMath.Vector2i.t

  val write : t -> ?rect:OgamlMath.IntRect.t -> Image.t -> unit

  val level : t -> int

  val to_color_attachment : t -> Attachment.ColorAttachment.t

  val bind : t -> int -> unit

end


module Texture2D : sig

  type t

  val create : (module RenderTarget.T with type t = 'a) -> 'a 
               -> ?mipmaps:[`AllEmpty | `Empty of int | `AllGenerated | `Generated of int | `None]
               -> ?format:TextureFormat.t 
               -> [< `File of string | `Image of Image.t | `Empty of OgamlMath.Vector2i.t] -> 
               (t, [> `Texture_too_large
                    | `File_not_found of string
                    | `Loading_error of string]) result

  val size : t -> OgamlMath.Vector2i.t

  val minify : t -> MinifyFilter.t -> unit

  val magnify : t -> MagnifyFilter.t -> unit

  val wrap : t -> WrapFunction.t -> unit

  val mipmap_levels : t -> int

  val mipmap : t -> int -> (Texture2DMipmap.t, [> `Invalid_mipmap]) result

  val to_color_attachment : t -> Attachment.ColorAttachment.t

  val bind : t -> int -> unit

end


module DepthTexture2DMipmap : sig

  type t

  val size : t -> OgamlMath.Vector2i.t

  val write : t -> ?rect:OgamlMath.IntRect.t -> Image.t -> unit

  val level : t -> int

  val to_depth_attachment : t -> Attachment.DepthAttachment.t

  val bind : t -> int -> unit

end


module DepthTexture2D : sig

  type t

  val create : (module RenderTarget.T with type t = 'a) -> 'a 
               -> ?mipmaps:[`AllEmpty | `Empty of int | `AllGenerated | `Generated of int | `None]
               -> DepthFormat.t
               -> [< `Data of (OgamlMath.Vector2i.t * Bytes.t) | `Empty of OgamlMath.Vector2i.t] -> 
               (t, [> `Insufficient_data 
                    | `Texture_too_large
                    | `File_not_found of string
                    | `Loading_error of string]) result

  val size : t -> OgamlMath.Vector2i.t

  val minify : t -> MinifyFilter.t -> unit

  val magnify : t -> MagnifyFilter.t -> unit

  val wrap : t -> WrapFunction.t -> unit

  val compare_function : t -> CompareFunction.t option -> unit

  val mipmap_levels : t -> int

  val mipmap : t -> int -> (DepthTexture2DMipmap.t, [> `Invalid_mipmap]) result

  val to_depth_attachment : t -> Attachment.DepthAttachment.t

  val bind : t -> int -> unit

end


module Texture2DArrayLayerMipmap : sig

  type t

  val size : t -> OgamlMath.Vector2i.t

  val write : t -> OgamlMath.IntRect.t -> Image.t -> unit

  val layer : t -> int

  val level : t -> int

  val bind : t -> int -> unit

  val to_color_attachment : t -> Attachment.ColorAttachment.t

end


module Texture2DArrayMipmap : sig

  type t

  val size : t -> OgamlMath.Vector3i.t

  val layers : t -> int

  val level : t -> int

  val layer : t -> int -> (Texture2DArrayLayerMipmap.t, [> `Invalid_layer]) result

  val bind : t -> int -> unit

end


module Texture2DArrayLayer : sig

  type t

  val size : t -> OgamlMath.Vector2i.t

  val layer : t -> int

  val mipmap_levels : t -> int

  val mipmap : t -> int -> (Texture2DArrayLayerMipmap.t, [> `Invalid_mipmap]) result

  val bind : t -> int -> unit

  val to_color_attachment : t -> Attachment.ColorAttachment.t

end


module Texture2DArray : sig

  type t 

  val create : (module RenderTarget.T with type t = 'a) -> 'a
               -> ?mipmaps:[`AllEmpty | `Empty of int | `AllGenerated | `Generated of int | `None]
               -> ?format:TextureFormat.t 
               -> [< `File of string | `Image of Image.t | `Empty of OgamlMath.Vector2i.t] list ->
               (t, [> `No_input_files
                    | `Non_equal_input_sizes
                    | `Texture_too_large
                    | `Texture_too_deep
                    | `File_not_found of string
                    | `Loading_error of string]) result

  val size : t -> OgamlMath.Vector3i.t

  val minify : t -> MinifyFilter.t -> unit

  val magnify : t -> MagnifyFilter.t -> unit

  val wrap : t -> WrapFunction.t -> unit

  val layers : t -> int

  val mipmap_levels : t -> int

  val layer : t -> int -> (Texture2DArrayLayer.t, [> `Invalid_layer]) result

  val mipmap : t -> int -> (Texture2DArrayMipmap.t, [> `Invalid_mipmap]) result

  val bind : t -> int -> unit

end


module CubemapMipmapFace : sig

  type t

  val size : t -> OgamlMath.Vector2i.t

  val write : t -> OgamlMath.IntRect.t -> Image.t -> unit

  val level : t -> int

  val face : t -> [`PositiveX | `PositiveY | `PositiveZ | `NegativeX | `NegativeY | `NegativeZ] 

  val bind : t -> int -> unit

  val to_color_attachment : t -> Attachment.ColorAttachment.t

end


module CubemapFace : sig

  type t

  val size : t -> OgamlMath.Vector2i.t

  val mipmap_levels : t -> int

  val mipmap : t -> int -> (CubemapMipmapFace.t, [> `Invalid_mipmap]) result

  val face : t -> [`PositiveX | `PositiveY | `PositiveZ | `NegativeX | `NegativeY | `NegativeZ] 

  val bind : t -> int -> unit

  val to_color_attachment : t -> Attachment.ColorAttachment.t

end


module CubemapMipmap : sig

  type t

  val size : t -> OgamlMath.Vector2i.t

  val level : t -> int

  val face : t -> [`PositiveX | `PositiveY | `PositiveZ | `NegativeX | `NegativeY | `NegativeZ] 
               -> CubemapMipmapFace.t

  val bind : t -> int -> unit

end


module Cubemap : sig

  type t

  val create : (module RenderTarget.T with type t = 'a) -> 'a
               -> ?mipmaps:[`AllEmpty | `Empty of int | `AllGenerated | `Generated of int | `None]
               -> ?format:TextureFormat.t 
               -> positive_x:[< `File of string | `Image of Image.t | `Empty of OgamlMath.Vector2i.t]
               -> positive_y:[< `File of string | `Image of Image.t | `Empty of OgamlMath.Vector2i.t]
               -> positive_z:[< `File of string | `Image of Image.t | `Empty of OgamlMath.Vector2i.t]
               -> negative_x:[< `File of string | `Image of Image.t | `Empty of OgamlMath.Vector2i.t]
               -> negative_y:[< `File of string | `Image of Image.t | `Empty of OgamlMath.Vector2i.t]
               -> negative_z:[< `File of string | `Image of Image.t | `Empty of OgamlMath.Vector2i.t]
               -> unit -> 
               (t, [> `Texture_too_large
                    | `Non_equal_input_sizes
                    | `File_not_found of string
                    | `Loading_error of string]) result

  val size : t -> OgamlMath.Vector2i.t

  val minify : t -> MinifyFilter.t -> unit

  val magnify : t -> MagnifyFilter.t -> unit

  val wrap : t -> WrapFunction.t -> unit

  val mipmap_levels : t -> int

  val mipmap : t -> int -> (CubemapMipmap.t, [> `Invalid_mipmap]) result

  val face : t -> [`PositiveX | `PositiveY | `PositiveZ | `NegativeX | `NegativeY | `NegativeZ] 
               -> CubemapFace.t

  val bind : t -> int -> unit

end


module Texture3DMipmap : sig

  type t

  val size : t -> OgamlMath.Vector3i.t

  val level : t -> int

  val layer : t -> int -> (t, [> `Invalid_layer]) result

  val current_layer : t -> int

  val bind : t -> int -> unit

  val write : t -> OgamlMath.IntRect.t -> Image.t -> unit
  
  val to_color_attachment : t -> Attachment.ColorAttachment.t

end


module Texture3D : sig

  type t 

  val create : (module RenderTarget.T with type t = 'a) -> 'a
               -> ?mipmaps:[`AllEmpty | `Empty of int | `AllGenerated | `Generated of int | `None]
               -> ?format:TextureFormat.t 
               -> [< `File of string | `Image of Image.t | `Empty of OgamlMath.Vector2i.t] list -> 
               (t, [> `Texture_too_large
                    | `Non_equal_input_sizes
                    | `No_input_files
                    | `File_not_found of string
                    | `Loading_error of string]) result

  val size : t -> OgamlMath.Vector3i.t

  val minify : t -> MinifyFilter.t -> unit

  val magnify : t -> MagnifyFilter.t -> unit

  val wrap : t -> WrapFunction.t -> unit

  val mipmap_levels : t -> int

  val mipmap : t -> int -> (Texture3DMipmap.t, [> `Invalid_mipmap]) result

  val bind : t -> int -> unit

end


