(* Operations on immutable 2 floats vectors in spherical coordinates*)

exception Vector2fs_exception of string

type t = {r : float; t : float}

val zero : t

val unit_x : t

val unit_y : t

val prop : float -> t -> t

val div : float -> t -> t

val to_cartesian : t -> Vector2f.t

val from_cartesian : Vector2f.t -> t

val norm : t -> float

val normalize : t -> t

val print : t -> string

