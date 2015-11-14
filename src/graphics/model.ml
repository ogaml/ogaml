
open OgamlMath

exception Invalid_model of string

exception Bad_format of string

type vertex = int

type normal = int

type uv = int

type point = int

type color = int

module TIntSet = Set.Make (struct

  type t = (int * int * int)

  let compare = compare

end)

type t = {
  ivertices : (Vector3f.t, int) Hashtbl.t;
  vertices  : (int, Vector3f.t) Hashtbl.t;
  inormals  : (Vector3f.t, int) Hashtbl.t;
  normals   : (int, Vector3f.t) Hashtbl.t;
  iuvs      : (Vector2f.t, int) Hashtbl.t;
  uvs       : (int, Vector2f.t) Hashtbl.t;
  ipoints   : (int * int option * int option * int option, int) Hashtbl.t;
  points    : (int, int * int option * int option * int option) Hashtbl.t;
  icolors   : (Color.t, int) Hashtbl.t;
  colors    : (int, Color.t) Hashtbl.t;
  mutable faces : TIntSet.t;
  mutable nbv   : int;
  mutable nbn   : int;
  mutable nbu   : int;
  mutable nbp   : int;
  mutable nbc   : int;
}

let empty () = 
  {
    ivertices = Hashtbl.create 13;
    vertices  = Hashtbl.create 13;
    inormals  = Hashtbl.create 13;
    normals   = Hashtbl.create 13;
    iuvs      = Hashtbl.create 13;
    uvs       = Hashtbl.create 13;
    ipoints   = Hashtbl.create 13;
    points    = Hashtbl.create 13;
    icolors   = Hashtbl.create 13;
    colors    = Hashtbl.create 13;
    faces     = TIntSet.empty;
    nbv       = 0;
    nbn       = 0;
    nbu       = 0;
    nbp       = 0;
    nbc       = 0;
  }

let scale t f = 
  Hashtbl.iter (fun i v -> 
    Hashtbl.replace t.vertices i (Vector3f.prop f v);
    Hashtbl.remove t.ivertices v;
    Hashtbl.replace t.ivertices (Vector3f.prop f v) i
  ) t.vertices 

let translate t tr = 
  Hashtbl.iter (fun i v -> 
    Hashtbl.replace t.vertices i (Vector3f.add tr v);
    Hashtbl.remove t.ivertices v;
    Hashtbl.replace t.ivertices (Vector3f.add tr v) i
  ) t.vertices 

let add_vertex t vert = 
  try 
    Hashtbl.find t.ivertices vert
  with Not_found -> begin
    Hashtbl.add t.vertices t.nbv vert;
    Hashtbl.add t.ivertices vert t.nbv;
    t.nbv <- t.nbv + 1;
    t.nbv - 1
  end

let add_normal t norm = 
  try 
    Hashtbl.find t.inormals norm
  with Not_found -> begin
    Hashtbl.add t.normals t.nbn norm;
    Hashtbl.add t.inormals norm t.nbn;
    t.nbn <- t.nbn + 1;
    t.nbn - 1
  end

let add_uv t uv = 
  try
    Hashtbl.find t.iuvs uv
  with Not_found -> begin
    Hashtbl.add t.uvs t.nbu uv;
    Hashtbl.add t.iuvs uv t.nbu;
    t.nbu <- t.nbu + 1;
    t.nbu - 1
  end

let add_color t color = 
  try
    Hashtbl.find t.icolors color
  with Not_found -> begin
    Hashtbl.add t.colors t.nbc color;
    Hashtbl.add t.icolors color t.nbc;
    t.nbc <- t.nbc + 1;
    t.nbc - 1
  end


let make_point t v n u c = 
  try
    Hashtbl.find t.ipoints (v,n,u,c)
  with Not_found -> begin
    Hashtbl.add t.points t.nbp (v,n,u,c);
    Hashtbl.add t.ipoints (v,n,u,c) t.nbp;
    t.nbp <- t.nbp + 1;
    t.nbp - 1
  end

let add_point t ~vertex ?normal ?uv ?color () = 
  let i = add_vertex t vertex in
  let j = 
    match normal with
    |None -> None
    |Some n -> Some (add_normal t n)
  in
  let k = 
    match uv with
    |None -> None
    |Some u -> Some (add_uv t u)
  in
  let l = 
    match color with
    |None -> None
    |Some c -> Some (add_color t c)
  in
  make_point t i j k l

let make_face t (i,j,k) = 
  t.faces <- TIntSet.add (i,j,k) t.faces

