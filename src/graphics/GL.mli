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


(** Low-level GL enumerations *)
module Types : sig

  (** Shader types enumeration *)
  module ShaderType : sig

    type t = 
      | Fragment
      | Vertex

  end

  (** GLSL types enumeration *)
  module GlslType : sig

    type t =
      | Int
      | Int2
      | Int3
      | Int4
      | Float
      | Float2
      | Float3
      | Float4
      | Float2x2
      | Float2x3
      | Float2x4
      | Float3x2
      | Float3x3
      | Float3x4
      | Float4x2
      | Float4x3
      | Float4x4
      | Sampler1D
      | Sampler2D
      | Sampler3D

  end

  (** Texture targets enumeration *)
  module TextureTarget : sig

    type t = 
      | Texture1D
      | Texture2D
      | Texture3D

  end

  (** Pixel format enumeration *)
  module PixelFormat : sig

    type t = 
      | R
      | RG
      | RGB
      | BGR
      | RGBA
      | BGRA
      | Depth
      | DepthStencil

  end

  (** Texture format enumeration *)
  module TextureFormat : sig

    type t = 
      | RGB
      | RGBA
      | Depth
      | DepthStencil

  end

  (** Texture minify filter values *)
  module MinifyFilter : sig

    type t = 
      | Nearest
      | Linear
      | NearestMipmap
      | LinearMipmap

  end

  (** Texture magnify filter values *)
  module MagnifyFilter : sig

    type t = 
      | Nearest
      | Linear

  end

  (** VBO kinds enumeration *)
  module VBOKind : sig

    type t = 
      | StaticDraw
      | DynamicDraw

  end

  (** GL float types *)
  module GlFloatType : sig

    type t = 
      | Byte
      | UByte
      | Short
      | UShort
      | Int
      | UInt
      | Float
      | Double

  end

  (** GL int types *)
  module GlIntType : sig

    type t  =
      | Byte
      | UByte
      | Short
      | UShort
      | Int
      | UInt

  end

end


(** Represents openGL data internally *)
module Data : sig

  (** Type of floats stored in data *)
  type float_32

  (** Type of ints stored in data *)
  type int_32

  (** Type of data using caml type 'a and storing type 'b *)
  type ('a, 'b) t  

  (** Creates some data, the integer must be the expected size *)
  val create_int : int -> (int32, int_32) t

  (** Creates some data, the integer must be the expected size *)
  val create_float : int -> (float, float_32) t

  (** Adds a vector3f to the data *)
  val add_3f : (float, float_32) t -> OgamlMath.Vector3f.t -> unit

  (** Adds a color to the data *)
  val add_color : (float, float_32) t -> Color.t -> unit

  (** Adds two floats to the data *)
  val add_2f : (float, float_32) t -> OgamlMath.Vector2f.t -> unit

  (** Adds an int to the data *)
  val add_int : (int32, int_32) t -> int -> unit

  (** Adds an int32 to the data *)
  val add_int32 : (int32, int_32) t -> int32 -> unit

  (** Returns the data associated to a matrix *)
  val of_matrix : OgamlMath.Matrix3D.t -> (float, float_32) t

  (** Returns the length of some data*)
  val length : ('a, 'b) t -> int

  (** Returns the data at position i (debug only) *)
  val get : ('a, 'b) t -> int -> 'a 

end


(** Default openGL functions *)
module Pervasives : sig

  (** Clears the current display buffer *)
  val clear : bool -> bool -> bool -> unit

  (** Sets the clear color *)
  val color : float -> float -> float -> float -> unit

  (** Sets the current culling mode *)
  val culling : DrawParameter.CullingMode.t -> unit

  (** Sets the current polygon mode *)
  val polygon : DrawParameter.PolygonMode.t -> unit

  (** Sets the current value of depth testing *)
  val depthtest : bool -> unit

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
  val bind : Types.TextureTarget.t -> t option -> unit

  (** Associates an image with the currently bound texture *)
  val image : Types.TextureTarget.t -> Types.PixelFormat.t -> (int * int) 
    -> Types.TextureFormat.t -> Bytes.t -> unit

  (** Sets the value of a parameter of the currently bound texture2D *)
  val parameter2D : [`Magnify of Types.MagnifyFilter.t 
                    |`Minify  of Types.MinifyFilter.t] -> unit

  (** Deletes a texture from the memory *)
  val destroy : t -> unit

end


(** Represents an openGL shader *)
module Shader : sig

  (** Abstract shader type *)
  type t

  (** Creates an empty shader *)
  val create : Types.ShaderType.t -> t

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
  val utype : t -> int -> Types.GlslType.t

  (** Returns the type of an attribute from its index *)
  val atype : t -> int -> Types.GlslType.t

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
  val data : int -> (float, Data.float_32) Data.t option -> Types.VBOKind.t -> unit

  (** Sets some subset of the data of the currently bound VBO *)
  val subdata : int -> int -> (float, Data.float_32) Data.t -> unit

  (** Destroys a VBO *)
  val destroy : t -> unit

end


(** Represents an openGL element buffer *)
module EBO : sig

  (** Type of an EBO *)
  type t

  (** Creates an EBO *)
  val create : unit -> t

  (** Binds an EBO *)
  val bind : t option -> unit

  (** Destroys an EBO *)
  val destroy : t -> unit

  (** Sets the data of the currently bound EBO *)
  val data : int -> (int32, Data.int_32) Data.t option -> Types.VBOKind.t -> unit

  (** Sets some subset of the data of the currently bound EBO *)
  val subdata : int -> int -> (int32, Data.int_32) Data.t -> unit

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
  val attrib_float : Program.a_location -> int -> Types.GlFloatType.t -> int -> int -> unit

  (** Binds an integer attribute to an offset and a type in a VBO *)
  val attrib_int : Program.a_location -> int -> Types.GlIntType.t -> int -> int -> unit

  (** Draws the currently bound VAO *)
  val draw : DrawMode.t -> int -> int -> unit

  (** Draws an element array using the currently bound VAO and EBO *)
  val draw_elements : DrawMode.t -> int -> unit

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

  val mat2  : Program.u_location -> (float, Data.float_32) Data.t -> unit

  val mat23 : Program.u_location -> (float, Data.float_32) Data.t -> unit

  val mat24 : Program.u_location -> (float, Data.float_32) Data.t -> unit

  val mat32 : Program.u_location -> (float, Data.float_32) Data.t -> unit

  val mat3  : Program.u_location -> (float, Data.float_32) Data.t -> unit

  val mat34 : Program.u_location -> (float, Data.float_32) Data.t -> unit

  val mat42 : Program.u_location -> (float, Data.float_32) Data.t -> unit

  val mat43 : Program.u_location -> (float, Data.float_32) Data.t -> unit

  val mat4  : Program.u_location -> (float, Data.float_32) Data.t -> unit

end


