(** This module provides a way to easily construct
  * a list of uniforms to be passed to a program
  * when drawing 
**)

(** Type of a set of uniforms *)
type t

(** An empty uniform set *)
val empty : t

(** Adds a vector3f to a uniform structure *)
val vector3f : string -> OgamlMath.Vector3f.t -> t -> (t, [> `Duplicate_uniform of string]) result

(** Adds a vector3f to a uniform structure, replacing any previously existing uniform with the same name *)
val vector3f_r : string -> OgamlMath.Vector3f.t -> t -> t

(** Adds a vector2f to a uniform structure *)
val vector2f : string -> OgamlMath.Vector2f.t -> t -> (t, [> `Duplicate_uniform of string]) result

(** Adds a vector2f to a uniform structure, replacing any previously existing uniform with the same name *)
val vector2f_r : string -> OgamlMath.Vector2f.t -> t -> t

(** Adds a vector3i to a uniform structure *)
val vector3i : string -> OgamlMath.Vector3i.t -> t -> (t, [> `Duplicate_uniform of string]) result

(** Adds a vector3i to a uniform structure, replacing any previously existing uniform with the same name *)
val vector3i_r : string -> OgamlMath.Vector3i.t -> t -> t

(** Adds a vector2i to a uniform structure *)
val vector2i : string -> OgamlMath.Vector2i.t -> t -> (t, [> `Duplicate_uniform of string]) result

(** Adds a vector2i to a uniform structure, replacing any previously existing uniform with the same name *)
val vector2i_r : string -> OgamlMath.Vector2i.t -> t -> t

(** Adds an integer to a uniform structure *)
val int : string -> int -> t -> (t, [> `Duplicate_uniform of string]) result

(** Adds an integer to a uniform structure, replacing any previously existing uniform with the same name *)
val int_r : string -> int -> t -> t

(** Adds a float to a uniform structure *)
val float : string -> float -> t -> (t, [> `Duplicate_uniform of string]) result

(** Adds a float to a uniform structure, replacing any previously existing uniform with the same name *)
val float_r : string -> float -> t -> t

(** Adds a matrix3D to a uniform structure *)
val matrix3D : string -> OgamlMath.Matrix3D.t -> t -> (t, [> `Duplicate_uniform of string]) result

(** Adds a matrix3D to a uniform structure, replacing any previously existing uniform with the same name *)
val matrix3D_r : string -> OgamlMath.Matrix3D.t -> t -> t

(** Adds a matrix2D to a uniform structure *)
val matrix2D : string -> OgamlMath.Matrix2D.t -> t -> (t, [> `Duplicate_uniform of string]) result

(** Adds a matrix2D to a uniform structure, replacing any previously existing uniform with the same name *)
val matrix2D_r : string -> OgamlMath.Matrix2D.t -> t -> t

(** Adds a color to a uniform structure *)
val color : string -> Color.t -> t -> (t, [> `Duplicate_uniform of string]) result

(** Adds a color to a uniform structure, replacing any previously existing uniform with the same name *)
val color_r : string -> Color.t -> t -> t

(** Adds a 2D texture to a uniform structure *)
val texture2D : string -> ?tex_unit:int -> Texture.Texture2D.t -> t -> (t, [> `Duplicate_uniform of string]) result

(** Adds a 2D texture to a uniform structure, replacing any previously existing uniform with the same name *)
val texture2D_r : string -> ?tex_unit:int -> Texture.Texture2D.t -> t -> t

(** Adds a 2D depth texture to a uniform structure *)
val depthtexture2D : string -> ?tex_unit:int -> Texture.DepthTexture2D.t -> t -> (t, [> `Duplicate_uniform of string]) result

(** Adds a 2D depth texture to a uniform structure, replacing any previously existing uniform with the same name *)
val depthtexture2D_r : string -> ?tex_unit:int -> Texture.DepthTexture2D.t -> t -> t

(** Adds a 2D depth texture to a uniform structure as a shadow sampler.
  * $comparison$ defaults to $Texture.CompareFunction.LEqual$ *)
val shadow2D : string -> ?tex_unit:int -> ?comparison:Texture.CompareFunction.t -> Texture.DepthTexture2D.t -> t -> (t, [> `Duplicate_uniform of string]) result

(** Adds a 2D depth texture to a uniform structure as a shadow sampler, replacing any previously existing uniform with the same name.
  * $comparison$ defaults to $Texture.CompareFunction.LEqual$ *)
val shadow2D_r : string -> ?tex_unit:int -> ?comparison:Texture.CompareFunction.t -> Texture.DepthTexture2D.t -> t -> t

(** Adds a 3D texture to a uniform structure *)
val texture3D : string -> ?tex_unit:int -> Texture.Texture3D.t -> t -> (t, [> `Duplicate_uniform of string]) result

(** Adds a 3D texture to a uniform structure, replacing any previously existing uniform with the same name *)
val texture3D_r : string -> ?tex_unit:int -> Texture.Texture3D.t -> t -> t

(** Adds a 2D texture array to a uniform structure *)
val texture2Darray : string -> ?tex_unit:int -> Texture.Texture2DArray.t -> t -> (t, [> `Duplicate_uniform of string]) result

(** Adds a 2D texture array to a uniform structure, replacing any previously existing uniform with the same name *)
val texture2Darray_r : string -> ?tex_unit:int -> Texture.Texture2DArray.t -> t -> t

(** Adds a cubemap texture to a uniform structure *)
val cubemap : string -> ?tex_unit:int -> Texture.Cubemap.t -> t -> (t, [> `Duplicate_uniform of string]) result

(** Adds a cubemap texture to a uniform structure, replacing any previously existing uniform with the same name *)
val cubemap_r : string -> ?tex_unit:int -> Texture.Cubemap.t -> t -> t


module LL : sig

  (** Binds a value to some program uniforms *)
  val bind : Context.t -> t -> Program.Uniform.t list -> 
    (unit, [> `Invalid_uniform_type of string
            | `Invalid_texture_unit of int
            | `Missing_uniform of string
            | `Too_many_textures]) result

end
