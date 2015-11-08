
(** Backface culling enumeration *)
module CullingMode = struct

  type t = 
    | CullNone
    | CullClockwise
    | CullCounterClockwise

end

(** Polygon drawing mode enumeration *)
module PolygonMode = struct

  type t = 
    | DrawVertices
    | DrawLines
    | DrawFill

end

type t = {
  culling : CullingMode.t;
  polygon : PolygonMode.t
}

let make ?culling:(culling = CullingMode.CullNone)
         ?polygon:(polygon = PolygonMode.DrawFill) 
         () = 
  { culling; polygon }

let culling t = t.culling

let polygon t = t.polygon
