
type t = {x : int; y : int; z : int; width : int; height : int; depth : int}

val create : Vector3i.t -> Vector3i.t -> t

val create_from_points : Vector3i.t -> Vector3i.t -> t

val zero : t

val one : t

val position : t -> Vector3i.t

val corner : t -> Vector3i.t

val size : t -> Vector3i.t

val center : t -> Vector3f.t

val normalize : t -> t

val volume : t -> int

val scale : t -> Vector3i.t -> t

val translate : t -> Vector3i.t -> t

val intersect : t -> t -> bool

val contains : t -> Vector3i.t -> bool

val iter : t -> (int -> int -> int -> unit) -> unit
