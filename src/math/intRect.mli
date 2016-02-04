
type t = {x : int; y : int; width : int; height : int}

val create : Vector2i.t -> Vector2i.t -> t

val create_from_points : Vector2i.t -> Vector2i.t -> t

val zero : t

val one : t

val position : t -> Vector2i.t

val corner : t -> Vector2i.t

val size : t -> Vector2i.t

val center : t -> Vector2f.t

val normalize : t -> t

val area : t -> int

val scale : t -> Vector2i.t -> t

val translate : t -> Vector2i.t -> t

val intersect : t -> t -> bool

val contains : t -> Vector2i.t -> bool

val iter : t -> (Vector2i.t -> unit) -> unit

val fold : t -> (Vector2i.t -> 'a -> 'a) -> 'a -> 'a

