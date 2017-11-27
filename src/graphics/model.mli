

module Vertex : sig

  type t

  val create : position:OgamlMath.Vector3f.t ->
              ?normal:OgamlMath.Vector3f.t   ->
              ?uv:OgamlMath.Vector2f.t       ->
              ?color:Color.t -> unit -> t

  val position : t -> OgamlMath.Vector3f.t

  val normal : t -> OgamlMath.Vector3f.t option

  val uv : t -> OgamlMath.Vector2f.t option

  val color : t -> Color.t option

end


module Face : sig

  type t

  val create : Vertex.t -> Vertex.t -> Vertex.t -> t

  val quad : Vertex.t -> Vertex.t -> Vertex.t -> Vertex.t -> (t * t)

  val vertices : t -> (Vertex.t * Vertex.t * Vertex.t)

  val paint : t -> Color.t -> t

  val normal : t -> OgamlMath.Vector3f.t

end


module Location : sig

  type t

  val first_line : t -> int

  val last_line : t -> int

  val first_char : t -> int

  val last_char : t -> int

  val to_string : t -> string

end


type t

(* Creation *)

val empty : t

val from_obj : string -> (t, [> `Syntax_error of (Location.t * string) 
                              | `Parsing_error of Location.t]) result

val cube : OgamlMath.Vector3f.t -> OgamlMath.Vector3f.t -> t


(* Transformation *)

val transform : t -> OgamlMath.Matrix3D.t -> t

val scale : t -> OgamlMath.Vector3f.t -> t

val translate : t -> OgamlMath.Vector3f.t -> t

val rotate : t -> OgamlMath.Quaternion.t -> t


(* Model modification *)

val add_face : t -> Face.t -> t

val paint : t -> Color.t -> t

val merge : t -> t -> t

val compute_normals : ?smooth:bool -> t -> t

val simplify : t -> t

val source : t -> ?index_source:IndexArray.Source.t 
               -> vertex_source:VertexArray.SimpleVertex.T.s VertexArray.Source.t 
               -> unit -> (unit, [> `Missing_attribute]) result



(* Iterators *)

val iter : t -> (Face.t -> unit) -> unit

val fold : t -> ('a -> Face.t -> 'a) -> 'a -> 'a

val map : t -> (Face.t -> Face.t) -> t

