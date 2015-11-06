(** This module provides a way to easily construct
  * a list of uniforms to be passed to a program
  * when drawing 
**)

(** Raised when trying to bind a non-provided uniform *)
exception Unknown_uniform of string

(** Raised when trying to bind a uniform with the wrong type *)
exception Invalid_uniform of string

(** Type of a set of uniforms *)
type t

(** An empty uniform set *)
val empty : t

(** Adds a vector3f to a uniform structure *)
val vector3f : string -> OgamlMath.Vector3f.t -> t -> t

(** Adds a matrix3D to a uniform structure *)
val matrix3D : string -> OgamlMath.Matrix3D.t -> t -> t

(** Adds a color to a uniform structure *)
val color : string -> Color.t -> t -> t

(** Binds a value to a program uniform *)
val bind : t -> Program.Uniform.t -> unit

