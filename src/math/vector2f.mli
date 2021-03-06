(* Operations on immutable 2 floats vectors *)

exception Vector2f_exception of string

type t = {x : float; y : float}

val make : float -> float -> t

val zero : t

val unit_x : t

val unit_y : t

val add : t -> t -> t

val sub : t -> t -> t

val prop : float -> t -> t

val div : float -> t -> t

val pointwise_product : t -> t -> t

val pointwise_div : t -> t -> t

val to_int : t -> Vector2i.t

val from_int : Vector2i.t -> t

val dot : t -> t -> float

val product : t -> t -> t

val det : t -> t -> float

val angle : t -> t -> float

val squared_norm : t -> float

val norm : t -> float

val squared_dist : t -> t -> float

val dist : t -> t -> float

val clamp : t -> t -> t -> t

val map : t -> (float -> float) -> t

val map2 : t -> t -> (float -> float -> float) -> t

val max : t -> float

val min : t -> float

val normalize : t -> t

val to_string : t -> string

val direction : t -> t -> t

val endpoint : t -> t -> float -> t

val raytrace_points : t -> t -> (float * t * t) list

val raytrace : t -> t -> float -> (float * t * t) list

