(* Operation on immutable 2 ints vectors *)

exception Vector2i_exception of string

type t = {x : int; y : int}

val zero : t

val unit_x : t

val unit_y : t

val add : t -> t -> t

val sub : t -> t -> t

val prop : int -> t -> t

val div : int -> t -> t

val dot : t -> t -> int

val product : t -> t -> t

val det : t -> t -> int

val angle : t -> t -> float

val squared_norm : t -> int

val norm : t -> float

val clamp : t -> t -> t -> t

val map : t -> (int -> int) -> t

val map2 : t -> t -> (int -> int -> int) -> t

val max : t -> int

val min : t -> int

val raster : t -> t -> t list

val print : t -> string

