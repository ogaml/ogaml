(* WIP Replacement for Model *)

open OgamlMath
open OgamlUtils
open Result.Operators

type face_point = {
  vertex : int ;
  normal : int ;
  uv     : int
}

type face = face_point * face_point * face_point

(* For now we only deal with vertices, normals, texture coordinates and faces.

  The idea is to stick as close as possible to OBJ file.

  TODO: Lines, materials, groups, object names, colors(?).
  TODO: Quads?
*)
type t = {
  vertices : Vector3f.t array ;
  normals  : Vector3f.t array ;
  uv       : Vector2f.t array ;
  faces    : face array
}

let transform m obj = {
  obj with
  vertices = Array.map (Matrix3D.times m) obj.vertices ;
  normals  = Array.map (Matrix3D.times m) obj.normals
}

(* TODO More efficient rotate/scale/translate? *)

(* TODO to_vertex_array or add_to_vertex_array perhaps *)

(* Building from an OBJ file *)
let rec lengths vn nn uvn fn ast =
  let open ObjAST in
  match ast with
  | Vertex v :: ast -> lengths (vn + 1) nn uvn fn ast
  | UV v :: ast -> lengths vn nn (uvn + 1) fn ast
  | Normal v :: ast -> lengths vn (nn + 1) uvn fn ast
  | Tri _ :: ast -> lengths vn nn uvn (fn + 1) ast
  | Quad _ :: ast (* TODO perhaps? *)
  | Param :: ast
  | Mtllib _ :: ast
  | Usemtl _ :: ast
  | Object _ :: ast
  | Group  _ :: ast
  | Smooth _  :: ast -> lengths vn nn uvn fn ast
  | [] -> (vn, nn, uvn, fn)
