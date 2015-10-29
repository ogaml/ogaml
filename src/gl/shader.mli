
exception GLSL_error of string

type t

type kind = Fragment | Vertex

val recommended_version : unit -> int

val create : ?version:int -> [< `File of string | `String of string] -> kind -> t


