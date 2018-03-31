(* Operations on immutable 3 floats vectors in spherical coordinates*)

type t = {r : float; t : float; p : float}

val zero : t

val unit_x : t

val unit_y : t

val unit_z : t

val prop : float -> t -> t

val div : float -> t -> (t, [> `Division_by_zero]) result

val to_cartesian : t -> Vector3f.t

val from_cartesian : Vector3f.t -> t

val norm : t -> float

val normalize : t -> (t, [> `Division_by_zero]) result

val to_string : t -> string

