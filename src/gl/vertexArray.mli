
exception Invalid_vertex of string

exception Invalid_attribute of string

exception Missing_attribute of string

module Vertex : sig

  type t

  val create : ?position:OgamlMath.Vector3f.t ->
               ?texcoord:(float * float)      ->
               ?normal:OgamlMath.Vector3f.t   ->
               ?color:Color.t -> unit -> t

end


module Source : sig

  type t

  val empty : ?position:string -> 
              ?normal  :string -> 
              ?texcoord:string ->
              ?color   :string ->
              size:int -> t

  val add : t -> Vertex.t -> t

  val (<<) : t -> Vertex.t -> t

end

type static

type dynamic

type 'a t 

val static : Source.t -> static t

val dynamic : Source.t -> dynamic t

val rebuild : dynamic t -> Source.t -> dynamic t

val bind : State.t -> 'a t -> Program.t -> unit

val length : 'a t -> int


