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
  type ('a, 'b) t = ('a, 'b, Bigarray.c_layout) Bigarray.Array1.t

  (** Gets data from a float array *)
  val of_float_array : float array -> (float, Bigarray.float32_elt) t

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

  (** Creates an empty program *)
  val create : unit -> t

  (** Attaches a shader to a program *)
  val attach : t -> Shader.t -> unit

  (** Links the program *)
  val link : t -> unit

  (** Returns the location of a uniform *)
  val uloc : t -> string -> int

  (** Returns the location of an attribute *)
  val aloc : t -> string -> int

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
  val data : int -> ('a, 'b) Data.t option -> Enum.VBOKind.t -> unit

  (** Sets some subset of the data of the currently bound VBO *)
  val subdata : int -> int -> ('a, 'b) Data.t -> unit

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
  val enable_attrib : int -> unit

  (** Binds a floating point attribute to an offset and a type in a VBO *)
  val attrib_float : int -> int -> Enum.GlFloatType.t -> int -> int -> unit

  (** Binds an integer attribute to an offset and a type in a VBO *)
  val attrib_int : int -> int -> Enum.GlIntType.t -> int -> int -> unit

  (** Draws the currently bound VAO *)
  val draw : Enum.DrawMode.t -> int -> int -> unit

end




