type t

type samples = (int, Bigarray.int16_signed_elt, Bigarray.c_layout) Bigarray.Array1.t

val load :
  string ->
  (t, [> `File_not_found of string | `Unsupported_number_of_channels]) result

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
  (unit, [> `No_source_available]) result

val duration : t -> float

val samples : t -> samples

val channels : t -> [`Stereo | `Mono]
