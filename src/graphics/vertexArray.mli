
exception Invalid_source of string

exception Invalid_vertex of string

exception Invalid_attribute of string

exception Missing_attribute of string

exception Out_of_bounds of string


module Vertex : sig

  type t

  val create : ?position:OgamlMath.Vector3f.t ->
               ?texcoord:OgamlMath.Vector2f.t ->
               ?normal:OgamlMath.Vector3f.t   ->
               ?color:Color.t -> unit -> t
  
  val position : t -> OgamlMath.Vector3f.t option

  val texcoord : t -> OgamlMath.Vector2f.t option

  val normal : t -> OgamlMath.Vector3f.t option

  val color : t -> Color.t option

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

  val attrib_position : t -> string option

  val attrib_normal : t -> string option

  val attrib_uv : t -> string option

  val attrib_color : t -> string option

  val add : t -> Vertex.t -> unit

  val (<<) : t -> Vertex.t -> t

  val length : t -> int

  val append : t -> t -> t

  val get : t -> int -> Vertex.t

  val iter : t -> (Vertex.t -> unit) -> unit

  val map : t -> (Vertex.t -> Vertex.t) -> t

  val mapto : t -> (Vertex.t -> Vertex.t) -> t -> unit

end


type debug_times = {
  mutable param_bind_t : float;
  mutable program_bind_t : float;
  mutable uniform_bind_t : float;
  mutable vao_bind_t : float;
  mutable draw_t : float
}

val debug_t : debug_times


type static

type dynamic

type 'a t 

val static : State.t -> Source.t -> static t

val dynamic : State.t -> Source.t -> dynamic t

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

