

module Texture2D : sig

  type t

  val create : State.t -> [< `File of string | `Image of Image.t ] -> t

  val size : t -> (int * int)

  module LL : sig

    val bind : State.t -> t option -> unit

  end

end
