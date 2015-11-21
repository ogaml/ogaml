(** Module for creating 2D shapes *)

(** Type of shapes *)
type t

(** Creates a convex polygon given a list of points.
  * points is this list of points,
  * origin is the origin of the polygon whoose coordinates are taken with
  * respect to the first point of points (which is also the default origin) *)
val create_polygon :
  points    : OgamlMath.Vector2i.t list ->
  color     : Color.t ->
  ?origin   : OgamlMath.Vector2f.t ->
  ?position : OgamlMath.Vector2i.t ->
  ?scale    : OgamlMath.Vector2f.t ->
  ?rotation : float ->
  unit -> t

(** Creates a rectangle *)
val create_rectangle :
  position  : OgamlMath.Vector2i.t ->
  size      : OgamlMath.Vector2i.t ->
  color     : Color.t ->
  ?origin   : OgamlMath.Vector2f.t ->
  ?scale    : OgamlMath.Vector2f.t ->
  ?rotation : float ->
  unit -> t


(** LL: Shouldn't be exposed *)

(** Get the underlying vertex array *)
val get_vertex_array : t -> VertexArray.static VertexArray.t
