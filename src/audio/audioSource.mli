
exception NoSourceAvailable

type t

val create :
  ?position:OgamlMath.Vector3f.t ->
  ?velocity:OgamlMath.Vector3f.t ->
  ?orientation:OgamlMath.Vector3f.t ->
  AudioContext.t -> t

(* Will raise NoSourceAvailable if force is true and no source is available,
   this could still happen in extreme cases. *)
val play : t ->
  ?pitch:float ->
  ?gain:float ->
  ?loop:bool ->
  ?force:bool -> (* NOTE : if [force] is true, then a source *must* be allocated *)
  SoundBuffer.t -> unit

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
