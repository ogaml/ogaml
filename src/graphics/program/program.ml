
exception Compilation_error of string

exception Linking_error of string

exception Invalid_version of string


module Uniform = ProgramInternal.Uniform


module Attribute = ProgramInternal.Attribute


type t = ProgramInternal.t


type src = [`File of string | `String of string]


let read_file filename =
  let chan = open_in filename in
  let len = in_channel_length chan in
  let str = Bytes.create len in
  really_input chan str 0 len;
  close_in chan; str


let to_source = function
  | `File   s -> read_file s
  | `String s -> s


let from_source (type s) (module M : RenderTarget.T with type t = s)
  ~target ~vertex_source ~fragment_source =
  let vertex = to_source vertex_source   in
  let fragment = to_source fragment_source in
  let state = M.state target in
  try 
    ProgramInternal.create ~vertex ~fragment ~id:(State.LL.program_id state)
  with 
  | ProgramInternal.Compilation_error s -> raise (Compilation_error s)
  | ProgramInternal.Linking_error     s -> raise (Linking_error s)
  | ProgramInternal.Invalid_version   s -> raise (Invalid_version s)
 

let from_source_list (type s) (module M : RenderTarget.T with type t = s)
  ~target ~vertex_source ~fragment_source =
  let vertex = List.map (fun (v,s) -> (v, to_source s)) vertex_source in
  let fragment = List.map (fun (v,s) -> (v, to_source s)) fragment_source in
  let state = M.state target in
  try 
    ProgramInternal.create_list
      ~vertex ~fragment ~id:(State.LL.program_id state)
      ~version:(State.glsl_version state)
  with 
  | ProgramInternal.Compilation_error s -> raise (Compilation_error s)
  | ProgramInternal.Linking_error     s -> raise (Linking_error s)
  | ProgramInternal.Invalid_version   s -> raise (Invalid_version s)
 

let from_source_pp (type s) (module M : RenderTarget.T with type t = s)
  ~target ~vertex_source ~fragment_source =
  let vertex   = to_source vertex_source   in
  let fragment = to_source fragment_source in
  let state = M.state target in
  try 
    ProgramInternal.create_pp
      ~vertex ~fragment ~id:(State.LL.program_id state)
      ~version:(State.glsl_version state)
  with 
  | ProgramInternal.Compilation_error s -> raise (Compilation_error s)
  | ProgramInternal.Linking_error     s -> raise (Linking_error s)
  | ProgramInternal.Invalid_version   s -> raise (Invalid_version s)
 

module LL = struct

  let use state prog = 
    match prog with
    |None when State.LL.linked_program state <> None -> begin
      State.LL.set_linked_program state None;
      GL.Program.use None
    end
    |Some(p) when State.LL.linked_program state <> Some p.ProgramInternal.id -> begin
      State.LL.set_linked_program state (Some p.ProgramInternal.id);
      GL.Program.use (Some p.ProgramInternal.program);
    end
    | _ -> ()

  let iter_uniforms prog f = List.iter f prog.ProgramInternal.uniforms

  let iter_attributes prog f = List.iter f prog.ProgramInternal.attributes

end
