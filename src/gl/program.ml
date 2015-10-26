
exception Program_error of string

type program

type attribute = int

type uniform = int

type t = {
  prog  : program;
  unifs : (string, uniform) Hashtbl.t;
  attrs : (string, attribute) Hashtbl.t
}

external abstract_create : unit -> program = "caml_gl_create_program"

external abstract_attach : Shader.t -> program -> unit = "caml_gl_attach_shader"

external abstract_uniform_location : program -> string -> uniform
  = "caml_gl_uniform_location"

external abstract_attrib_location : program -> string -> attribute
  = "caml_gl_attrib_location"

external abstract_use : program option -> unit = "caml_gl_use_program"


let create () = 
  let p = abstract_create () in
  {
   prog  = p; 
   unifs = Hashtbl.create 13;
   attrs = Hashtbl.create 13
  }

let attach s p = 
  abstract_attach s p.prog; p

let add_uniform s p = 
  let loc = abstract_uniform_location p.prog s in
  if loc = -1 then
    raise 
      (Program_error 
        (Printf.sprintf "Cannot bind uniform %s" s)
      )
  else Hashtbl.add p.unifs s loc;
  p

let add_attribute s p = 
  let loc = abstract_attrib_location p.prog s in
  if loc = -1 then
    raise 
      (Program_error 
        (Printf.sprintf "Cannot bind attribute %s" s)
      )
  else Hashtbl.add p.attrs s loc;
  p

let uniform p s = 
  try 
    Hashtbl.find p.unifs s
  with
    Not_found -> raise 
        (Program_error
          (Printf.sprintf "Uniform %s not found. Did you bind it before ?" s)
        )

let attribute p s = 
  try 
    Hashtbl.find p.attrs s
  with
    Not_found -> raise 
        (Program_error
          (Printf.sprintf "Attribute %s not found. Did you bind it before ?" s)
        )

let build ~shaders ~uniforms ~attributes =
  let p = create () in
  List.iter (fun s -> attach s p |> ignore) shaders;
  List.iter (fun s -> add_uniform   s p |> ignore) uniforms;
  List.iter (fun s -> add_attribute s p |> ignore) attributes;
  p

let use p = 
  match p with
  |None -> abstract_use None
  |Some p' -> abstract_use (Some p'.prog)
