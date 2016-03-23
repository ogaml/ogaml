

module Texture2D : sig

  type t

  val create : [< `File of string | `Image of Image.t ] -> t

  val size : t -> OgamlMath.Vector2i.t

  module LL : sig

    val bind : State.t -> int -> t option -> unit

  end

end
