

module Texture2D : sig

  type t

  val create : State.t -> [< `File of string | `Image of Image.t ] -> t

  val bind : State.t -> t option -> unit

  val size : t -> (int * int)

end
