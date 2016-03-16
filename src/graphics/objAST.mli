type t = 
  | Vertex of OgamlMath.Vector3f.t
  | UV     of OgamlMath.Vector2f.t
  | Normal of OgamlMath.Vector3f.t
  | Param  
  | Tri    of OgamlMath.Vector3i.t * 
              OgamlMath.Vector3i.t * 
              OgamlMath.Vector3i.t
  | Quad   of OgamlMath.Vector3i.t * 
              OgamlMath.Vector3i.t * 
              OgamlMath.Vector3i.t *
              OgamlMath.Vector3i.t
  | Mtllib of string
  | Usemtl of string
  | Object of string
  | Group  of string
  | Smooth of int option

