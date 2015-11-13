
open OgamlMath

exception Invalid_model of string

exception Bad_format of string

type vertex = int

type normal = int

type uv = int

type point = int

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
  ipoints   : (int * int option * int option, int) Hashtbl.t;
  points    : (int, int * int option * int option) Hashtbl.t;
  mutable faces : TIntSet.t;
  mutable nbv   : int;
  mutable nbn   : int;
  mutable nbu   : int;
  mutable nbp   : int;
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
    faces     = TIntSet.empty;
    nbv       = 0;
    nbn       = 0;
    nbu       = 0;
    nbp       = 0;
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

let make_point t (i,j,k) = 
  try
    Hashtbl.find t.ipoints (i,j,k)
  with Not_found -> begin
    Hashtbl.add t.points t.nbp (i,j,k);
    Hashtbl.add t.ipoints (i,j,k) t.nbp;
    t.nbp <- t.nbp + 1;
    t.nbp - 1
  end

let add_point t ~vertex ?normal ?uv () = 
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
  make_point t (i,j,k)

let make_face t (i,j,k) = 
  t.faces <- TIntSet.add (i,j,k) t.faces

let compute_normals t = 
  TIntSet.fold (fun (i,j,k) s ->
    let (vti,nmi,uvi) as pti = Hashtbl.find t.points i in
    let (vtj,nmj,uvj) as ptj = Hashtbl.find t.points j in
    let (vtk,nmk,uvk) as ptk = Hashtbl.find t.points k in
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
        make_point t (vti, Some newnmi, uvi)
      end
    in
    let newj = 
      if nmj <> None then j
      else begin
        let normal = Vector3f.cross (Vector3f.sub pointk pointj)
                                    (Vector3f.sub pointi pointj)
        in
        let newnmj = add_normal t normal in
        make_point t (vtj, Some newnmj, uvj)
      end
    in
    let newk = 
      if nmk <> None then k
      else begin
        let normal = Vector3f.cross (Vector3f.sub pointi pointk)
                                    (Vector3f.sub pointj pointk)
        in
        let newnmk = add_normal t normal in
        make_point t (vtk, Some newnmk, uvk)
      end
    in
    TIntSet.add (newi, newj, newk) s
  ) t.faces TIntSet.empty
  |> fun s -> t.faces <- s
 
let source_point t source point = 
  let (vt,nm,uv) as pt = Hashtbl.find t.points point in
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
  VertexArray.Vertex.create ~position ?normal ?texcoord ()
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

