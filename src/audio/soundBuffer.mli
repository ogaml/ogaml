
type t

type samples = (int, Bigarray.int16_signed_elt, Bigarray.c_layout) Bigarray.Array1.t

val load : string -> t

val create :
  samples:samples ->
  channels:[`Stereo | `Mono] ->
  rate:int -> t

val duration : t -> float

val samples : t -> samples

val channels : t -> [`Stereo | `Mono]


module LL : sig

  val buffer : t -> AL.Buffer.t

end
