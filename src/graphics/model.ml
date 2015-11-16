
open OgamlMath

exception Invalid_model of string

exception Bad_format of string

type vertex = int

type normal = int

type uv = int

type point = int

type color = int


module IndexedTable = struct

  type 'a t = {
    mutable indices : ('a, int) Hashtbl.t;
    mutable data   : 'a array;
    mutable size   : int;
    mutable length : int
  }

  let double t = 
    let arr = Array.make (t.size * 2) t.data.(0) in
    Array.blit t.data 0 arr 0 t.size;
    t.size <- t.size * 2;
    t.data <- arr

  let rec alloc t i = 
    let space = t.size - t.length in
    if space < i then begin
      double t;
      alloc t i
    end

  let create n def = 
    {
      indices = Hashtbl.create 97;
      data = Array.make n def;
      size = n;
      length = 0
    }

  let reset t n = 
    t.indices <- Hashtbl.create 97;
    t.data <- Array.make n t.data.(0);
    t.size <- n;
    t.length <- 0

  let copy t = 
    {
      indices = t.indices;
      data    = t.data;
      size    = t.size;
      length  = t.length
    }

  let shrink t =
    t.data <- Array.sub t.data 0 t.length;
    t.size <- t.length

  let add t e = 
    if not (Hashtbl.mem t.indices e) then begin 
      alloc t 1;
      Hashtbl.add t.indices e t.length;
      t.data.(t.length) <- e;
      t.length <- t.length + 1
    end

  let replace t i e = 
    Hashtbl.remove t.indices t.data.(i);
    Hashtbl.replace t.indices e i;
    t.data.(i) <- e

  let length t = 
    t.length

  let get t i = 
    t.data.(i)

  let id t e =
    Hashtbl.find t.indices e

  let iter t f = 
    for i = 0 to t.length - 1 do
      f i t.data.(i);
    done

  let blit t1 t2 = 
    t1.indices <- t2.indices;
    t1.data    <- t2.data;
    t1.length  <- t2.length;
    t1.size    <- t2.size

end




type t = {
  vertices  : Vector3f.t IndexedTable.t;
  normals   : Vector3f.t IndexedTable.t;
  uvs       : Vector2f.t IndexedTable.t;
  colors    : Color.t    IndexedTable.t;
  points    : (int * int option * int option * int option) IndexedTable.t;
  faces     : (int * int * int) IndexedTable.t;
}

