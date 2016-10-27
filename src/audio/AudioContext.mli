
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

val has_stereo_source_available : t -> bool

val has_mono_source_available : t -> bool

module LL : sig

  (** Returns an available source, if there is one *)
  val get_available_stereo_source : t -> AL.Source.t option

  val get_available_mono_source : t -> AL.Source.t option

  (** [allocate_stereo_source ctx src dur cbk] marks the source [src] as
    * allocated for [dur] seconds. The callback [cbk] will be called when the
    * source is de-allocated *)
  val allocate_stereo_source : t -> AL.Source.t -> float -> (unit -> unit) -> unit

  val allocate_mono_source : t -> AL.Source.t -> float -> (unit -> unit) -> unit

  (** Marks a source as de-allocated *)
  val deallocate_stereo_source : t -> AL.Source.t -> unit

  val deallocate_mono_source : t -> AL.Source.t -> unit

end

