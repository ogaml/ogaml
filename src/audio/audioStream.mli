type t

val load : string -> t

val play :
  ?pitch:float ->
  ?gain:float ->
  ?loop:bool ->
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

val attach : t -> AudioSource.t -> unit

val stop : t -> unit
