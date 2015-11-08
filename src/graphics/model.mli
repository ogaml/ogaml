
exception Bad_format of string

val from_obj : ?scale:float -> ?color:Color.t ->
               [`File of string | `String of string] ->
               VertexArray.Source.t -> VertexArray.Source.t


