(* WIP Replacement for Model *)

open OgamlMath
open OgamlUtils
open Result.Operators

module Location = struct

  type t = {
    file : string;
    first_line : int;
    last_line  : int;
    first_char : int;
    last_char  : int;
  }

  let create first_pos last_pos =
    let open Lexing in
    {
    file = first_pos.pos_fname;
    first_line = first_pos.pos_lnum;
    last_line  = last_pos.pos_lnum;
    first_char = first_pos.pos_cnum - first_pos.pos_bol;
    last_char  = last_pos.pos_cnum - last_pos.pos_bol;
    }

  let dummy = create Lexing.dummy_pos Lexing.dummy_pos

  let first_line t = t.first_line

  let last_line t = t.last_line

  let first_char t = t.first_char

  let last_char t = t.last_char

  let to_string t =
    Printf.sprintf "lines %i-%i, characters %i-%i"
      t.first_line t.last_line t.first_char t.last_char

end

type face_point = {
  vertex : int ;
  normal : int ;
  uv     : int
}

let mkfp vertex uv normal = { vertex ; normal ; uv }
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
  uvs      : Vector2f.t array ;
  faces    : face array
}

let transform m obj = {
  obj with
  vertices = Array.map (Matrix3D.times m) obj.vertices ;
  normals  = Array.map (Matrix3D.times m) obj.normals
}

(* TODO More efficient rotate/scale/translate? *)
let scale f t =
  transform (Matrix3D.scaling f) t

let translate v t =
  transform (Matrix3D.translation v) t

let rotate q t =
  transform (Matrix3D.from_quaternion q) t

(* Building from an OBJ file *)
let rec lengths vn nn uvn fn ast =
  let open ObjAST in
  match ast with
  | Vertex _ :: ast -> lengths (vn + 1) nn uvn fn ast
  | UV _ :: ast -> lengths vn nn (uvn + 1) fn ast
  | Normal _ :: ast -> lengths vn (nn + 1) uvn fn ast
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
  let aux o =
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
  let uvs = Array.make uvn Vector2f.zero in
  let dummy_fp = mkfp 0 0 0 in
  let faces = Array.make fn (dummy_fp, dummy_fp, dummy_fp) in
  fill_from_ast vertices normals uvs faces ast ;
  { vertices ; normals ; uvs ; faces }

let parse_with_errors lexbuf =
  try
    Ok (ObjParser.file ObjLexer.token lexbuf)
  with
    |ObjLexer.SyntaxError msg ->
        let loc = Location.create lexbuf.Lexing.lex_start_p
                                  lexbuf.Lexing.lex_curr_p
        in
        Error (`Syntax_error (loc, msg))
    |Parsing.Parse_error ->
        let loc = Location.create lexbuf.Lexing.lex_start_p
                                  lexbuf.Lexing.lex_curr_p
        in
        Error (`Parsing_error (loc))

let parse_file f =
  let input = open_in f in
  let lexbuf = Lexing.from_channel input in
  lexbuf.Lexing.lex_curr_p <- {lexbuf.Lexing.lex_curr_p with Lexing.pos_fname = f};
  let ast = parse_with_errors lexbuf in
  close_in input;
  ast

let from_obj s =
  parse_file s >>>= from_ast

let mksv obj p =
  (* Log.debug Log.stdout "vertex %d" p.vertex ;
  Log.debug Log.stdout "uv     %d" p.uv ;
  Log.debug Log.stdout "normal %d" p.normal ; *)
  let open VertexArray in
  let uv = if p.uv = 0 then None else Some obj.uvs.(p.uv-1) in
  SimpleVertex.create
    ~position: obj.vertices.(p.vertex-1)
    ?uv
    ~normal: obj.normals.(p.normal-1)
    ()

let add_to_source src obj =
  (* We add the faces *)
  Array.fold_left (fun src (p1, p2, p3) ->
    let open VertexArray.Source in
    src <<< mksv obj p1
        <<< mksv obj p2
        <<< mksv obj p3
  ) (Ok src) obj.faces
