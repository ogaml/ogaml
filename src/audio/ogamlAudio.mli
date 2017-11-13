
module AudioContext : sig

  exception Creation_error of string

  exception Destruction_error of string

  type t

  val create : 
    ?position:OgamlMath.Vector3f.t -> 
    ?velocity:OgamlMath.Vector3f.t ->
    ?look_at:OgamlMath.Vector3f.t ->
    ?up_dir:OgamlMath.Vector3f.t -> unit -> t

  val destroy : t -> unit

  val position : t -> OgamlMath.Vector3f.t

  val set_position : t -> OgamlMath.Vector3f.t -> unit

  val velocity : t -> OgamlMath.Vector3f.t

  val set_velocity : t -> OgamlMath.Vector3f.t -> unit

  val look_at : t -> OgamlMath.Vector3f.t

  val set_look_at : t -> OgamlMath.Vector3f.t -> unit

  val up_dir : t -> OgamlMath.Vector3f.t

  val set_up_dir : t -> OgamlMath.Vector3f.t -> unit

  val max_stereo_sources : t -> int

  val max_mono_sources : t -> int

  val has_stereo_source_available : t -> bool

  val has_mono_source_available : t -> bool

end


module AudioSource : sig

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

end


module SoundBuffer : sig

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
    t -> AudioSource.t -> unit

  val duration : t -> float

  val samples : t -> samples

  val channels : t -> [`Stereo | `Mono]

end


module AudioStream : sig

  type t

end

