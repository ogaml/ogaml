type t

val create : ?position:Vector2f.t -> ?origin:Vector2f.t -> ?rotation:float ->
  ?scale:Vector2f.t -> unit -> t

val position : t -> Vector2f.t

val origin : t -> Vector2f.t

val rotation : t -> float

val scale : t -> Vector2f.t

val compose : ?translation:Vector2f.t -> ?rotation:float -> 
  ?scaling:Vector2f.t -> t -> t

val translate : Vector2f.t -> t -> t

val rotate : float -> t -> t

val rescale : Vector2f.t -> t -> t

val set : ?position:Vector2f.t -> ?origin:Vector2f.t -> ?rotation:float ->
  ?scale:Vector2f.t -> t -> t

val apply : t -> Vector2f.t -> Vector2f.t
