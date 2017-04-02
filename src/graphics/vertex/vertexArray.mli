
module Vertex : sig

  exception Sealed_vertex of string

  exception Unsealed_vertex of string

  exception Unbound_attribute of string

  type 'a t


  module AttributeType : sig

    type 'a s

    val int : int s

    val vector2i : OgamlMath.Vector2i.t s

    val vector3i : OgamlMath.Vector3i.t s

    val float : float s

    val vector2f : OgamlMath.Vector2f.t s

    val vector3f : OgamlMath.Vector3f.t s

    val color : Color.t s

  end


  module Attribute : sig

    type ('a, 'b) s

    val set : 'b t -> ('a, 'b) s -> 'a -> unit

    val get : 'b t -> ('a, 'b) s -> 'a

    val name : ('a, 'b) s -> string

    val divisor : ('a, 'b) s -> int

    val atype : ('a, 'b) s -> 'a AttributeType.s

  end


  module type VERTEX = sig

    type s

    val attribute : string -> ?divisor:int -> 'a AttributeType.s -> ('a, s) Attribute.s

    val seal : unit -> unit

    val create : unit -> s t

    val copy : s t -> s t

  end


  val make : unit -> (module VERTEX)

end


module SimpleVertex : sig

  module T : Vertex.VERTEX

  val create : 
    ?position:OgamlMath.Vector3f.t ->
    ?color:Color.t ->
    ?uv:OgamlMath.Vector2f.t ->
    ?normal:OgamlMath.Vector3f.t -> unit -> T.s Vertex.t

  val position : (OgamlMath.Vector3f.t, T.s) Vertex.Attribute.s

  val color : (Color.t, T.s) Vertex.Attribute.s

  val uv : (OgamlMath.Vector2f.t, T.s) Vertex.Attribute.s

  val normal : (OgamlMath.Vector3f.t, T.s) Vertex.Attribute.s

end


module VertexSource : sig

  exception Uninitialized_field of string

  exception Incompatible_sources 

  type 'a t

  val empty : ?size:int -> unit -> 'a t

  val add : 'a t -> 'a Vertex.t -> unit

  val (<<) : 'a t -> 'a Vertex.t -> 'a t

  val length : 'a t -> int

  val clear : 'a t -> unit

  val append : 'a t -> 'a t -> unit

  val iter : 'a t -> ?start:int -> ?length:int -> ('a Vertex.t -> unit) -> unit

  val map : 'a t -> ?start:int -> ?length:int -> ('a Vertex.t -> 'b Vertex.t) -> 'b t

  val map_to : 'a t -> ?start:int -> ?length:int -> ('a Vertex.t -> 'b Vertex.t) -> 'b t -> unit

end

exception Missing_attribute of string

exception Invalid_attribute of string

exception Out_of_bounds of string

type static

type dynamic

type ('a, 'b) t 

val static : (module RenderTarget.T with type t = 'a) 
              -> 'a -> 'b VertexSource.t -> (static, 'b) t

val dynamic : (module RenderTarget.T with type t = 'a) 
               -> 'a -> 'b VertexSource.t -> (dynamic, 'b) t

val rebuild : (module RenderTarget.T with type t = 'a)
               -> 'a -> (dynamic, 'b) t -> 'b VertexSource.t -> int -> unit

val length : (_, _) t -> int

val draw :
  (module RenderTarget.T with type t = 'a) ->
  vertices   : (_, _) t ->
  target     : 'a ->
  ?indices   : _ IndexArray.t ->
  program    : Program.t ->
  ?uniform    : Uniform.t ->
  ?parameters : DrawParameter.t ->
  ?start     : int ->
  ?length    : int ->
  ?mode      : DrawMode.t ->
  unit -> unit

