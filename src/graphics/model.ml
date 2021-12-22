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

let missing_normals v1 v2 v3 =
  let open Vector3i in
  v1.z = 0 || v2.z = 0 || v3.z = 0

(* Building from an OBJ file *)
type counters = {
  vn  : int ; (* vertices *)
  nn  : int ; (* normals *)
  mnn : int ; (* missing normals *)
  uvn : int ; (* uvs *)
  fn  : int   (* faces *)
}

let count_zero = {
  vn  = 0 ;
  nn  = 0 ;
  mnn = 0 ;
  uvn = 0 ;
  fn  = 0
}

let rec lengths cn c ast =
  let open ObjAST in
  match ast with
  | Vertex _ :: ast -> lengths cn { c with vn = c.vn + 1 } ast
  | UV _ :: ast -> lengths cn { c with uvn = c.uvn + 1 } ast
  | Normal _ :: ast -> lengths cn { c with nn = c.nn + 1 } ast
  | Tri (v1, v2, v3) :: ast when cn && missing_normals v1 v2 v3 ->
    lengths cn { c with mnn = c.mnn + 1 ; fn = c.fn + 1 } ast
  | Tri _ :: ast -> lengths cn { c with fn = c.fn + 1 } ast
  | Quad _ :: ast -> lengths cn { c with fn = c.fn + 2 } ast
  | Param :: ast
  | Mtllib _ :: ast
  | Usemtl _ :: ast
  | Object _ :: ast
  | Group  _ :: ast
  | Smooth _  :: ast -> lengths cn c ast
  | [] -> (c.vn, c.nn, c.mnn, c.uvn, c.fn)

type 'a partial_array = {
  table : 'a array ;
  mutable length : int
}

let mkpa ?start:(length=0) table = {
  table ;
  length
}

let addpa v pa =
  pa.table.(pa.length) <- v ;
  pa.length <- pa.length + 1

let fill_from_ast compute_normals va na uva fa ast =
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
    (* TODO Perhaps, parsing should be consistent here *)
    | Tri (v1, v2, v3) -> addpa (v3ifp v1, v3ifp v2, v3ifp v3) fa
    | Quad (v1, v2, v3, v4) ->
      addpa (v3ifp v1, v3ifp v2, v3ifp v3) fa ;
      addpa (v3ifp v1, v3ifp v3, v3ifp v4) fa
    (* TODO Handle other things? *)
    | _ -> ()
  in
  List.iter aux ast

let missing_normals_f f1 f2 f3 =
  f1.normal = 0 || f2.normal = 0 || f3.normal = 0

let face_normal vertices f1 f2 f3 =
  let pv1, pv2, pv3 =
    vertices.(f1.vertex),
    vertices.(f2.vertex),
    vertices.(f3.vertex)
  in
  let open Vector3f in
  cross (sub pv2 pv1) (sub pv3 pv1)
  |> normalize
  |> function Ok v -> v | Error _ -> zero

let from_ast compute_normals ast : t =
  let (vn, nn, mnn, uvn, fn) = lengths compute_normals count_zero ast in
  let vertices = Array.make vn Vector3f.zero in
  let normals = Array.make (nn + mnn) Vector3f.zero in
  let uvs = Array.make uvn Vector2f.zero in
  let dummy_fp = mkfp 0 0 0 in
  let faces = Array.make fn (dummy_fp, dummy_fp, dummy_fp) in
  fill_from_ast compute_normals vertices normals uvs faces ast ;
  let normals = mkpa ~start:nn normals in
  let faces =
    Array.map (fun (f1, f2, f3) ->
      if missing_normals_f f1 f2 f3 then begin
        let n = face_normal vertices f1 f2 f3 in
        let ni = normals.length in
        addpa n normals ;
        let r f =
          if f.normal = 0 then { f with normal = ni } else f
        in
        (r f1, r f2, r f3)
      end
      else (f1,f2,f3)
    ) faces
  in
  { vertices ; normals = normals.table ; uvs ; faces }

let parse_with_errors lexbuf =
  try
    Ok (ObjParser.file ObjLexer.token lexbuf)
  with
  | ObjLexer.SyntaxError msg ->
    let loc = Location.create lexbuf.Lexing.lex_start_p
                              lexbuf.Lexing.lex_curr_p
    in
    Error (`Syntax_error (loc, msg))
  | Parsing.Parse_error ->
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

let from_obj ?(compute_normals=false) s =
  parse_file s >>>= from_ast compute_normals

(* TODO smooth?? *)
(* TODO Factorise more with from_obj *)
let compute_normals obj =
  let mnn =
    Array.fold_left
      (fun n (f1,f2,f3) -> if missing_normals_f f1 f2 f3 then n + 1 else n)
      0
      obj.faces
  in
  let newnormals = Array.make mnn Vector3f.zero in
  let newnormals = mkpa newnormals in
  let newfaces = Array.copy obj.faces in
  Array.iteri (fun i (f1,f2,f3) ->
    if missing_normals_f f1 f2 f3 then begin
      let n = face_normal obj.vertices f1 f2 f3 in
      let ni = newnormals.length in
      addpa n newnormals ;
      let r f =
        if f.normal = 0 then { f with normal = ni } else f
      in
      newfaces.(i) <- (r f1, r f2, r f3)
    end
  ) obj.faces ;
  let newnormals = Array.append obj.normals newnormals.table in
  { obj with faces = newfaces ; normals = newnormals }

let mksv obj p =
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
