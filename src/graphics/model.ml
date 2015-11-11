
exception Bad_format of string

(** OBJ Parsing **)

(** Tokenizer **)
type nb = Int of int | Float of float

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