let compute_normals t = 
  TIntSet.fold (fun (i,j,k) s ->
    let (vti,nmi,uvi,coi) as pti = Hashtbl.find t.points i in
    let (vtj,nmj,uvj,coj) as ptj = Hashtbl.find t.points j in
    let (vtk,nmk,uvk,cok) as ptk = Hashtbl.find t.points k in
    let pointi = Hashtbl.find t.vertices vti in
    let pointj = Hashtbl.find t.vertices vtj in
    let pointk = Hashtbl.find t.vertices vtk in
    let newi = 
      if nmi <> None then i
      else begin
        let normal = Vector3f.cross (Vector3f.sub pointj pointi)
                                    (Vector3f.sub pointk pointi)
        in
        let newnmi = add_normal t normal in
        make_point t vti (Some newnmi) uvi coi
      end
    in
    let newj = 
      if nmj <> None then j
      else begin
        let normal = Vector3f.cross (Vector3f.sub pointk pointj)
                                    (Vector3f.sub pointi pointj)
        in
        let newnmj = add_normal t normal in
        make_point t vtj (Some newnmj) uvj coj
      end
    in
    let newk = 
      if nmk <> None then k
      else begin
        let normal = Vector3f.cross (Vector3f.sub pointi pointk)
                                    (Vector3f.sub pointj pointk)
        in
        let newnmk = add_normal t normal in
        make_point t vtk (Some newnmk) uvk cok
      end
    in
    TIntSet.add (newi, newj, newk) s
  ) t.faces TIntSet.empty
  |> fun s -> t.faces <- s
 
let source_point t source point = 
  let (vt,nm,uv,co) as pt = Hashtbl.find t.points point in
  let position = Hashtbl.find t.vertices vt in
  let normal = 
    match nm with
    |None when VertexArray.Source.requires_normal source ->
       raise (Invalid_model "Normals are requested by source but not provided in the model")
    |Some i when VertexArray.Source.requires_normal source ->
        Some (Hashtbl.find t.normals i)
    | _ -> None
  in
  let texcoord = 
    match uv with
    |None when VertexArray.Source.requires_uv source ->
       raise (Invalid_model "Normals are requested by source but not provided in the model")
    |Some i when VertexArray.Source.requires_uv source -> 
        Some (Hashtbl.find t.uvs i)
    | _ -> None
  in
  let color = 
    match co with
    |None when VertexArray.Source.requires_color source ->
       raise (Invalid_model "Colors are requested by source but not provided in the model")
    |Some i when VertexArray.Source.requires_color source -> 
        Some (Hashtbl.find t.colors i)
    | _ -> None
  in
  VertexArray.Vertex.create ~position ?normal ?texcoord ?color ()
  |> VertexArray.Source.add source

let source_non_indexed t source = 
  TIntSet.iter (fun (i,j,k) ->
    source_point t source i; 
    source_point t source j; 
    source_point t source k
  ) t.faces

let source t ?index_source ~vertex_source () = 
  source_non_indexed t vertex_source

(* TEMPORARY (TODO) *)
let from_obj f = empty ()

(** OBJ Parsing **)

type lit = Int of int | Float of float

let lit_to_float = function
  |Int i -> float_of_int i
  |Float f -> f

let lit_to_int = function
  |Int i -> i
  |Float f -> int_of_float f


type loc = {line : int; str : string}


type tokens = Slash   of loc | 
              Literal of loc * lit | 
              F       of loc | 
              VT      of loc | 
              VN      of loc |
              V       of loc |
              Unknown of loc

let int_regex = Str.regexp "-?[0-9]*$"

let float_regex = Str.regexp "-?[0-9]*\\(\\.[0-9]*\\)?\\([eE]\\([-+]\\)?[0-9]+\\)?$"


let tokenize loc w = 
  if Str.string_match int_regex w 0 then
    Literal (loc, Int (int_of_string w))
  else if Str.string_match float_regex w 0 then
    Literal (loc, Float (float_of_string w))
  else if w = "f" then
    F loc
  else if w = "vt" then
    VT loc
  else if w = "vn" then
    VN loc
  else if w = "v" then
    V loc
  else if w = "/" then
    Slash loc
  else
    Unknown loc

let tokenize_delim loc = function
  |Str.Text s -> tokenize loc s
  |Str.Delim s -> Slash loc

let tokenize_line i str = 
  let lstr = Str.split (Str.regexp " ") str in
  let loc = {line = i; str} in
  match lstr with
  |[] -> []
  |h::t -> begin
    match tokenize loc h with
    |Unknown _-> []
    |token    -> 
      List.map (Str.full_split (Str.regexp "/")) t
      |> List.flatten
      |> List.map (tokenize_delim loc)
      |> fun l -> token::l
  end

let tokenize_full str = 
  let lstr = Str.split_delim (Str.regexp "\r?\n") str in
  List.mapi (fun i l ->
    match tokenize_line i l with
    |[] -> []
    |Unknown _ :: _ -> []
    |l -> l
  ) lstr
  |> List.flatten

let extract_loc = function
  |Literal (loc, _) 
  |Slash loc        
  |F  loc
  |VT loc
  |VN loc
  |V  loc
  |Unknown loc -> loc

