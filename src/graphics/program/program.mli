(** This module provides an high-level, type-safe and optimized 
  * way to manipulate programs (groups of GLSL shaders).
**)

(** Thrown at GLSL failure *)
exception Program_error of string


(** This module provides a low-level access to uniforms *)
module Uniform : sig 

  (** Type of a uniform *)
  type t

  (** Returns the name of a uniform *)
  val name : t -> string

  (** Returns the type of a uniform *)
  val kind : t -> GLTypes.GlslType.t

  (** Returns the location of a uniform.
    * This is a low-level value and should only be
    * used internally *)
  val location : t -> GL.Program.u_location

end


(** This module provides a low-level access to attributes *)
module Attribute : sig 

  (** Type of an attribute *)
  type t

  (** Returns the name of an attribute *)
  val name : t -> string

  (** Returns the type of an attribute *)
  val kind : t -> GLTypes.GlslType.t

  (** Returns the location of an attribute.
    * This is a low-level value and should only be
    * used internally *)
  val location : t -> GL.Program.a_location

end


(** The type of GL programs *)
type t = ProgramInternal.t

(** Type of a source *)
type src = [`File of string | `String of string]

(** Creates a program from two shader sources. *)
val from_source : (module RenderTarget.T with type t = 'a) -> 
  ?log:OgamlUtils.Log.t -> 
  context:'a -> vertex_source:src -> fragment_source:src -> unit -> t

(** Creates a program from a list of shader sources
  * and version numbers. Choses the best source for 
  * the current hardware. *)
val from_source_list : (module RenderTarget.T with type t = 'a)
  -> ?log:OgamlUtils.Log.t 
  -> context:'a 
  -> vertex_source:(int * src) list 
  -> fragment_source:(int * src) list -> unit -> t

(** Creates a program from a source by prepending 
  * #version v where v is the best GLSL version supported
  * by the given context. *)
val from_source_pp : (module RenderTarget.T with type t = 'a) -> 
  ?log:OgamlUtils.Log.t ->
  context:'a -> vertex_source:src -> fragment_source:src -> unit -> t

(* Non-exposed functions *)
module LL : sig

  (** Activates the program for use in the next rendering 
    * pass. Used internally by Ogaml, usually not needed. *)
  val use : Context.t -> t option -> unit

  (** Returns the list of the uniforms of a program *)
  val uniforms : t -> Uniform.t list

  (** Returns the list of the attributes of a program *)
  val attributes : t -> Attribute.t list

end

