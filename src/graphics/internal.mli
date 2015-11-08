(** Provides unsafe access to the internal openGL state.        
  *
  * All functions in this module modify the GL context 
  * without further verification.
  *
  * Any call to one of these functions should be followed
  * by an update of the current window's State.t
  *
  * NOTE : For internal use only, may cause bugs 
**)


(** Represents openGL data internally *)
module Data : sig

  (** Type of data *)
  type t  

  (** Creates some data, the integer must be the expected size *)
  val create : int -> t

  (** Adds a vector3f to the data *)
  val add_3f : t -> OgamlMath.Vector3f.t -> unit

  (** Adds a color to the data *)
  val add_color : t -> Color.t -> unit

  (** Adds two floats to the data *)
  val add_2f : t -> float * float -> unit

  (** Returns the data associated to a matrix TEMPORARY *)
  val of_matrix : OgamlMath.Matrix3D.t -> t

  (** Returns the length of some data*)
  val length : t -> int

  (** Returns the data at position i (debug only) *)
  val get : t -> int -> float

end


(** Default openGL functions functions *)
module Pervasives : sig

  (** Clears the current display buffer *)
  val clear : bool -> bool -> bool -> unit

  (** Sets the clear color *)
  val color : float -> float -> float -> float -> unit

  (** Sets the current culling mode *)
  val culling : DrawParameter.CullingMode.t -> unit

  (** Sets the current polygon mode *)
  val polygon : DrawParameter.PolygonMode.t -> unit

  (** Returns the current glsl version *)
  val glsl_version : unit -> string

  (** Returns the current gl version *)
  val gl_version : unit -> string

  (** Returns the maximal number of textures *)
  val max_textures : unit -> int

end


(** Represents an openGL texture *)
module Texture : sig

  (** Abstract texture type *)
  type t

  (** Creates an empty texture *)
  val create : unit -> t

  (** Activates a texture binding point *)
  val activate : int -> unit

  (** Binds a texture to the current point with a given format *)
  val bind : Enum.TextureTarget.t -> t option -> unit

  (** Associates an image with the currently bound texture *)
  val image : Enum.TextureTarget.t -> Enum.PixelFormat.t -> (int * int) 
    -> Enum.TextureFormat.t -> Bytes.t -> unit

  (** Sets the value of a parameter of the currently bound texture2D *)
  val parameter2D : [`Magnify of Enum.MagnifyFilter.t 
                    |`Minify  of Enum.MinifyFilter.t] -> unit

  (** Deletes a texture from the memory *)
  val destroy : t -> unit

end


(** Represents an openGL shader *)
module Shader : sig

  (** Abstract shader type *)
  type t

  (** Creates an empty shader *)
  val create : Enum.ShaderType.t -> t

  (** Returns true iff the shader is valid *)
  val valid : t -> bool

  (** Adds a source to a shader *)
  val source : t -> string -> unit

  (** Compiles a shader *)
  val compile : t -> unit

  (** Returns the compilation status of a shader *)
  val status : t -> bool

  (** Returns the information log about the compilation *)
  val log : t -> string

end


(** Represents an openGL program *)
module Program : sig

  (** Abstract program type *)
  type t

  (** Abstract uniform location *)
  type u_location

  (** Abstract attribute location *)
  type a_location

  (** Creates an empty program *)
  val create : unit -> t

  (** Returns true iff the program is valid *)
  val valid : t -> bool

  (** Attaches a shader to a program *)
  val attach : t -> Shader.t -> unit

  (** Links the program *)
  val link : t -> unit

  (** Returns the location of a uniform *)
  val uloc : t -> string -> u_location

  (** Returns the location of an attribute *)
  val aloc : t -> string -> a_location

  (** Returns the name of a uniform from its index *)
  val uname : t -> int -> string

  (** Returns the name of an attribute from its index *)
  val aname : t -> int -> string

  (** Returns the type of a uniform from its index *)
  val utype : t -> int -> Enum.GlslType.t

  (** Returns the type of an attribute from its index *)
  val atype : t -> int -> Enum.GlslType.t

  (** Returns the number of uniforms *)
  val ucount : t -> int

  (** Returns the number of attributes *)
  val acount : t -> int

  (** Uses the program *)
  val use : t option -> unit

  (** Returns true iff the linking was successful *)
  val status : t -> bool

  (** Returns the log of the program *)
  val log : t -> string

end


(** Represents an openGL buffer *)
module VBO : sig

  (** Type of a VBO *)
  type t

  (** Creates a VBO *)
  val create : unit -> t

  (** Binds a VBO for modification/drawing *)
  val bind : t option -> unit

  (** Sets the data of the currently bound VBO *)
  val data : int -> Data.t option -> Enum.VBOKind.t -> unit

  (** Sets some subset of the data of the currently bound VBO *)
  val subdata : int -> int -> Data.t -> unit

  (** Destroys a VBO *)
  val destroy : t -> unit

end


(** Represents an openGL vertex array *)
module VAO : sig

  (** Type of a VAO *)
  type t

  (** Creates a VAO *)
  val create : unit -> t

  (** Binds a VAO *)
  val bind : t option -> unit

  (** Destroys a VAO *)
  val destroy : t -> unit

  (** Enables an attribute for use *)
  val enable_attrib : Program.a_location -> unit

  (** Binds a floating point attribute to an offset and a type in a VBO *)
  val attrib_float : Program.a_location -> int -> Enum.GlFloatType.t -> int -> int -> unit

  (** Binds an integer attribute to an offset and a type in a VBO *)
  val attrib_int : Program.a_location -> int -> Enum.GlIntType.t -> int -> int -> unit

  (** Draws the currently bound VAO *)
  val draw : Enum.DrawMode.t -> int -> int -> unit

end


(** Uniform bindings *)
module Uniform : sig

  val float1 : Program.u_location -> float -> unit

  val float2 : Program.u_location -> float -> float -> unit

  val float3 : Program.u_location -> float -> float -> float -> unit

  val float4 : Program.u_location -> float -> float -> float -> float ->unit

  val int1 : Program.u_location -> int -> unit

  val int2 : Program.u_location -> int -> int -> unit

  val int3 : Program.u_location -> int -> int -> int -> unit

  val int4 : Program.u_location -> int -> int -> int -> int ->unit

  val uint1 : Program.u_location -> int -> unit

  val uint2 : Program.u_location -> int -> int -> unit

  val uint3 : Program.u_location -> int -> int -> int -> unit

  val uint4 : Program.u_location -> int -> int -> int -> int ->unit

  val mat2  : Program.u_location -> Data.t -> unit

  val mat23 : Program.u_location -> Data.t -> unit

  val mat24 : Program.u_location -> Data.t -> unit

  val mat32 : Program.u_location -> Data.t -> unit

  val mat3  : Program.u_location -> Data.t -> unit

  val mat34 : Program.u_location -> Data.t -> unit

  val mat42 : Program.u_location -> Data.t -> unit

  val mat43 : Program.u_location -> Data.t -> unit

  val mat4  : Program.u_location -> Data.t -> unit

end


