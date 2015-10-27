
exception GLSL_error of Error.t * string

type t

type kind = Fragment | Vertex


(* Abstract functions *)

external abstract_log : t -> (string * int) = "caml_gl_shader_infolog"

external abstract_create_fragment : unit -> t = "caml_gl_create_fragment_shader"

external abstract_create_vertex : unit -> t = "caml_gl_create_vertex_shader"

external abstract_source : string -> t -> unit = "caml_gl_source_shader"

external abstract_compile : t -> unit = "caml_gl_compile_shader"

let abstract_debug sh = 
  let s,l = abstract_log sh in
  let s   = String.sub s 0 l in
  match Error.get () with
  | None -> if s <> "" then print_endline s
  | Some e -> raise (GLSL_error (e,s))

let abstract_read_file filename =
  let chan = open_in filename in
  let len = in_channel_length chan in
  let str = Bytes.create len in
  really_input chan str 0 len;
  close_in chan; str


(* Exposed functions *)

let create arg k = 
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
  abstract_source src sh;
  abstract_compile sh;
  abstract_debug sh;
  sh



