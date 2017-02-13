
type t = {x : int; y : int; width : int; height : int}

val create : Vector2i.t -> Vector2i.t -> t

val create_from_points : Vector2i.t -> Vector2i.t -> t

val zero : t

val one : t

val position : t -> Vector2i.t

val abs_position : t -> Vector2i.t

val corner : t -> Vector2i.t

val abs_corner : t -> Vector2i.t

val size : t -> Vector2i.t

val abs_size : t -> Vector2i.t

val center : t -> Vector2f.t

val normalize : t -> t

val area : t -> int

val extend : t -> Vector2i.t -> t

val scale : t -> Vector2i.t -> t

val translate : t -> Vector2i.t -> t

val intersects : t -> t -> bool

val includes : t -> t -> bool

val contains : ?strict:bool -> t -> Vector2i.t -> bool

val iter : ?strict:bool -> t -> (Vector2i.t -> unit) -> unit

val fold : ?strict:bool -> t -> (Vector2i.t -> 'a -> 'a) -> 'a -> 'a

val to_string : t -> string
