
exception GLSL_error of string

type t

type kind = Fragment | Vertex


(* Abstract functions *)

external abstract_log : t -> (string * int) = "caml_gl_shader_infolog"

external abstract_create_fragment : unit -> t = "caml_gl_create_fragment_shader"

external abstract_create_vertex : unit -> t = "caml_gl_create_vertex_shader"

external abstract_source : string -> t -> unit = "caml_gl_source_shader"

external abstract_compile : t -> unit = "caml_gl_compile_shader"

external abstract_compiled : t -> bool = "caml_gl_shader_compiled"

let abstract_debug sh k arg = 
  let s,l = abstract_log sh in
  let s   = String.sub s 0 l in
  if abstract_compiled sh && s <> "" then print_endline s
  else if not (abstract_compiled sh) then begin
    let shader_name = 
      match (k,arg) with
      |Fragment, `String _ -> "fragment shader"
      |Vertex  , `String _ -> "vertex shader"
      | _      , `File   s -> s
    in
    raise (GLSL_error (Printf.sprintf "Error compiling %s : %s" shader_name s))
  end

let abstract_read_file filename =
  let chan = open_in filename in
  let len = in_channel_length chan in
  let str = Bytes.create len in
  really_input chan str 0 len;
  close_in chan; str


(* Exposed functions *)
let recommended_version () = 
  let s = Config.glsl_version () in
  let pt1 = String.index s '.' in
  let sp = 
    try String.index s ' ' 
    with Not_found -> String.length s
  in
  let pt2 = 
    try String.index_from s (pt1+1) '.' 
    with Not_found -> sp
  in
  let major = String.sub s 0 pt1 in
  let minor = String.sub s (pt1+1) (min sp pt2 - pt1 - 1) in
  int_of_string (major ^ minor)


let create ?version arg k = 
  let sh = 
    match k with
    |Fragment -> abstract_create_fragment ()
    |Vertex   -> abstract_create_vertex   ()
  in
  let src = 
    match arg with
    |`File s   -> abstract_read_file s
    |`String s -> s
  in
  let src_app = 
    match version with
    |None -> src
    |Some v -> Printf.sprintf "#version %i\n\n%s" v src
  in
  abstract_source src_app sh;
  abstract_compile sh;
  abstract_debug sh k arg;
  sh



