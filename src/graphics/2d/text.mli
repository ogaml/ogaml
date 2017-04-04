module Fx : sig

  type t

  type ('a,'b) it = 'a -> 'b -> ('b -> 'b) -> 'b

  type ('a,'b,'c) full_it = ('a, 'b) it * 'b * ('b -> 'c)

  val forall : 'c -> ('a, 'c list, 'c list) full_it

  val foreach : ('a -> 'b) -> ('a, 'b list, 'b list) full_it

  val foreachi : ('a -> int -> 'b) -> ('a, 'b list * int, 'b list) full_it

  val foreachword :
    (Font.code list -> 'a) -> 'a ->
    (Font.code, 'a list * Font.code list, 'a list) full_it

  (* TODO: Exception when the iterator doesn't return list of right size *)
  val create :
    (module RenderTarget.T with type t = 'a) ->
    target : 'a ->
    text : string ->
    position : OgamlMath.Vector2f.t ->
    font : Font.t ->
    colors : (Font.code,'b,Color.t list) full_it ->
    size : int ->
    unit -> t

  val draw :
    (module RenderTarget.T with type t = 'a) ->
    ?parameters : DrawParameter.t ->
    text : t ->
    target : 'a ->
    unit -> unit

  val advance : t -> OgamlMath.Vector2f.t

  val boundaries : t -> OgamlMath.FloatRect.t

end

type t

val create :
  text : string ->
  position : OgamlMath.Vector2f.t ->
  font : Font.t ->
  ?color : Color.t ->
  size  : int ->
  ?bold : bool ->
  unit -> t

val draw :
  (module RenderTarget.T with type t = 'a) ->
  ?parameters : DrawParameter.t ->
  text : t ->
  target : 'a ->
  unit -> unit

val to_source : t -> VertexArray.SimpleVertex.T.s VertexArray.Source.t -> unit

val map_to_source : t -> 
                    (VertexArray.SimpleVertex.T.s VertexArray.Vertex.t -> 'b VertexArray.Vertex.t) -> 
                    'b VertexArray.Source.t -> unit

val advance : t -> OgamlMath.Vector2f.t

val boundaries : t -> OgamlMath.FloatRect.t
