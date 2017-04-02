
exception Program_error of string


module Uniform = ProgramInternal.Uniform


module Attribute = ProgramInternal.Attribute


type t = ProgramInternal.t


type src = [`File of string | `String of string]


let read_file filename =
  let chan = open_in_bin filename in
  let len = in_channel_length chan in
  let str = Bytes.create len in
  really_input chan str 0 len;
  close_in chan; str


let to_source = function
  | `File   s -> read_file s
  | `String s -> s


let from_source (type s) (module M : RenderTarget.T with type t = s)
  ?log ~context ~vertex_source ~fragment_source () = 
  let vertex = to_source vertex_source   in
  let fragment = to_source fragment_source in
  let context = M.context context in
  let idpool = Context.LL.program_pool context in
  let id = Context.ID_Pool.get_next idpool in
  try 
    let prog = ProgramInternal.create ~vertex ~fragment ~id in
    Gc.finalise (fun _ -> 
      Context.ID_Pool.free idpool id;
      if Context.LL.linked_program context = Some id then 
        Context.LL.set_linked_program context None
    ) prog;
    prog
  with 
  | ProgramInternal.Program_internal_error s -> 
      begin match log with
      | None   -> ()
      | Some l -> OgamlUtils.Log.error l "%s" !(ProgramInternal.last_log)
      end;
      raise (Program_error s)
 

let from_source_list (type s) (module M : RenderTarget.T with type t = s)
  ?log ~context ~vertex_source ~fragment_source () = 
  let vertex = List.map (fun (v,s) -> (v, to_source s)) vertex_source in
  let fragment = List.map (fun (v,s) -> (v, to_source s)) fragment_source in
  let context = M.context context in
  let idpool = Context.LL.program_pool context in
  let id = Context.ID_Pool.get_next idpool in
  try 
    let prog =
      ProgramInternal.create_list
        ~vertex ~fragment ~id
        ~version:(Context.glsl_version context)
    in
    Gc.finalise (fun _ -> 
      Context.ID_Pool.free idpool id;
      if Context.LL.linked_program context = Some id then 
        Context.LL.set_linked_program context None
    ) prog;
    prog
  with 
  | ProgramInternal.Program_internal_error s ->
      begin match log with
      | None   -> ()
      | Some l -> OgamlUtils.Log.error l "%s" !(ProgramInternal.last_log)
      end;
      raise (Program_error s)
 

let from_source_pp (type s) (module M : RenderTarget.T with type t = s)
  ?log ~context ~vertex_source ~fragment_source () =
  let vertex   = to_source vertex_source   in
  let fragment = to_source fragment_source in
  let context = M.context context in
  let idpool = Context.LL.program_pool context in
  let id = Context.ID_Pool.get_next idpool in
  try 
    let prog =
      ProgramInternal.create_pp
        ~vertex ~fragment ~id
        ~version:(Context.glsl_version context)
    in
    Gc.finalise (fun _ -> 
      Context.ID_Pool.free idpool id;
      if Context.LL.linked_program context = Some id then 
        Context.LL.set_linked_program context None
    ) prog;
    prog
  with 
  | ProgramInternal.Program_internal_error s -> 
      begin match log with
      | None   -> ()
      | Some l -> OgamlUtils.Log.error l "%s" !(ProgramInternal.last_log)
      end;
      raise (Program_error s)
 

module LL = struct

  let use context prog = 
    match prog with
    |None when Context.LL.linked_program context <> None -> begin
      Context.LL.set_linked_program context None;
      GL.Program.use None
    end
    |Some(p) when Context.LL.linked_program context <> Some p.ProgramInternal.id -> begin
      Context.LL.set_linked_program context (Some (p.ProgramInternal.program, p.ProgramInternal.id));
      GL.Program.use (Some p.ProgramInternal.program);
    end
    | _ -> ()

  let uniforms prog = prog.ProgramInternal.uniforms

  let attributes prog = prog.ProgramInternal.attributes

end