(** Tokenizer **)
(*type nb = Int of int | Float of float

type tokens = Slash | Number of nb | F | VT | VN | V 

let rec junk_spaces stream = 
  match Stream.peek stream with
  |Some ' ' -> Stream.junk stream; junk_spaces stream
  | _ -> ()

let rec junk_line stream = 
  match Stream.next stream with
  |'\n' -> ()
  | _   -> junk_line stream

let rec tokenize_nb line acc mul i stream = 
  match Stream.next stream with
  |'0'..'9' as c -> 
      tokenize_nb line acc mul (i*10 + (Char.code c - 48)) stream
  |' ' |'\r' -> 
      tokenize_obj line (Number (Int (mul * i)) :: acc) stream
  |'/' -> 
      tokenize_obj line (Slash :: Number (Int (mul * i)) :: acc) stream
  |'\n' -> 
      tokenize_obj (line +1) (Number (Int (mul * i)) :: acc) stream
  |'.' -> 
      tokenize_float line acc (float_of_int mul) (float_of_int i) 10. stream
  |'e' ->
      tokenize_exp line acc (float_of_int (mul * i)) 0 1 stream
  | c  -> 
      raise (Bad_format 
        (Printf.sprintf "Cannot parse OBJ file, expected int (char %c, line %i)" c line))

and tokenize_float line acc mul i r stream =
  match Stream.next stream with
  |'0'..'9' as c -> 
      tokenize_float line acc mul (i +. float_of_int (Char.code c - 48) /. r) (r*.10.) stream
  |' ' |'\r' -> 
      tokenize_obj line (Number (Float (mul *. i)) :: acc) stream
  |'e' ->
      tokenize_exp line acc (mul *. i) 0 1 stream
  |'/' ->
      tokenize_obj line (Slash :: Number (Float (mul *. i)) :: acc) stream
  |'\n' -> 
      tokenize_obj (line + 1) (Number (Float (mul *. i)) :: acc) stream
  | c -> raise (Bad_format (Printf.sprintf "Cannot parse OBJ file, expected float (char %c, line %i)" c line))

and tokenize_exp line acc f e sign stream = 
  match Stream.next stream with
  |'0'..'9' as c -> 
      tokenize_exp line acc f (e * 10 + (Char.code c - 48)) sign stream
  |' ' |'\r' ->
      tokenize_obj line (Number (Float (f *. (10. ** (float_of_int (sign * e))))) :: acc) stream
  |'/' ->
      tokenize_obj line (Slash :: Number (Float (f *. (10. ** (float_of_int (sign * e))))) :: acc) stream
  |'-' ->
      tokenize_exp line acc f e (-1) stream
  |'\n' -> 
      tokenize_obj (line + 1) (Number (Float (f *. (10. ** (float_of_int (sign * e))))) :: acc) stream
  | c -> raise (Bad_format (Printf.sprintf "Cannot parse OBJ file, expected exp (char %c, line %i)" c line))

and tokenize_obj line acc stream = 
  junk_spaces stream;
  match Stream.peek stream with
  |Some(c) -> begin
    match c with
    |'0'..'9' -> 
        tokenize_nb line acc 1 0 stream
    |'-' -> 
        Stream.junk stream; 
        junk_spaces stream; 
        tokenize_nb line acc (-1) 0 stream
    |'.' -> 
        Stream.junk stream; 
        tokenize_float line acc 1. 0. 10. stream
    |'/' -> 
        Stream.junk stream;
        tokenize_obj line (Slash :: acc) stream
    |'v' -> begin
      Stream.junk stream;
      match Stream.next stream with
      |' ' -> tokenize_obj line (V::acc) stream
      |'t' -> Stream.junk stream; tokenize_obj line (VT :: acc) stream
      |'n' -> Stream.junk stream; tokenize_obj line (VN :: acc) stream
      | _  -> junk_line stream; tokenize_obj (line + 1) acc stream
    end
    |'f' -> Stream.junk stream; tokenize_obj line (F :: acc) stream
    | _  -> 
        junk_line stream; 
        tokenize_obj (line + 1) acc stream
  end
  |None -> List.rev acc

(** Parser **)
let rec pprint l n = 
  match l with
  |_ when n = 0 -> print_endline ""
  |[] -> print_endline ""
  |V  :: t -> Printf.printf "v "; pprint t (n-1)
  |VT :: t -> Printf.printf "vt "; pprint t (n-1)
  |VN :: t -> Printf.printf "vn "; pprint t (n-1)
  |F :: t -> Printf.printf "f "; pprint t (n-1)
  |Number (Int i) :: t -> Printf.printf "%i " i; pprint t (n-1)
  |Number (Float f) :: t -> Printf.printf "%f " f; pprint t (n-1)
  |Slash :: t -> Printf.printf "/"; pprint t (n-1)

let rec parse_point = function
  |Number (Int x) :: Slash :: Number (Int y) :: Slash :: Number (Int z) :: t -> ((Some x, Some y, Some z), t)
  |Number (Int x) :: Slash :: Slash :: Number (Int z) :: t -> ((Some x, None, Some z), t)
  |Number (Int x) :: Slash :: Number (Int y) :: Slash :: t -> ((Some x, Some y, None), t)
  |Number (Int x) :: Slash :: Number (Int y) :: t -> ((Some x, Some y, None), t)
  |Number (Int x) :: Slash :: Slash :: t-> ((Some x, None, None), t)
  |Number (Int x) :: Slash :: t -> ((Some x, None, None), t)
  |Number (Int x) :: t -> ((Some x, None, None), t)
  | _ -> raise (Bad_format "Cannot parse OBJ file : bad point format")

let rec parse_triangle l = 
  let (pt1, l) = parse_point l in
  let (pt2, l) = parse_point l in
  let (pt3, l) = parse_point l in
  ((pt1, pt2, pt3), l)

let to_float = function
  |Int i -> float_of_int i
  |Float f -> f

let rec parse_tokens lv lvt lvn lf = function
  |[] -> (lv, lvt, lvn, lf)
  |V :: Number x :: Number y :: Number z :: t-> 
      let x,y,z = to_float x, to_float y, to_float z in
      parse_tokens
        (OgamlMath.Vector3f.({x;y;z}) :: lv)
        lvt lvn lf t
  |VT :: Number x :: Number y :: t ->
      let x,y = to_float x, to_float y in
      parse_tokens
        lv
        (OgamlMath.Vector2f.({x;y}) :: lvt)
        lvn lf t
  |VN :: Number x :: Number y :: Number z :: t ->
      let x,y,z = to_float x, to_float y, to_float z in
      parse_tokens
        lv lvt
        (OgamlMath.Vector3f.({x;y;z}) :: lvn)
        lf t
  |F :: l -> 
      let ((a,b,c),l) = parse_triangle l in
      parse_tokens lv lvt lvn (a :: b :: c :: lf) l
  | _ -> raise (Bad_format "Cannot parse OBJ file")

let from_obj ?scale:(scale = 1.0) ?color:(color = `RGB Color.RGB.white) data src = 
  let lv, lvt, lvn, lf = 
    match data with
    |`String str -> 
      let stream = (Stream.of_string str) in
      let tokens = tokenize_obj 0 [] stream in
      parse_tokens [] [] [] [] tokens
    |`File   str -> 
      let chan = open_in str in
      let stream = (Stream.of_channel chan) in
      let tokens = tokenize_obj 0 [] stream in
      let res = parse_tokens [] [] [] [] tokens in
      close_in chan;
      res
  in
  let av, avt, avn = 
    Array.of_list lv,
    Array.of_list lvt,
    Array.of_list lvn
  in
  List.iter (fun (v,u,n) ->
    let position = 
      if VertexArray.Source.requires_position src then begin
        match v with
        |None -> raise (Bad_format "Vertex positions requested but not provided")
        |Some v when v > 0 -> Some (OgamlMath.Vector3f.prop scale (av.(Array.length av - v)))
        |Some v -> Some (OgamlMath.Vector3f.prop scale (av.(- v - 1)))
      end else None
    in
    let texcoord = 
      if VertexArray.Source.requires_uv src then begin
        match u with
        |None -> raise (Bad_format "UV coordinates requested but not provided")
        |Some v when v > 0 -> Some (avt.(Array.length avt - v))
        |Some v -> Some (avt.(- v - 1))
      end else None
    in
    let normal = 
      if VertexArray.Source.requires_normal src then begin
        match n with
        |None -> raise (Bad_format "Normals requested but not provided")
        |Some v when v > 0 -> Some (avn.(Array.length avn - v))
        |Some v -> Some (avn.(- v - 1))
      end else None
    in
    let color = 
      if VertexArray.Source.requires_color src then Some color
      else None
    in
    VertexArray.(Source.add src (Vertex.create ?position ?texcoord ?color ?normal ()))
  ) lf; src



*)
