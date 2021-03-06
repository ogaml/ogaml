
exception Texture_error of string

module type T = sig

  type t

  (* System only *)
  val bind : t -> int -> unit

end

module MinifyFilter = GLTypes.MinifyFilter

module MagnifyFilter = GLTypes.MagnifyFilter

module WrapFunction = GLTypes.WrapFunction

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
               -> [< `File of string | `Image of Image.t | `Empty of OgamlMath.Vector2i.t] -> t

  val size : t -> OgamlMath.Vector2i.t

  val minify : t -> MinifyFilter.t -> unit

  val magnify : t -> MagnifyFilter.t -> unit

  val wrap : t -> WrapFunction.t -> unit

  val mipmap_levels : t -> int

  val mipmap : t -> int -> Texture2DMipmap.t

  val to_color_attachment : t -> Attachment.ColorAttachment.t

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

  val layer : t -> int -> Texture2DArrayLayerMipmap.t

  val bind : t -> int -> unit

end


module Texture2DArrayLayer : sig

  type t

  val size : t -> OgamlMath.Vector2i.t

  val layer : t -> int

  val mipmap_levels : t -> int

  val mipmap : t -> int -> Texture2DArrayLayerMipmap.t

  val bind : t -> int -> unit

  val to_color_attachment : t -> Attachment.ColorAttachment.t

end


module Texture2DArray : sig

  type t 

  val create : (module RenderTarget.T with type t = 'a) -> 'a
               -> ?mipmaps:[`AllEmpty | `Empty of int | `AllGenerated | `Generated of int | `None]
               -> [< `File of string | `Image of Image.t | `Empty of OgamlMath.Vector2i.t] list -> t

  val size : t -> OgamlMath.Vector3i.t

  val minify : t -> MinifyFilter.t -> unit

  val magnify : t -> MagnifyFilter.t -> unit

  val wrap : t -> WrapFunction.t -> unit

  val layers : t -> int

  val mipmap_levels : t -> int

  val layer : t -> int -> Texture2DArrayLayer.t

  val mipmap : t -> int -> Texture2DArrayMipmap.t

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

  val mipmap : t -> int -> CubemapMipmapFace.t

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
               -> positive_x:[< `File of string | `Image of Image.t | `Empty of OgamlMath.Vector2i.t]
               -> positive_y:[< `File of string | `Image of Image.t | `Empty of OgamlMath.Vector2i.t]
               -> positive_z:[< `File of string | `Image of Image.t | `Empty of OgamlMath.Vector2i.t]
               -> negative_x:[< `File of string | `Image of Image.t | `Empty of OgamlMath.Vector2i.t]
               -> negative_y:[< `File of string | `Image of Image.t | `Empty of OgamlMath.Vector2i.t]
               -> negative_z:[< `File of string | `Image of Image.t | `Empty of OgamlMath.Vector2i.t]
               -> unit -> t

  val size : t -> OgamlMath.Vector2i.t

  val minify : t -> MinifyFilter.t -> unit

  val magnify : t -> MagnifyFilter.t -> unit

  val wrap : t -> WrapFunction.t -> unit

  val mipmap_levels : t -> int

  val mipmap : t -> int -> CubemapMipmap.t

  val face : t -> [`PositiveX | `PositiveY | `PositiveZ | `NegativeX | `NegativeY | `NegativeZ] 
               -> CubemapFace.t

  val bind : t -> int -> unit

end
