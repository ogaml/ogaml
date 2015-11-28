(** Creation and manipulation of 2D sprites *)

(** Type of sprites *)
type t

(** Creates a sprite. *)
val create_sprite :
  texture   : Texture.Texture2D.t ->
  ?origin   : OgamlMath.Vector2f.t ->
  ?position : OgamlMath.Vector2i.t ->
  ?scale    : OgamlMath.Vector2f.t ->
  ?rotation : float ->
  unit -> t

(** Draws a sprite. *)
val draw : window:Window.t -> sprite:t -> unit
