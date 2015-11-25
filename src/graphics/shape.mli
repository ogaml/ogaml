(** Module for creating 2D shapes *)

(** Type of shapes *)
type t

(** Creates a convex polygon given a list of points.
  * points is this list of points,
  * origin is the origin of the polygon.
  * All coordinates are taken with respect to the top-left corner of the
  * shape. *)
val create_polygon :
  points    : OgamlMath.Vector2i.t list ->
  color     : Color.t ->
  ?origin   : OgamlMath.Vector2f.t ->
  ?position : OgamlMath.Vector2i.t ->
  ?scale    : OgamlMath.Vector2f.t ->
  ?rotation : float ->
  unit -> t

(** Creates a rectangle.
  * Its origin is positioned with respect to the top-left corner. *)
val create_rectangle :
  position  : OgamlMath.Vector2i.t ->
  size      : OgamlMath.Vector2i.t ->
  color     : Color.t ->
  ?origin   : OgamlMath.Vector2f.t ->
  ?scale    : OgamlMath.Vector2f.t ->
  ?rotation : float ->
  unit -> t

(** Creates a regular polygon with a given number of vertices.
  * When this number is high, one can expect a circle. *)
val create_regular :
  position  : OgamlMath.Vector2i.t ->
  radius    : float ->
  amount    : int ->
  color     : Color.t ->
  ?origin   : OgamlMath.Vector2f.t ->
  ?scale    : OgamlMath.Vector2f.t ->
  ?rotation : float ->
  unit -> t

(** Sets the position of the origin in the window. *)
val set_position : t -> OgamlMath.Vector2i.t -> unit

(** Sets the position of the origin with respect to the first point of the
  * shape. *)
val set_origin : t -> OgamlMath.Vector2f.t -> unit

(** Sets the angle of rotation of the shape. *)
val set_rotation : t -> float -> unit

(** Sets the scale of the shape. *)
val set_scale : t -> OgamlMath.Vector2f.t -> unit

(** Sets the filling color of the shape. *)
val set_color : t -> Color.t -> unit

(** Translates the shape by the given vector. *)
val translate : t -> OgamlMath.Vector2i.t -> unit

(** Rotates the shape by the given angle. *)
val rotate : t -> float -> unit

(** Scales the shape. *)
val scale : t -> OgamlMath.Vector2f.t -> unit

(** Returns the position of the origin in window coordinates. *)
val get_position : t -> OgamlMath.Vector2i.t

(** Returns the position of the origin with respect to the first point of the
  * shape. *)
val get_origin : t -> OgamlMath.Vector2f.t

(** Returns the angle of rotation of the sape. *)
val get_rotation : t -> float

(** Returns the scale of the shape. *)
val get_scale : t -> OgamlMath.Vector2f.t

(** Returns the filling color of the shape. *)
val get_color : t -> Color.t

(** LL: Shouldn't be exposed *)

(** Get the underlying vertex array. *)
val get_vertex_array : t -> VertexArray.static VertexArray.t
