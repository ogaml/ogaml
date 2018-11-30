open OgamlMath
open OgamlUtils
open Result.Operators

module Vertex = struct

  type t = {
    position : Vector3f.t;
    normal   : Vector3f.t option;
    uv       : Vector2f.t option;
    color    : Color.t option;
  }

  let create ~position ?normal ?uv ?color () =
    {position; normal; uv; color}

  let position t = t.position

  let normal t = t.normal

  let uv t = t.uv

  let color t = t.color

  let paint t color : t = {t with color = Some color}

  let transform t mat = 
    {t with position = Matrix3D.times mat t.position}

  let set_normal t n =
    {t with normal = Some n}

  let to_vao t = 
    VertexArray.SimpleVertex.create 
      ~position:t.position
      ?normal:t.normal
      ?uv:t.uv
      ?color:t.color ()

end


module Face = struct

  type t = Vertex.t * Vertex.t * Vertex.t

  let create v1 v2 v3 = (v1,v2,v3)

  let quad v1 v2 v3 v4 = (v1,v2,v3),(v1,v3,v4)

  let vertices f = f

  let paint (v1,v2,v3) col = 
    let open Vertex in
    (paint v1 col, paint v2 col, paint v3 col)

  let normal (v1,v2,v3) =
    let v1,v2,v3 = 
      Vertex.position v1,
      Vertex.position v2,
      Vertex.position v3
    in
    let n = 
      Vector3f.cross (Vector3f.sub v2 v1) (Vector3f.sub v3 v1)
      |> Vector3f.normalize
    in
    match n with
    | Ok v -> v
    | Error _ -> Vector3f.zero

  let transform (v1,v2,v3) mat = 
    (Vertex.transform v1 mat, Vertex.transform v2 mat, Vertex.transform v3 mat)

  let set_normal (v1,v2,v3) n = 
    (Vertex.set_normal v1 n,
     Vertex.set_normal v2 n,
     Vertex.set_normal v3 n)
end


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


type t = Face.t list


(* Iterators *)
let iter (t : t) (f : Face.t -> unit) = 
  List.iter f t

