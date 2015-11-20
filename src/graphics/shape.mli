(** Module for creating 2D shapes *)

(** Type of shapes *)
type t

(** Creates a rectangle *)
val create_rectangle :
  x         : int ->
  y         : int ->
  width     : int ->
  height    : int ->
  color     : Color.t ->
  ?origin   : float * float ->
  ?rotation : float ->
  unit -> t


(** LL: Shouldn't be exposed *)

(** Get the underlying vertex array *)
val get_vertex_array : t -> VertexArray.static VertexArray.t
