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

  val create :
    (module RenderTarget.T with type t = 'a) ->
    target : 'a ->
    text : string ->
    position : OgamlMath.Vector2f.t ->
    font : Font.t ->
    colors : (Font.code,'b,Color.t list) full_it ->
    size : int ->
    unit -> (t, [> `Invalid_UTF8_bytes | `Invalid_UTF8_leader]) result

  val draw :
    (module RenderTarget.T with type t = 'a) ->
    ?parameters : DrawParameter.t ->
    text : t ->
    target : 'a ->
    unit -> 
    (unit, [> `Font_texture_size_overflow | `Font_texture_depth_overflow]) result

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
  unit -> (t, [> `Invalid_UTF8_bytes | `Invalid_UTF8_leader]) result

val draw :
  (module RenderTarget.T with type t = 'a) ->
  ?parameters : DrawParameter.t ->
  text : t ->
  target : 'a ->
  unit -> 
  (unit, [> `Font_texture_size_overflow | `Font_texture_depth_overflow]) result

val to_source : t -> VertexArray.SimpleVertex.T.s VertexArray.Source.t -> 
    (unit, [> `Missing_attribute of string]) result

val map_to_source : t -> 
                    (VertexArray.SimpleVertex.T.s VertexArray.Vertex.t -> 'b VertexArray.Vertex.t) -> 
                    'b VertexArray.Source.t -> 
                    (unit, [> `Missing_attribute of string]) result

val advance : t -> OgamlMath.Vector2f.t

val boundaries : t -> OgamlMath.FloatRect.t
