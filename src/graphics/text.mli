type t

val create :
  text : string ->
  position : OgamlMath.Vector2i.t ->
  font : Font.t ->
  size : int ->
  bold : bool ->
  t

val draw : ?parameters:DrawParameter.t -> text:t -> window:Window.t -> unit -> unit
