type t

val load : string -> (t, unit) result

val play :
  ?pitch:float ->
  ?gain:float ->
  ?force:bool ->
  ?on_stop:(unit -> unit) ->
  t -> AudioSource.t -> unit

val duration : t -> float

val seek : t -> float -> unit

val current : t -> float

val pause : t -> unit

val resume : t -> unit

val status : t -> [`Playing | `Stopped | `Paused]

val detach : t -> unit

val stop : t -> unit
