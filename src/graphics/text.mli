type t

val create :
  text : string ->
  position : OgamlMath.Vector2i.t ->
  font : Font.t ->
  ?color : Color.t ->
  size : int ->
  bold : bool ->
  unit -> t

val draw :
  ?parameters : DrawParameter.t ->
  text : t ->
  window : Window.t ->
  unit -> unit

val advance : t -> OgamlMath.Vector2f.t

val boundaries : t -> OgamlMath.FloatRect.t