let rec parse_point = function
  |Literal (_, Int x) :: Slash _ :: Literal (_, Int y) :: Slash _ :: Literal (_, Int z) :: t -> 
    ((x, Some y, Some z), t)
  |Literal (_, Int x) :: Slash _ :: Slash _ :: Literal (_, Int z) :: t -> 
    ((x, None, Some z), t)
  |Literal (_, Int x) :: Slash _ :: Literal (_, Int y) :: Slash _ :: t -> 
    ((x, Some y, None), t)
  |Literal (_, Int x) :: Slash _ :: Literal (_, Int y) :: t -> 
    ((x, Some y, None), t)
  |Literal (_, Int x) :: Slash _ :: Slash _ :: t-> 
    ((x, None, None), t)
  |Literal (_, Int x) :: Slash _ :: t -> 
    ((x, None, None), t)
  |Literal (_, Int x) :: t -> 
    ((x, None, None), t)
  |token :: _ -> 
    let loc = extract_loc token in 
    raise (Bad_format (Printf.sprintf "Format error in OBJ file, line %i : %s" loc.line loc.str))
  |[] -> 
    raise (Bad_format ("Format error in OBJ file, unexpected end of file"))

let rec parse_rectangle l = 
  let (pt1, l) = parse_point l in
  let (pt2, l) = parse_point l in
  let (pt3, l) = parse_point l in
  let (pt4, l) = parse_point l in
  ((pt1, pt2, pt3), (pt1, pt3, pt4), l)

let rec parse_triangle l = 
  let (pt1, l) = parse_point l in
  let (pt2, l) = parse_point l in
  let (pt3, l) = parse_point l in
  ((pt1, pt2, pt3), l)

let rec parse_tokens lv lvt lvn lf = function
  |[] -> (lv, lvt, lvn, lf)
  |V _ :: Literal (_,x) :: Literal (_,y) :: Literal (_,z) :: t-> 
      let x,y,z = lit_to_float x, lit_to_float y, lit_to_float z in
      parse_tokens
        (OgamlMath.Vector3f.({x;y;z}) :: lv)
        lvt lvn lf t
  |VT _ :: Literal (_,x) :: Literal (_,y) :: Literal(_,_) :: t ->
      let x,y = lit_to_float x, lit_to_float y in
      parse_tokens
        lv
        (OgamlMath.Vector2f.({x;y}) :: lvt)
        lvn lf t
  |VT _ :: Literal (_,x) :: Literal (_,y) :: t ->
      let x,y = lit_to_float x, lit_to_float y in
      parse_tokens
        lv
        (OgamlMath.Vector2f.({x;y}) :: lvt)
        lvn lf t
  |VN _ :: Literal (_,x) :: Literal (_,y) :: Literal (_,z) :: t ->
      let x,y,z = lit_to_float x, lit_to_float y, lit_to_float z in
      parse_tokens
        lv lvt
        (OgamlMath.Vector3f.({x;y;z}) :: lvn)
        lf t
  |F _ :: l -> 
      let newlf, tail = 
        try 
          let (tri1, tri2, t) = parse_rectangle l in
          tri1 :: tri2 :: lf, t
        with 
          Bad_format _ -> begin
            let (tri, t) = parse_triangle l in
            tri :: lf, t
        end
      in
      parse_tokens lv lvt lvn newlf tail
  |token :: _ -> 
    let loc = extract_loc token in 
    raise (Bad_format (Printf.sprintf "Format error in OBJ file, line %i : %s" loc.line loc.str))

let read_file filename =
  let chan = open_in filename in
  let len = in_channel_length chan in
  let str = Bytes.create len in
  really_input chan str 0 len;
  close_in chan; str

let to_source = function
  | `File   s -> read_file s
  | `String s -> s

let from_obj src = 
  let tokens = tokenize_full (to_source src) in
  let lv, lvt, lvn, lf = parse_tokens [] [] [] [] tokens in
  let model = empty () in
  let create_pt model (v,vt,vn) = 
    let newv = if v < 0 then -v-1 else model.nbv - v in
    let newvt = 
      match vt with
      |None -> None
      |Some vt -> Some(if vt < 0 then -vt-1 else model.nbu - vt)
    in
    let newvn = 
      match vn with
      |None -> None
      |Some vn -> Some(if vn < 0 then -vn-1 else model.nbn - vn)
    in
    make_point model newv newvn newvt None 
  in
  List.iter (fun v -> add_vertex model v |> ignore) lv;
  List.iter (fun v -> add_uv model     v |> ignore) lvt;
  List.iter (fun v -> add_normal model v |> ignore) lvn;
  List.iter (fun (pt1, pt2, pt3) ->
    let a = create_pt model pt1 in
    let b = create_pt model pt2 in
    let c = create_pt model pt3 in
    make_face model (a,b,c)
  ) lf;
  model



