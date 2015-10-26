
module FragmentShader : sig

  type t

  val create : [< `File of string | `String of string] -> t

end


module VertexShader : sig

  type t

  val create : [< `File of string | `String of string] -> t

end
