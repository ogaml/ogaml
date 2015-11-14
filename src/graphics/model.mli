
exception Invalid_model of string

exception Bad_format of string

type t

type vertex

type normal

type uv

type point

type color

val empty : unit -> t

val from_obj : [`File of string | `String of string] -> t

val scale : t -> float -> unit

val translate : t -> OgamlMath.Vector3f.t -> unit

val add_vertex : t -> OgamlMath.Vector3f.t -> vertex

val add_normal : t -> OgamlMath.Vector3f.t -> normal

val add_uv : t -> OgamlMath.Vector2f.t -> uv

val add_color : t -> Color.t -> color

val make_point : t -> vertex -> normal option -> uv option -> color option -> point

val add_point : t -> vertex:OgamlMath.Vector3f.t ->
                    ?normal:OgamlMath.Vector3f.t ->
                    ?uv:OgamlMath.Vector2f.t -> 
                    ?color:Color.t -> unit -> point

val make_face : t -> (point * point * point) -> unit

val compute_normals : t -> unit

val source : t -> ?index_source:IndexArray.Source.t ->
                   vertex_source:VertexArray.Source.t -> unit -> unit

