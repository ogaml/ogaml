
exception Program_error of string

type t

type attribute

type uniform

val create : unit -> t

val build : 
  shaders    : Shader.t list ->
  uniforms   : string list   ->
  attributes : string list   -> t

val attach : Shader.t -> t -> t

val link : t -> unit

val add_uniform : string -> t -> t

val add_attribute : string -> t -> t

val uniform   : t -> string -> uniform

val attribute : t -> string -> attribute

val use : t option -> unit

