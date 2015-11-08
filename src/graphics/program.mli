(** This module provides an high-level, type-safe and optimized 
  * way to manipulate programs (groups of GLSL shaders).
**)

(** Thrown when GLSL compilation failed *)
exception Compilation_error of string

(** Thrown when the program linking failed *)
exception Linking_error of string

(** Thrown when no valid shader has been provided *)
exception Invalid_version of string


(** This module provides a low-level access to uniforms *)
module Uniform : sig 

  (** Type of a uniform *)
  type t

  (** Returns the name of a uniform *)
  val name : t -> string

  (** Returns the type of a uniform *)
  val kind : t -> Enum.GlslType.t

  (** Returns the location of a uniform.
    * This is a low-level value and should only be
    * used internally *)
  val location : t -> Internal.Program.u_location

end


(** This module provides a low-level access to attributes *)
module Attribute : sig 

  (** Type of an attribute *)
  type t

  (** Returns the name of an attribute *)
  val name : t -> string

  (** Returns the type of an attribute *)
  val kind : t -> Enum.GlslType.t

  (** Returns the location of an attribute.
    * This is a low-level value and should only be
    * used internally *)
  val location : t -> Internal.Program.a_location

end


(** The type of GL programs *)
type t

(** Type of a source *)
type src = [`File of string | `String of string]

(** Creates a program from two shader sources. *)
val from_source : vertex_source:src -> fragment_source:src -> t

(** Creates a program from a list of shader sources
  * and version numbers. Choses the best source for 
  * the current hardware. *)
val from_source_list : State.t 
                       -> vertex_source:(int * src) list  
                       -> fragment_source:(int * src) list -> t 

(** Creates a program from a source by prepending 
  * #version v where v is the best GLSL version supported
  * by the given context. *)
val from_source_pp : State.t 
                     -> vertex_source:src
                     -> fragment_source:src -> t

(** Activates the program for use in the next rendering 
  * pass. Used internally by Ogaml, usually not needed. *)
val use : State.t -> t option -> unit

(** Iterates on the uniforms of a program *)
val iter_uniforms : t -> (Uniform.t -> unit) -> unit

(** Iterates on the attributes of a program *)
val iter_attributes : t -> (Attribute.t -> unit) -> unit


