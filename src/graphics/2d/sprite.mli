(** Creation and manipulation of 2D sprites *)

exception Sprite_error of string

(** Type of sprites *)
type t

(** Creates a sprite. *)
val create :
  texture   : Texture.Texture2D.t ->
  ?subrect  : OgamlMath.IntRect.t ->
  ?origin   : OgamlMath.Vector2f.t ->
  ?position : OgamlMath.Vector2f.t ->
  ?scale    : OgamlMath.Vector2f.t ->
  ?size     : OgamlMath.Vector2f.t ->
  ?rotation : float ->
  unit -> t

(*type debug_times = {
  mutable size_get_t : float;
  mutable uniform_create_t : float;
  mutable source_alloc_t : float;
  mutable vertices_create_t : float;
  mutable vao_create_t : float;
  mutable draw_t : float;
}

val debug_t : debug_times*)

(** Draws a sprite. *)
val draw : 
  (module RenderTarget.T with type t = 'a) ->
  ?parameters:DrawParameter.t -> target:'a -> sprite:t -> unit -> unit

val to_source : t -> VertexArray.SimpleVertex.T.s VertexArray.VertexSource.t -> unit

(** Outputs a sprite to a vertex array source by mapping its vertices.
  *
  * See $to_source$ for more information. *)
val map_to_source : t -> 
                    (VertexArray.SimpleVertex.T.s VertexArray.Vertex.t -> 'b VertexArray.Vertex.t) -> 
                    'b VertexArray.VertexSource.t -> unit

(** Sets the position of the origin of the sprite in the window. *)
val set_position : t -> OgamlMath.Vector2f.t -> unit

(** Sets the position of the origin with respect to the top-left corner of the
  * sprite. The origin is the center of all transformations. *)
val set_origin : t -> OgamlMath.Vector2f.t -> unit

(** Sets the angle of rotation of the sprite. *)
val set_rotation : t -> float -> unit

(** Sets the scale of the sprite. *)
val set_scale : t -> OgamlMath.Vector2f.t -> unit

(** Sets the base size of the sprite *)
val set_size : t -> OgamlMath.Vector2f.t -> unit

(** Translates the sprite by the given vector. *)
val translate : t -> OgamlMath.Vector2f.t -> unit

(** Rotates the sprite by the given angle. *)
val rotate : t -> float -> unit

(** Scales the sprite. *)
val scale : t -> OgamlMath.Vector2f.t -> unit

(** Returns the position of the origin in window coordinates. *)
val position : t -> OgamlMath.Vector2f.t

(** Returns the position of the origin with respect to the first point of the
  * sprite. *)
val origin : t -> OgamlMath.Vector2f.t

(** Returns the base size of the sprite *)
val size : t -> OgamlMath.Vector2f.t

(** Returns the angle of rotation of the sprite. *)
val rotation : t -> float

(** Returns the scale of the sprite. *)
val get_scale : t -> OgamlMath.Vector2f.t
