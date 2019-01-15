(* WIP Replacement for Model *)

open OgamlMath

type t

val transform : Matrix3D.t -> t -> t

(* val from_obj : string -> t *)

val add_to_source :
  VertexArray.SimpleVertex.T.s VertexArray.Source.t -> t -> unit
