
exception Error of string

type t

type samples = (int, Bigarray.int16_signed_elt, Bigarray.c_layout) Bigarray.Array1.t

val load : string -> t

val create :
  samples:samples ->
  channels:[`Stereo | `Mono] ->
  rate:int -> t

val play :
  ?pitch:float ->
  ?gain:float ->
  ?loop:bool ->
  ?force:bool ->
  ?on_stop:(unit -> unit) ->
  t -> AudioSource.t ->
  (unit, [> `NoSourceAvailable]) result

val duration : t -> float

val samples : t -> samples

val channels : t -> [`Stereo | `Mono]
