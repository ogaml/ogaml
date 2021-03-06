(* Operations on immutable 3 floats vectors *)

exception Vector3f_exception of string

type t = {x : float; y : float; z : float}

val make : float -> float -> float -> t

val zero : t

val unit_x : t

val unit_y : t

val unit_z : t

val add : t -> t -> t

val sub : t -> t -> t

val prop : float -> t -> t

val div : float -> t -> t

val pointwise_product : t -> t -> t

val pointwise_div : t -> t -> t

val to_int : t -> Vector3i.t

val from_int : Vector3i.t -> t

val project : t -> Vector2f.t

val lift : Vector2f.t -> t

val dot : t -> t -> float

val product : t -> t -> t

val cross : t -> t -> t

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

(* Returns the normalized direction vector from point1 to point 2 
 * Equivalent to normalize @ sub *)
val direction : t -> t -> t

(* Returns the point u + tv *)
val endpoint : t -> t -> float -> t

val raytrace_points : t -> t -> (float * t * t) list

val raytrace : t -> t -> float -> (float * t * t) list