let fold (t : t) (f : 'a -> Face.t -> 'a) (i : 'a) : 'a =
  List.fold_left f i t

let map (t : t) (f : Face.t -> Face.t) = 
  List.map f t


(* Transformation *)
let transform (t : t) mat = 
  map t (fun f -> Face.transform f mat)

let scale t f = 
  transform t (Matrix3D.scaling f)

let translate t v = 
  transform t (Matrix3D.translation v)

let rotate t q = 
  transform t (Matrix3D.from_quaternion q)
   

(* Modification *)
let add_face t f = f :: t

let paint t c = 
  map t (fun f -> Face.paint f c)

let merge t1 t2 = t1 @ t2

let compute_normals ?smooth:(smooth=false) t = 
  if not smooth then 
    map t (fun f -> Face.set_normal f (Face.normal f))
  else begin
    let partial_sums = Hashtbl.create 97 in
    let add_sum v n = 
      try 
        let n' = Hashtbl.find partial_sums v in
        Hashtbl.replace partial_sums v (Vector3f.add n n')
      with
        Not_found -> Hashtbl.add partial_sums v n
    in
    iter t (fun f -> 
      let (v1,v2,v3) = Face.vertices f in
      let n = Face.normal f in
      add_sum v1 n; add_sum v2 n; add_sum v3 n
    );
    map t (fun f ->
      let (v1,v2,v3) = Face.vertices f in 
      Face.create 
        (Vertex.set_normal v1 (Hashtbl.find partial_sums v1))
        (Vertex.set_normal v2 (Hashtbl.find partial_sums v2))
        (Vertex.set_normal v3 (Hashtbl.find partial_sums v3))
    )
  end

let simplify t = 
  List.sort_uniq compare t

let source (t : t) ?index_source ~vertex_source () =
  let source_vertex v = 
    let va = Vertex.to_vao v in
    VertexArray.Source.add vertex_source va
  in
  let indices = Hashtbl.create 97 in
  let get_index v = 
    try Ok (Hashtbl.find indices v)
    with Not_found -> 
      let ind = VertexArray.Source.length vertex_source in
      source_vertex v >>>= (fun () ->
      Hashtbl.add indices v ind;
      ind)
  in
  match index_source with
  | None -> 
      Result.List.iter (fun f ->
        let (v1,v2,v3) = Face.vertices f in
        (source_vertex v1) >>= (fun () ->
        (source_vertex v2) >>= (fun () ->
        (source_vertex v3)))
      ) t
  | Some idx ->
      Result.List.iter (fun f ->
        let (v1,v2,v3) = Face.vertices f in
        get_index v1 >>= (fun i1 ->
        get_index v2 >>= (fun i2 ->
        get_index v3 >>>= (fun i3 ->
        IndexArray.Source.add idx i1;
        IndexArray.Source.add idx i2;
        IndexArray.Source.add idx i3)))
      ) t

(* Creation *)
let empty = []

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

let cube corner size = 
  let open Vector3f in
  let bdl, bul, bur, bdr, 
      fdl, ful, fur, fdr 
      =
      corner,
      add corner {x = 0.; y = size.y; z = 0.},
      add corner {x = size.x; y = size.y; z = 0.},
      add corner {x = size.x; y = 0.; z = 0.},
      add corner {x = 0.; y = 0.; z = size.z},
      add corner {x = 0.; y = size.y; z = size.z},
      add corner {x = size.x; y = size.y; z = size.z},
      add corner {x = size.x; y = 0.; z = size.z}
  in
  let nx, ny, nz, nmx, nmy, nmz =
    unit_x, unit_y, unit_z,
    prop (-1.) unit_x,
    prop (-1.) unit_y,
    prop (-1.) unit_z
  in
  let uv1, uv2, uv3, uv4 = 
    Vector2f.({x = 0.; y = 0.}),
    Vector2f.({x = 0.; y = 1.}),
    Vector2f.({x = 1.; y = 1.}),
    Vector2f.({x = 1.; y = 0.})
  in
  let cx, cy, cz, cmx, cmy, cmz = 
    `RGB Color.RGB.blue,
    `RGB Color.RGB.green,
    `RGB Color.RGB.yellow,
    `RGB Color.RGB.red,
    `RGB Color.RGB.magenta,
    `RGB Color.RGB.cyan
  in
  let make_face p1 p2 p3 p4 n c model = 
    let v1 = Vertex.create ~position:p1 ~normal:n ~color:c ~uv:uv1 () in
    let v2 = Vertex.create ~position:p2 ~normal:n ~color:c ~uv:uv2 () in
    let v3 = Vertex.create ~position:p3 ~normal:n ~color:c ~uv:uv3 () in
    let v4 = Vertex.create ~position:p4 ~normal:n ~color:c ~uv:uv4 () in
    let f1, f2 = Face.quad v1 v4 v3 v2 in
    add_face model f1
    |> fun m -> add_face m f2
  in
  make_face fdl ful fur fdr nz cz empty
  |> make_face ful bul bur fur ny cy
  |> make_face bul bdl bdr bur nmz cmz
  |> make_face bdl fdl fdr bdr nmy cmy
  |> make_face fdr fur bur bdr nx cx
  |> make_face bdl bul ful fdl nmx cmx


module IndexTable = struct

  type 'a t = {
    mutable length : int;
    mutable data   : 'a array
  }

  let double t = 
    let newarr = Array.make (t.length * 2) t.data.(0) in
    Array.blit t.data 0 newarr 0 t.length;
    t.data <- newarr

  let make i = {
    length = 0;
    data   = Array.make 64 i
  }

  let push t v = 
    if t.length >= Array.length t.data then 
      double t;
    t.data.(t.length) <- v;
    t.length <- t.length + 1

  let get t i = 
    if i < 0 then t.data.(t.length + i)
    else t.data.(i-1)
     
end

    
let from_ast tblv tbluv tbln model ast = 
  let make_vertex v = 
    Vertex.create 
      ~position:(IndexTable.get tblv v.Vector3i.x)
      ?uv:(if v.Vector3i.y = 0 then None 
           else Some (IndexTable.get tbluv v.Vector3i.y))
      ?normal:(if v.Vector3i.z = 0 then None 
               else Some (IndexTable.get tbln v.Vector3i.z))
      ()
  in
  match ast with
  | ObjAST.Vertex v -> 
      IndexTable.push tblv v;
      model
  | ObjAST.UV     v -> 
      IndexTable.push tbluv v;
      model
  | ObjAST.Normal v -> 
      IndexTable.push tbln v;
      model
  | ObjAST.Tri  (v1,v2,v3) -> 
      let f = Face.create (make_vertex v1) (make_vertex v2) (make_vertex v3) in
      add_face model f
  | ObjAST.Quad (v1,v2,v3,v4) -> 
      let f1,f2 = Face.quad (make_vertex v1) (make_vertex v2) 
                            (make_vertex v3) (make_vertex v4) in
      let model = add_face model f1 in
      add_face model f2
  | ObjAST.Param  
  | ObjAST.Mtllib _
  | ObjAST.Usemtl _ 
  | ObjAST.Object _
  | ObjAST.Group  _
  | ObjAST.Smooth _ -> model

let from_obj s = 
  parse_file s >>>= (fun ast ->
  let tblv  = IndexTable.make Vector3f.zero in
  let tbluv = IndexTable.make Vector2f.zero in
  let tbln  = IndexTable.make Vector3f.zero in
  List.fold_left (from_ast tblv tbluv tbln) empty ast)


