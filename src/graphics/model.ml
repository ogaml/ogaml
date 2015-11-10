
exception Bad_format of string

let read_file filename =
  let chan = open_in filename in
  let len = in_channel_length chan in
  let str = Bytes.create len in
  really_input chan str 0 len;
  close_in chan; str

let to_source = function
  | `File   s -> read_file s
  | `String s -> s

type tokens = Slash | Float of float | Int of int | F | VT | VN | V

let rec junk_spaces stream = 
  match Stream.peek stream with
  |Some ' ' -> Stream.junk stream; junk_spaces stream
  | _ -> ()

let rec junk_line stream = 
  match Stream.next stream with
  |'\n' -> ()
  | _   -> junk_line stream

let rec tokenize_nb i stream = 
  match Stream.next stream with
  |'0'..'9' as c -> tokenize_nb (i*10 + (Char.code c - 48)) stream
  |' ' -> Int i
  |'.' -> Float (tokenize_float (float_of_int i) 10. stream)
  | _  -> raise (Bad_format "Cannot parse OBJ file, expected int")

and tokenize_float i r stream =
  match Stream.next stream with
  |'0'..'9' as c -> tokenize_float (i +. float_of_int (Char.code c - 48) /. r) (r*.10.) stream
  |' ' -> i
  | _ -> raise (Bad_format ("Cannot parse OBJ file, expected float"))

and tokenize_obj stream = 
  junk_spaces stream;
  match Stream.peek stream with
  |Some(c) -> begin
    match c with
    |'0'..'9' -> (tokenize_nb 0 stream :: (tokenize_obj stream))
    |'-' -> 
        Stream.junk stream; 
        junk_spaces stream; 
        begin 
          match tokenize_nb 0 stream with
          |Int i -> (Int (-i) :: (tokenize_obj stream))
          |Float f -> (Float (-.f) :: (tokenize_obj stream))
          | _ -> assert false
        end
    |'.' -> 
        Stream.junk stream; 
        (Float(tokenize_float 0. 10. stream) :: (tokenize_obj stream))
    |'/' -> 
        Stream.junk stream;
        (Slash :: (tokenize_obj stream))
    |'v' -> begin
      Stream.junk stream;
      match Stream.next stream with
      |' ' -> V :: (tokenize_obj stream)
      |'t' -> VT :: (tokenize_obj stream)
      |'n' -> VN :: (tokenize_obj stream)
      | _  -> junk_line stream; tokenize_obj stream
    end
    |'f' -> F :: (tokenize_obj stream)
    | _  -> 
        junk_line stream; 
        tokenize_obj stream
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
      let (tri,l) = parse_triangle l in
      parse_tokens lv lvt lvn (tri :: lf) l
  | _ -> raise (Bad_format "Cannot parse OBJ file")


let from_obj ?scale:(scale = 1.0) ?color:(color = `RGB Color.RGB.white) data src = 
  let str = to_source data in
  let lines = Str.split (Str.regexp "[\r\n]+") str in
  let vtable = ref [] in
  let ntable = ref [] in
  let ttable = ref [] in
  let ftable = ref [] in
  List.iteri(fun i line ->
    try 
      Scanf.sscanf line "%s" (function
        |"v"  -> Scanf.sscanf line "%_s %f %f %f" 
                (fun x y z -> vtable := OgamlMath.Vector3f.({x;y;z})::!vtable)
        |"vt" -> Scanf.sscanf line "%_s %f %f" 
                (fun x y -> ttable := (x,y)::!ttable)
        |"vn" -> Scanf.sscanf line "%_s %f %f %f"
                (fun x y z -> ntable := OgamlMath.Vector3f.({x;y;z})::!ntable)
        |"f"  -> begin
          try 
            Scanf.sscanf line "%_s %i/%i/%i %i/%i/%i %i/%i/%i%_s"
                (fun a1 b1 c1 a2 b2 c2 a3 b3 c3 -> ftable := 
                    (Some a1, Some b1, Some c1) :: 
                    (Some a2, Some b2, Some c2) :: 
                    (Some a3, Some b3, Some c3) :: !ftable)
          with Scanf.Scan_failure _ -> begin
            try
              Scanf.sscanf line "%_s %i//%i %i//%i %i//%i%_s"
                  (fun a1 c1 a2 c2 a3 c3 -> ftable := 
                      (Some a1,None,Some c1) :: 
                      (Some a2,None,Some c2) :: 
                      (Some a3,None,Some c3) :: !ftable)
            with Scanf.Scan_failure _ -> begin
              try 
                Scanf.sscanf line "%_s %i/%i %i/%i %i/%i%_s"
                    (fun a1 b1 a2 b2 a3 b3 -> ftable := 
                        (Some a1,Some b1,None) :: 
                        (Some a2,Some b2,None) :: 
                        (Some a3,Some b3,None) :: !ftable)
              with Scanf.Scan_failure _ -> begin
                Scanf.sscanf line "%_s %i %i %i%_s"
                    (fun a1 a2 a3 -> ftable := 
                        (Some a1,None,None) :: 
                        (Some a2,None,None) :: 
                        (Some a3,None,None) :: !ftable)
              end
            end
          end
          end
        | _   -> ())
    with Scanf.Scan_failure _ -> raise (Bad_format (
        Printf.sprintf "Bad OBJ format line %i : %s" i line
      ))
    ) lines;
  let vertices = Array.of_list !vtable in
  let normals  = Array.of_list !ntable in
  let uvs      = Array.of_list !ttable in
  let nv, nn, nu = 
      Array.length vertices, 
      Array.length normals, 
      Array.length uvs 
  in
  List.iter (fun (v,u,n) ->
    let position = 
      match v with
      |None when VertexArray.Source.requires_position src -> 
          raise (Bad_format "Vertex positions requested but not provided")
      | _ when not (VertexArray.Source.requires_position src) -> None
      |Some v when v > 0 -> Some (OgamlMath.Vector3f.prop scale (vertices.(nv - v)))
      |Some v -> Some (OgamlMath.Vector3f.prop scale (vertices.(- v - 1)))
      | _ -> assert false
    in    
    let texcoord = 
      match u with
      |None when VertexArray.Source.requires_uv src -> 
          raise (Bad_format "UV coordinates requested but not provided")
      | _ when not (VertexArray.Source.requires_uv src) -> None
      |Some v when v > 0 -> Some (uvs.(nu - v))
      |Some v -> Some (uvs.(-v - 1))
      | _ -> assert false
    in
    let normal = 
      match n with
      |None when VertexArray.Source.requires_normal src -> 
          raise (Bad_format "Normals requested but not provided")
      | _ when not (VertexArray.Source.requires_normal src) -> None
      |Some v when v > 0 -> Some (normals.(nn - v))
      |Some v -> Some (normals.(- v - 1))
      | _ -> assert false
    in
    let color = 
      if VertexArray.Source.requires_color src then Some color
      else None
    in
    VertexArray.(Source.add src (Vertex.create ?position ?texcoord ?color ?normal ()))
  ) !ftable; src




