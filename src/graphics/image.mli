
type t

val create : [`File of string | `Empty of int * int * Color.t] -> t

val size : t -> (int * int)

val set : t -> int -> int -> Color.t -> unit

val get : t -> int -> int -> Color.RGB.t

val data : t -> Bytes.t

