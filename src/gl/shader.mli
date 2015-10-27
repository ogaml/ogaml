
exception GLSL_error of Error.t * string

type t

type kind = Fragment | Vertex

val create : [< `File of string | `String of string] -> kind -> t


