
type t

val create : [`File of string | `Image of Image.t ] -> t

val activate : int -> unit

val bind : t option -> unit

val delete : t -> unit

