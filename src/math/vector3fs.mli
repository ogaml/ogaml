(* Operations on immutable 3 floats vectors in spherical coordinates*)

exception Vector3fs_exception of string

type t = {r : float; t : float; p : float}

val zero : t

val unit_x : t

val unit_y : t

val unit_z : t

val prop : float -> t -> t

val div : float -> t -> t

val to_cartesian : t -> Vector3f.t

val from_cartesian : Vector3f.t -> t

val norm : t -> float

val normalize : t -> t

val print : t -> string