let empty () = 
  {
    vertices  = IndexedTable.create 13 Vector3f.zero;
    normals   = IndexedTable.create 13 Vector3f.zero;
    uvs       = IndexedTable.create 13 Vector2f.zero;
    colors    = IndexedTable.create 13 (`RGB Color.RGB.black);
    points    = IndexedTable.create 13 (0, None, None, None);
    faces     = IndexedTable.create 13 (0, 0, 0);
  }

let shrink t = 
  IndexedTable.shrink t.vertices;
  IndexedTable.shrink t.normals ;
  IndexedTable.shrink t.uvs     ;
  IndexedTable.shrink t.colors  ;
  IndexedTable.shrink t.points  ;
  IndexedTable.shrink t.faces

let scale t f = 
  IndexedTable.iter 
    t.vertices 
    (fun i v -> 
      IndexedTable.replace t.vertices i (Vector3f.prop f v)
    )

let translate t tr = 
  IndexedTable.iter 
    t.vertices 
    (fun i v -> 
      IndexedTable.replace t.vertices i (Vector3f.add tr v)
    )

let add_vertex t vert = 
  IndexedTable.add t.vertices vert;
  IndexedTable.id t.vertices vert

let add_normal t norm = 
  IndexedTable.add t.normals norm;
  IndexedTable.id t.normals norm 

let add_uv t uv = 
  IndexedTable.add t.uvs uv;
  IndexedTable.id t.uvs uv 

let add_color t col = 
  IndexedTable.add t.colors col;
  IndexedTable.id t.colors col

let make_point t v n u c = 
  IndexedTable.add t.points (v,n,u,c);
  IndexedTable.id t.points (v,n,u,c)

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

let sort_tuple (i,j,k) = 
  let mini = min i (min j k) in
  if i = mini then (i,j,k)
  else if j = mini then (j,k,i)
  else (k,i,j)

let make_face t f = 
  IndexedTable.add t.faces (sort_tuple f)

let compute_face_normals t = 
  let oldpoints = IndexedTable.copy t.points in
  IndexedTable.reset t.points 13;
  IndexedTable.reset t.normals 13;
  IndexedTable.iter t.faces (fun idf (a,b,c) ->
    let (vti,_,uvi,coi) as pti = IndexedTable.get oldpoints a in
    let (vtj,_,uvj,coj) as ptj = IndexedTable.get oldpoints b in
    let (vtk,_,uvk,cok) as ptk = IndexedTable.get oldpoints c in
    let pointi = IndexedTable.get t.vertices vti in
    let pointj = IndexedTable.get t.vertices vtj in
    let pointk = IndexedTable.get t.vertices vtk in
    let normal = Vector3f.cross (Vector3f.sub pointj pointi)
                                (Vector3f.sub pointk pointi)
    in
    let newnm  = add_normal t normal in
    let newa = make_point t vti (Some newnm) uvi coi in
    let newb = make_point t vtj (Some newnm) uvj coj in
    let newc = make_point t vtk (Some newnm) uvk cok in
    IndexedTable.replace t.faces idf (newa, newb, newc)
  )

let compute_smooth_normals t = 
  let normal_sums = Array.make (IndexedTable.length t.vertices) Vector3f.zero in
  let oldpoints = IndexedTable.copy t.points in
  IndexedTable.reset t.points  13;
  IndexedTable.reset t.normals 13;
  IndexedTable.iter t.faces (fun idf (a,b,c) ->
    let (vti,_,_,_) as pti = IndexedTable.get oldpoints a in
    let (vtj,_,_,_) as ptj = IndexedTable.get oldpoints b in
    let (vtk,_,_,_) as ptk = IndexedTable.get oldpoints c in
    let pointi = IndexedTable.get t.vertices vti in
    let pointj = IndexedTable.get t.vertices vtj in
    let pointk = IndexedTable.get t.vertices vtk in
    let normal = Vector3f.cross (Vector3f.sub pointj pointi)
                                (Vector3f.sub pointk pointi)
    in
    normal_sums.(vti) <- Vector3f.add normal_sums.(vti) normal;
    normal_sums.(vtj) <- Vector3f.add normal_sums.(vtj) normal;
    normal_sums.(vtk) <- Vector3f.add normal_sums.(vtk) normal;
  );
  IndexedTable.iter t.faces (fun idf (a,b,c) ->
    let (vti,_,uvi,coi) as pti = IndexedTable.get oldpoints a in
    let (vtj,_,uvj,coj) as ptj = IndexedTable.get oldpoints b in
    let (vtk,_,uvk,cok) as ptk = IndexedTable.get oldpoints c in
    let newnmi = add_normal t (Vector3f.normalize normal_sums.(vti)) in
    let newnmj = add_normal t (Vector3f.normalize normal_sums.(vtj)) in
    let newnmk = add_normal t (Vector3f.normalize normal_sums.(vtk)) in
    let newa = make_point t vti (Some newnmi) uvi coi in
    let newb = make_point t vtj (Some newnmj) uvj coj in
    let newc = make_point t vtk (Some newnmk) uvk cok in
    IndexedTable.replace t.faces idf (newa, newb, newc)
  ) 

let compute_normals ?smooth:(smooth = false) t = 
  if smooth then compute_smooth_normals t
  else compute_face_normals t

let source_point t source point = 
  let (vt,nm,uv,co) as pt = IndexedTable.get t.points point in
  let position = IndexedTable.get t.vertices vt in
  let normal = 
    match nm with
    |None when VertexArray.Source.requires_normal source ->
       raise (Invalid_model "Normals are requested by source but not provided in the model")
    |Some i when VertexArray.Source.requires_normal source ->
        Some (IndexedTable.get t.normals i)
    | _ -> None
  in
  let texcoord = 
    match uv with
    |None when VertexArray.Source.requires_uv source ->
       raise (Invalid_model "Normals are requested by source but not provided in the model")
    |Some i when VertexArray.Source.requires_uv source -> 
        Some (IndexedTable.get t.uvs i)
    | _ -> None
  in
  let color = 
    match co with
    |None when VertexArray.Source.requires_color source ->
       raise (Invalid_model "Colors are requested by source but not provided in the model")
    |Some i when VertexArray.Source.requires_color source -> 
        Some (IndexedTable.get t.colors i)
    | _ -> None
  in
  VertexArray.Vertex.create ~position ?normal ?texcoord ?color ()
  |> VertexArray.Source.add source

let source_non_indexed t source = 
  IndexedTable.iter t.faces (fun idf (i,j,k) ->
    source_point t source i; 
    source_point t source j; 
    source_point t source k
  ) 

let source_indexed t indices source = 
  IndexedTable.iter t.faces (fun idf (i,j,k) ->
    IndexArray.Source.add indices i;
    IndexArray.Source.add indices j;
    IndexArray.Source.add indices k
  );
  for i = 0 to (IndexedTable.length t.points) - 1 do
    source_point t source i
  done

let source t ?index_source ~vertex_source () = 
  match index_source with
  |None -> source_non_indexed t vertex_source
  |Some indices -> source_indexed t indices vertex_source

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

let rec tokenize_lines_cps i l k = 
  match l with
  |[] -> k []
  |h::t -> 
    let tokens = tokenize_line i h in
    tokenize_lines_cps (i+1) t (fun l -> k (tokens @ l))

let tokenize_full str = 
  let lstr = Str.split_delim (Str.regexp "\r?\n") str in
  tokenize_lines_cps 0 lstr (fun l -> l)

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
  let offsets_v  = Array.make (List.length lv ) 0 in
  let offsets_vt = Array.make (List.length lvt) 0 in
  let offsets_vn = Array.make (List.length lvn) 0 in
  let create_pt model (v,vt,vn) = 
    let newv = if v < 0 then offsets_v.(-v-1) 
               else offsets_v.(Array.length offsets_v - v) 
    in
    let newvt = 
      match vt with
      |None -> None
      |Some vt -> Some(if vt < 0 then offsets_vt.(-vt-1) 
                       else offsets_vt.(Array.length offsets_vt - vt))
    in
    let newvn = 
      match vn with
      |None -> None
      |Some vn -> Some(if vn < 0 then offsets_vn.(-vn-1)
                       else offsets_vn.(Array.length offsets_vn - vn))
    in
    make_point model newv newvn newvt None 
  in
  List.iteri (fun i v -> offsets_v.(i)  <- add_vertex model v) lv;
  List.iteri (fun i v -> offsets_vt.(i) <- add_uv model     v) lvt;
  List.iteri (fun i v -> offsets_vn.(i) <- add_normal model v) lvn;
  List.iter (fun (pt1, pt2, pt3) ->
    let a = create_pt model pt1 in
    let b = create_pt model pt2 in
    let c = create_pt model pt3 in
    make_face model (a,b,c)
  ) lf;
  model



