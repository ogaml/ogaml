type t

val load : 
  ?buffers:int ->
  ?buffer_size:int -> 
  string -> (t, [> `Loading_error]) result

val play :
  ?pitch:float ->
  ?gain:float ->
  ?force:bool ->
  ?on_stop:(unit -> unit) ->
  t -> AudioSource.t -> 
  (unit, [> `No_source_available]) result

val duration : t -> float

val seek : t -> float -> unit

val current : t -> float

val pause : t -> unit

val resume : t -> unit

val status : t -> [`Playing | `Stopped | `Paused]

val detach : t -> unit

val stop : t -> unit
