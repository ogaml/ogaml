type t = {x : float; y : float; width : float; height : float}

val create : Vector2f.t -> Vector2f.t -> t

val create_from_points : Vector2f.t -> Vector2f.t -> t

val zero : t

val one : t

val position : t -> Vector2f.t

val abs_position : t -> Vector2f.t

val corner : t -> Vector2f.t

val size : t -> Vector2f.t

val abs_size : t -> Vector2f.t

val center : t -> Vector2f.t

val normalize : t -> t

val area : t -> float

val scale : t -> Vector2f.t -> t

val translate : t -> Vector2f.t -> t

val from_int : IntRect.t -> t

val floor : t -> IntRect.t

val intersects : t -> t -> bool

val contains : t -> Vector2f.t -> bool

