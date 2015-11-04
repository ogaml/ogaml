(** Represents an OpenGL state and keeps track of bound
  * values to avoid costly successive bindings.
  * 
  * Note that setters do not change the value stored
  * by the internal GL state and should not be used alone.
  *
  * NOTE : this module is mostly intended for internal use only
**)


(** Type of the GL state *)
type t

(** Creates a new, default-initialized GL state *)
val create : unit -> t

(** Returns the current OpenGL version. Format : (major, minor) *)
val version : t -> (int * int)

(** Returns true iff the OpenGL version passed as parameter is supported *)
val is_version_supported : t -> (int * int) -> bool

(** Returns the current GLSL version *)
val glsl_version : t -> int

(** Returns true iff the GLSL version passed as parameter is supported *)
val is_glsl_version_supported : t -> int -> bool

(** Returns the current culling mode *)
val culling_mode : t -> Enum.CullingMode.t

(** Sets the current culling mode *)
val set_culling_mode : t -> Enum.CullingMode.t -> unit

(** Returns the current polygon drawing mode *)
val polygon_mode : t -> Enum.PolygonMode.t

(** Sets the current polygon drawing mode *)
val set_polygon_mode : t -> Enum.PolygonMode.t -> unit

(** Returns the currently active texture unit *)
val texture_unit : t -> int

(** Sets the currently active texture unit *)
val set_texture_unit : t -> int -> unit

(** Returns the texture currently bound to a texture unit *)
val bound_texture : t -> int -> Internal.Texture.t

(** Sets the currently bound texture to a texture unit *)
val set_bound_texture : t -> int -> Internal.Texture.t -> unit







