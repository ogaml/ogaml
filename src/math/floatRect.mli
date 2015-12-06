type t = {x : float; y : float; width : float; height : float}

val create : Vector2f.t -> Vector2f.t -> t

val corner : t -> Vector2f.t

val center : t -> Vector2f.t

val area : t -> float

val scale : t -> Vector2f.t -> t

val translate : t -> Vector2f.t -> t

val from_int : IntRect.t -> t

val floor : t -> IntRect.t

val intersect : t -> t -> bool

val contains : t -> Vector2f.t -> bool

