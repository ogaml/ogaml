
type t

val create : [`File of string | `Image of Image.t ] -> t

val bind : t -> unit

val delete : t -> unit

