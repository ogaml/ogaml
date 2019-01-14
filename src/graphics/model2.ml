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
*)
type t = {
  vertices : Vector3f.t array ;
  normals  : Vector3f.t array ;
  uv       : Vector2f.t array ;
  faces    : face array
}

let transform m obj = {
  obj with
  vertices = Array.map (Matrix3D.times m) vertices ;
  normals  = Array.map (Matrix3D.times m) normals ;
  uv       = Array.map (Matrix3D.times m) uv
}

(* TODO More efficient rotate/scale/translate? *)

(* TODO to_vertex_array or add_to_vertex_array perhaps *)

(* TODO from_obj *)
