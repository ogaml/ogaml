
exception Bad_format of string

type tokens = Slash | Float of float | Int of int | F | VT | VN | V

let rec junk_spaces stream = 
  match Stream.peek stream with
  |Some ' ' -> Stream.junk stream; junk_spaces stream
  | _ -> ()

let rec junk_line stream = 
  match Stream.next stream with
  |'\n' -> ()
  | _   -> junk_line stream

let rec tokenize_nb line i stream = 
  match Stream.next stream with
  |'0'..'9' as c -> tokenize_nb line (i*10 + (Char.code c - 48)) stream
  |' ' |'\n' |'\r' -> Int i
  |'.' -> Float (tokenize_float line (float_of_int i) 10. stream)
  | c  -> raise (Bad_format (Printf.sprintf "Cannot parse OBJ file, expected int (char %c, line %i)" c line))

and tokenize_float line i r stream =
  match Stream.next stream with
  |'0'..'9' as c -> tokenize_float line (i +. float_of_int (Char.code c - 48) /. r) (r*.10.) stream
  |' ' | '\n' |'\r' -> i
  | c -> raise (Bad_format (Printf.sprintf "Cannot parse OBJ file, expected float (char %c, line %i)" c line))

and tokenize_obj line stream = 
  junk_spaces stream;
  match Stream.peek stream with
  |Some(c) -> begin
    print_char c;
    match c with
    |'0'..'9' -> 
        let tt = tokenize_nb line 0 stream in
        tt :: (tokenize_obj line stream)
    |'-' -> 
        Stream.junk stream; 
        junk_spaces stream; 
        begin 
          match tokenize_nb line 0 stream with
          |Int i -> (Int (-i) :: (tokenize_obj line stream))
          |Float f -> (Float (-.f) :: (tokenize_obj line stream))
          | _ -> assert false
        end
    |'.' -> 
        Stream.junk stream; 
        let tt = tokenize_float line 0. 10. stream in
        (Float tt :: (tokenize_obj line stream))
    |'/' -> 
        Stream.junk stream;
        (Slash :: (tokenize_obj line stream))
    |'v' -> begin
      Stream.junk stream;
      match Stream.next stream with
      |' ' -> V :: (tokenize_obj line stream)
      |'t' -> Stream.junk stream; VT :: (tokenize_obj line stream)
      |'n' -> Stream.junk stream; VN :: (tokenize_obj line stream)
      | _  -> junk_line stream; tokenize_obj (line + 1) stream
    end
    |'f' -> Stream.junk stream; F :: (tokenize_obj line stream)
    | _  -> 
        junk_line stream; 
        tokenize_obj (line + 1) stream
  end
  |None -> []

let rec parse_point = function
  |Int x :: Slash :: Int y :: Slash :: Int z :: t -> ((Some x, Some y, Some z), t)
  |Int x :: Slash :: Slash :: Int z :: t -> ((Some x, None, Some z), t)
  |Int x :: Slash :: Int y :: Slash :: t -> ((Some x, Some y, None), t)
  |Int x :: Slash :: Int y :: t -> ((Some x, Some y, None), t)
  |Int x :: Slash :: Slash :: t-> ((Some x, None, None), t)
  |Int x :: Slash :: t -> ((Some x, None, None), t)
  |Int x :: t -> ((Some x, None, None), t)
  | _ -> raise (Bad_format "Cannot parse OBJ file : bad point format")

let rec parse_triangle l = 
  let (pt1, l) = parse_point l in
  let (pt2, l) = parse_point l in
  let (pt3, l) = parse_point l in
  ((pt1, pt2, pt3), l)

let rec parse_tokens lv lvt lvn lf = function
  |[] -> (lv, lvt, lvn, lf)
  |V :: Float x :: Float y :: Float z :: t-> 
      parse_tokens
        (OgamlMath.Vector3f.({x;y;z}) :: lv)
        lvt lvn lf t
  |VT :: Float x :: Float y :: t ->
      parse_tokens
        lv
        (OgamlMath.Vector2f.({x;y}) :: lvt)
        lvn lf t
  |VN :: Float x :: Float y :: Float z :: t ->
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
      tokenize_obj 0 stream |> parse_tokens [] [] [] []
    |`File   str -> 
      let chan = open_in str in
      let stream = (Stream.of_channel chan) in
      let res = tokenize_obj 0 stream |> parse_tokens [] [] [] [] in
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
        match v with
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




