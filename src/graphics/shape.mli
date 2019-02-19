(** Creation and manipulation of 2D shapes *)

(** Type of shapes *)
type t

(** Creates a convex polygon given a list of points. *)
val create_polygon :
  points        : OgamlMath.Vector2f.t list ->
  color         : Color.t ->
  ?transform    : OgamlMath.Transform2D.t ->
  ?thickness    : float ->
  ?border_color : Color.t -> unit -> t

(** Creates a rectangle.
  * By default, its bottom-left corner is at (0,0). *)
val create_rectangle :
  size          : OgamlMath.Vector2f.t ->
  color         : Color.t ->
  ?transform    : OgamlMath.Transform2D.t ->
  ?thickness    : float ->
  ?border_color : Color.t -> unit -> t

(** Creates a regular polygon with a given number of vertices.
  * When this number is high, one can expect a circle.
  * By default, it is centered on (0,0). *)
val create_regular :
  radius        : float ->
  amount        : int ->
  color         : Color.t ->
  ?transform    : OgamlMath.Transform2D.t ->
  ?thickness    : float ->
  ?border_color : Color.t -> unit -> t

(** Creates a segment going from (0,0) to $segment$. *)
val create_segment :
  thickness : float ->
  color     : Color.t ->
  segment   : OgamlMath.Vector2f.t ->
  ?transform: OgamlMath.Transform2D.t -> unit -> t

(** Draws a shape. *)
val draw : 
    (module RenderTarget.T with type t = 'a) ->
    ?parameters:DrawParameter.t -> target:'a -> shape:t -> unit -> unit

(** Returns the vertex source of a shape.
  * The vertices only have color and position attributes. 
  * 
  * Note: the point of this function is to map or iterate through the source,
  * it should not be used to add vertices to this source. *)
val source : t -> VertexArray.SimpleVertex.T.s VertexArray.Source.t
