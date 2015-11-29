(** Creation and manipulation of 2D sprites *)

(** Type of sprites *)
type t

(** Creates a sprite. *)
val create :
  texture   : Texture.Texture2D.t ->
  ?origin   : OgamlMath.Vector2f.t ->
  ?position : OgamlMath.Vector2i.t ->
  ?scale    : OgamlMath.Vector2f.t ->
  ?rotation : float ->
  unit -> t

(** Draws a sprite. *)
val draw : window:Window.t -> sprite:t -> unit

(** Sets the position of the origin of the sprite in the window. *)
val set_position : t -> OgamlMath.Vector2i.t -> unit

(** Sets the position of the origin with respect to the top-left corner of the
  * sprite. The origin is the center of all transformations. *)
val set_origin : t -> OgamlMath.Vector2f.t -> unit

(** Sets the angle of rotation of the sprite. *)
val set_rotation : t -> float -> unit

(** Sets the scale of the sprite. *)
val set_scale : t -> OgamlMath.Vector2f.t -> unit

(** Translates the sprite by the given vector. *)
val translate : t -> OgamlMath.Vector2i.t -> unit

(** Rotates the sprite by the given angle. *)
val rotate : t -> float -> unit

(** Scales the sprite. *)
val scale : t -> OgamlMath.Vector2f.t -> unit

(** Returns the position of the origin in window coordinates. *)
val get_position : t -> OgamlMath.Vector2i.t

(** Returns the position of the origin with respect to the first point of the
  * sprite. *)
val get_origin : t -> OgamlMath.Vector2f.t

(** Returns the angle of rotation of the sprite. *)
val get_rotation : t -> float

(** Returns the scale of the sprite. *)
val get_scale : t -> OgamlMath.Vector2f.t
