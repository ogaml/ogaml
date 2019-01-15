(* WIP Replacement for Model *)

open OgamlMath

module Location : sig

  type t

  val first_line : t -> int

  val last_line : t -> int

  val first_char : t -> int

  val last_char : t -> int

  val to_string : t -> string

end

type t

val transform : Matrix3D.t -> t -> t
val scale : OgamlMath.Vector3f.t -> t -> t
val translate : OgamlMath.Vector3f.t -> t -> t
val rotate : OgamlMath.Quaternion.t -> t -> t
val from_obj : string -> (t, [> `Syntax_error of (Location.t * string)
                              | `Parsing_error of Location.t]) result

val add_to_source :
  VertexArray.SimpleVertex.T.s VertexArray.Source.t -> t -> unit
