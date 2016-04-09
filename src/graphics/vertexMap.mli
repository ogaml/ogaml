
exception Invalid_source of string

exception Invalid_vertex of string

exception Invalid_attribute of string

exception Missing_attribute of string

exception Out_of_bounds of string


module Vertex : sig

  type data = 
    | Vector3f of OgamlMath.Vector3f.t
    | Vector2f of OgamlMath.Vector2f.t
    | Vector3i of OgamlMath.Vector3i.t
    | Vector2i of OgamlMath.Vector2i.t
    | Int   of int
    | Float of float
    | Color of Color.t

  type t

  val empty : t

  val vector3f : string -> OgamlMath.Vector3f.t -> t -> t

  val vector2f : string -> OgamlMath.Vector2f.t -> t -> t

  val vector3i : string -> OgamlMath.Vector3i.t -> t -> t

  val vector2i : string -> OgamlMath.Vector2i.t -> t -> t

  val int : string -> int -> t -> t

  val float : string -> float -> t -> t

  val color : string -> Color.t -> t -> t

  val data : string -> data -> t -> t

  val attribute : t -> string -> data

end


module Source : sig

  type t

  val empty : unit -> t

  val add : t -> Vertex.t -> unit

  val (<<) : t -> Vertex.t -> t

  val length : t -> int

  val append : t -> t -> t

  val iter : t -> (Vertex.t -> unit) -> unit

  val map : t -> (Vertex.t -> Vertex.t) -> t

  val mapto : t -> (Vertex.t -> Vertex.t) -> t -> unit

  val from_array : VertexArray.Source.t -> t

  val from_array_to : VertexArray.Source.t -> t -> unit

  val map_array : VertexArray.Source.t -> (VertexArray.Vertex.t -> Vertex.t) -> t

  val map_array_to : VertexArray.Source.t -> (VertexArray.Vertex.t -> Vertex.t) -> t -> unit

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
  ?uniform    : Uniform.t ->
  ?parameters : DrawParameter.t ->
  ?start     : int ->
  ?length    : int ->
  ?mode      : DrawMode.t ->
  unit -> unit


