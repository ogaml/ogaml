(* Operations on immutable 2 floats vectors *)

type t = {x : float; y : float}

val zero : t

val unit_x : t

val unit_y : t

val add : t -> t -> t

val sub : t -> t -> t

val prop : float -> t -> t

val div : float -> t -> t

val floor : t -> Vector2i.t

val from_int : Vector2i.t -> t

val dot : t -> t -> float

val product : t -> t -> t

val det : t -> t -> float

val angle : t -> t -> float

val squared_norm : t -> float

val norm : t -> float

val clamp : t -> t -> t -> t

val map : t -> (float -> float) -> t

val map2 : t -> t -> (float -> float -> float) -> t

val max : t -> float

val min : t -> float

val normalize : t -> t

val print : t -> string

val direction : t -> t -> t

val endpoint : t -> t -> float -> t

