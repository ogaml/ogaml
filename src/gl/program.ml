
exception Compilation_error of string

exception Linking_error of string

exception Invalid_version of string


module Uniform = struct

  type t = {name : string; kind : Enum.GlslType.t; location : int}

  let name u = u.name

  let kind u = u.kind

  let location u = u.location

end


module Attribute = struct

  type t = {name : string; kind : Enum.GlslType.t; location : int}

  let name a = a.name

  let kind a = a.kind

  let location a = a.location

end


type t = { 
           program    : Internal.Program.t; 
           vertex     : Internal.Shader.t;
           fragment   : Internal.Shader.t;
           uniforms   : Uniform.t   list;
           attributes : Attribute.t list
         }

let from_source state ~vertex_source ~fragment_source =
  let program = Internal.Program.create () in
  let vshader = Internal.Shader.create Enum.ShaderType.Vertex   in
  let fshader = Internal.Shader.create Enum.ShaderType.Fragment in
  Internal.Shader.source vshader vertex_source;
  Internal.Shader.source fshader fragment_source;
  Internal.Shader.compile vshader;
  Internal.Shader.compile fshader;
  if Internal.Shader.status vshader = false then begin
    let log = Internal.Shader.log vshader in
    let msg = Printf.sprintf "Error while compiling vertex shader : %s" log in
    raise (Compilation_error msg)
  end;
  if Internal.Shader.status fshader = false then begin
    let log = Internal.Shader.log fshader in
    let msg = Printf.sprintf "Error while compiling vertex shader : %s" log in
    raise (Compilation_error msg)
  end;
  Internal.Program.attach program vshader;
  Internal.Program.attach program fshader;
  Internal.Program.link program;
  if Internal.Program.status program = false then begin
    let log = Internal.Program.log program in
    let msg = Printf.sprintf "Error while linking GLSL program : %s" log in
    raise (Linking_error msg)
  end;
  let rec uniforms = function
    |0 -> []
    |n -> begin
      let name = Internal.Program.uname program (n - 1) in
      let kind = Internal.Program.utype program (n - 1) in
      let location = Internal.Program.uloc program name in
      {
        Uniform.name = name; 
        Uniform.kind = kind; 
        Uniform.location = location
      } :: (uniforms (n-1))
    end
  in
  let rec attributes = function
    |0 -> []
    |n -> begin
      let name = Internal.Program.aname program (n - 1) in
      let kind = Internal.Program.atype program (n - 1) in
      let location = Internal.Program.aloc program name in
      {
        Attribute.name = name; 
        Attribute.kind = kind; 
        Attribute.location = location
      } :: (attributes (n-1))
    end
  in
  {
    program;
    vertex   = vshader;
    fragment = fshader;
    uniforms = uniforms (Internal.Program.ucount program);
    attributes = attributes (Internal.Program.acount program);
  }
 

let from_source_list state ~vertex_source ~fragment_source =
  let list_vshader = 
    List.sort (fun (v,_) (v',_) -> - (compare v v')) vertex_source
  in
  let list_fshader = 
    List.sort (fun (v,_) (v',_) -> - (compare v v')) fragment_source
  in
  let best_vshader = 
    List.find (fun (v,_) -> State.is_glsl_version_supported state v) list_vshader
    |> snd
  in
  let best_fshader = 
    List.find (fun (v,_) -> State.is_glsl_version_supported state v) list_fshader
    |> snd
  in
  from_source state ~vertex_source:best_vshader ~fragment_source:best_fshader


let use state prog = 
  match prog with
  |None when State.linked_program state <> None -> begin
    State.set_linked_program state None;
    Internal.Program.use None
  end
  |Some(p) when State.linked_program state <> Some p.program -> begin
    State.set_linked_program state (Some p.program);
    Internal.Program.use (Some p.program);
  end
  | _ -> ()


let iter_uniforms prog f = List.iter f prog.uniforms

let iter_attributes prog f = List.iter f prog.attributes


