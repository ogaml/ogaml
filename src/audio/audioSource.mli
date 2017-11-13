
exception NoSourceAvailable

type t

val create :
  ?position:OgamlMath.Vector3f.t ->
  ?velocity:OgamlMath.Vector3f.t ->
  ?orientation:OgamlMath.Vector3f.t ->
  AudioContext.t -> t

val stop : t -> unit

val pause : t -> unit

val resume : t -> unit

val status : t -> [`Playing | `Stopped | `Paused]

val position : t -> OgamlMath.Vector3f.t

val set_position : t -> OgamlMath.Vector3f.t -> unit

val velocity : t -> OgamlMath.Vector3f.t

val set_velocity : t -> OgamlMath.Vector3f.t -> unit

val orientation : t -> OgamlMath.Vector3f.t

val set_orientation : t -> OgamlMath.Vector3f.t -> unit

module LL : sig

  val play : 
    ?pitch:float ->
    ?gain:float ->
    ?loop:bool ->
    ?force:bool ->
    duration:float ->
    channels:[`Mono | `Stereo] ->
    buffer:AL.Buffer.t ->
    t -> unit

end
