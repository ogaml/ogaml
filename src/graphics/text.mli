(* module Fx : sig

  type t

  type ('a,'b) iterator = 'a -> 'b -> ('b -> 'b) -> 'b

  type ('a,'b,'c) full_iter = ('a,'b) iterator * 'b * ('b -> 'c)

  val create :
    text : string ->
    position : OgamlMath.Vector2f.t ->
    font : Font.t ->
    ?color :

end *)

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
