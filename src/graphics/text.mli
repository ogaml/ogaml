module Fx : sig

  type t

  type ('a,'b) it = 'a -> 'b -> ('b -> 'b) -> 'b

  type ('a,'b,'c) full_it = ('a,'b) it * 'b * ('b -> 'c)

  val forall : 'c -> ('a,'c list,'c list) full_it

  (* TODO: Exception when the iterator doesn't return list of right size *)
  val create :
    text : string ->
    position : OgamlMath.Vector2f.t ->
    font : Font.t ->
    colors : (Font.code,'b,Color.t list) full_it ->
    size : int ->
    unit -> t

  val draw :
    ?parameters : DrawParameter.t ->
    text : t ->
    window : Window.t ->
    unit -> unit

end

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
