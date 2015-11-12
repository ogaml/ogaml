
exception Invalid_buffer of string

exception Invalid_vertex of string

exception Invalid_attribute of string

exception Missing_attribute of string

module Vertex : sig

  type t

  val create : ?position:OgamlMath.Vector3f.t ->
               ?texcoord:OgamlMath.Vector2f.t ->
               ?normal:OgamlMath.Vector3f.t   ->
               ?color:Color.t -> unit -> t

end


module Source : sig

  type t

  val empty : ?position:string -> 
              ?normal  :string -> 
              ?texcoord:string ->
              ?color   :string ->
              size:int -> unit -> t

  val requires_position : t -> bool

  val requires_normal   : t -> bool

  val requires_uv : t -> bool

  val requires_color : t -> bool

  val add : t -> Vertex.t -> unit

  val (<<) : t -> Vertex.t -> t

  val length : t -> int

end

type static

type dynamic

type 'a t 

val static : Source.t -> static t

val dynamic : Source.t -> dynamic t

val rebuild : dynamic t -> Source.t -> dynamic t

val length : 'a t -> int

val destroy : 'a t -> unit


module LL : sig

  val bind : State.t -> 'a t -> Program.t -> unit

end

