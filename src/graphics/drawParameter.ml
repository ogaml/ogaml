
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
  polygon : PolygonMode.t;
  depth   : bool;
}

let make ?culling:(culling = CullingMode.CullNone)
         ?polygon:(polygon = PolygonMode.DrawFill) 
         ?depth_test:(depth_test = false)
         () = 
  { culling; polygon; depth = depth_test }

let culling t = t.culling

let polygon t = t.polygon

let depth_test t = t.depth

