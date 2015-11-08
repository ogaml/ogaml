
type t = {
  culling : Enum.CullingMode.t;
  polygon : Enum.PolygonMode.t
}

let make ?culling:(culling = Enum.CullingMode.CullNone)
         ?polygon:(polygon = Enum.PolygonMode.DrawFill) 
         () = 
  { culling; polygon }

let culling t = t.culling

let polygon t = t.polygon
