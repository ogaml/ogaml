
exception Invalid_source of string

exception Invalid_vertex of string

exception Invalid_attribute of string

exception Missing_attribute of string


module Vertex : sig

  type t

  val empty : t

  val vector3f : string -> OgamlMath.Vector3f.t -> t -> t

  val vector2f : string -> OgamlMath.Vector2f.t -> t -> t

  val vector3i : string -> OgamlMath.Vector3i.t -> t -> t

  val vector2i : string -> OgamlMath.Vector2i.t -> t -> t

  val int : string -> int -> t -> t

  val float : string -> float -> t -> t

  val color : string -> Color.t -> t -> t

end


module Source : sig

  type t

  val empty : unit -> t

  val add : t -> Vertex.t -> unit

  val (<<) : t -> Vertex.t -> t

  val length : t -> int

end


type static

type dynamic

type 'a t 

val static : Source.t -> static t

val dynamic : Source.t -> dynamic t

val rebuild : dynamic t -> Source.t -> int -> unit

val length : 'a t -> int

val draw :
  vertices   : 'a t ->
  window     : Window.t ->
  ?indices   : 'b IndexArray.t ->
  program    : Program.t ->
  uniform    : Uniform.t ->
  parameters : DrawParameter.t ->
  mode       : DrawMode.t ->
  unit -> unit


