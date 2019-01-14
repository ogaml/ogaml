(* WIP Replacement for Model *)

open OgamlMath
open OgamlUtils
open Result.Operators

type face_point = {
  vertex : int ;
  normal : int ;
  uv     : int
}

let mkfp vertex normal uv = { vertex ; normal ; uv }
let v3ifp v = Vector3i.(mkfp v.x v.y v.z)

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

type 'a partial_array = {
  table : 'a array ;
  mutable length : int
}

let mkpa table = {
  table ;
  length = 0
}

let addpa v pa =
  pa.table.(pa.length) <- v ;
  pa.length <- pa.length + 1

let fill_from_ast va na uva fa ast =
  let va = mkpa va in
  let na = mkpa na in
  let uva = mkpa uva in
  let fa = mkpa fa in
  let open ObjAST in
  let rec aux o =
    match o with
    | Vertex v -> addpa v va
    | UV v -> addpa v uva
    | Normal v -> addpa v na
    (* TODO Perhaps, parsing should be conistent here *)
    | Tri (v1, v2, v3) -> addpa (v3ifp v1, v3ifp v2, v3ifp v3) fa
    (* TODO Handle other things, particularly Quad? *)
    | _ -> ()
  in
  List.iter aux ast

let from_ast ast : t =
  let (vn, nn, uvn, fn) = lengths 0 0 0 0 ast in
  let vertices = Array.make vn Vector3f.zero in
  let normals = Array.make nn Vector3f.zero in
  let uv = Array.make uvn Vector2f.zero in
  let dummy_fp = mkfp 0 0 0 in
  let faces = Array.make fn (dummy_fp, dummy_fp, dummy_fp) in
  fill_from_ast vertices normals uv faces ast ;
  { vertices ; normals ; uv ; faces }
