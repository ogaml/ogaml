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


