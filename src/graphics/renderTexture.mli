
type t

val create : State.t -> OgamlMath.Vector2i.t -> t

val texture : t -> Texture.Texture2D.t

val size : t -> OgamlMath.Vector2i.t

val display : t -> unit

val clear : ?color:Color.t -> t -> unit

module LL : sig

  val programs : t -> ProgramLibrary.t

  val bind_draw_parameters : t -> DrawParameter.t -> unit

end
