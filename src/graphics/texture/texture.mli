
module type T = sig

  type t

  (* System only *)
  val bind : t -> int -> unit

end

module MinifyFilter = GLTypes.MinifyFilter

module MagnifyFilter = GLTypes.MagnifyFilter

module WrapFunction = GLTypes.WrapFunction

module Texture2D : sig

  type t

  val create : (module RenderTarget.T with type t = 'a) -> 'a 
               -> [< `File of string | `Image of Image.t ] -> t

  val size : t -> OgamlMath.Vector2i.t

  val minify : t -> MinifyFilter.t -> unit

  val magnify : t -> MagnifyFilter.t -> unit

  val wrap : t -> WrapFunction.t -> unit

  val bind : t -> int -> unit

  val to_color_attachment : t -> Attachment.ColorAttachment.t

end
