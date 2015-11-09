
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




