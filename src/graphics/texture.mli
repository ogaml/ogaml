

module Texture2D : sig

  type t

  val create : (module RenderTarget.T with type t = 'a) -> 'a 
               -> [< `File of string | `Image of Image.t ] -> t

  val size : t -> OgamlMath.Vector2i.t

  module LL : sig

    val bind : State.t -> int -> t option -> unit

    val internal : t -> GL.Texture.t

  end

end
