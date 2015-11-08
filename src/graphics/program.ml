
exception Compilation_error of string

exception Linking_error of string

exception Invalid_version of string


module Uniform = struct

  type t = {name : string; kind : GL.Types.GlslType.t; location : GL.Program.u_location}

  let name u = u.name

  let kind u = u.kind

  let location u = u.location

end


module Attribute = struct

  type t = {name : string; kind : GL.Types.GlslType.t; location : GL.Program.a_location}

  let name a = a.name

  let kind a = a.kind

  let location a = a.location

end


type t = { 
           program    : GL.Program.t; 
           vertex     : GL.Shader.t;
           fragment   : GL.Shader.t;
           uniforms   : Uniform.t   list;
           attributes : Attribute.t list
         }

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

let from_source ~vertex_source ~fragment_source =
  let vertex_source   = to_source vertex_source   in
  let fragment_source = to_source fragment_source in
  let program = GL.Program.create () in
  let vshader = GL.Shader.create GL.Types.ShaderType.Vertex   in
  let fshader = GL.Shader.create GL.Types.ShaderType.Fragment in
  if not (GL.Shader.valid vshader) ||
     not (GL.Shader.valid fshader) ||
     not (GL.Program.valid program) then
    raise (Compilation_error "Failed to create a GLSL program , the GL context may not be initialized");
  GL.Shader.source vshader vertex_source;
  GL.Shader.source fshader fragment_source;
  GL.Shader.compile vshader;
  GL.Shader.compile fshader;
  if GL.Shader.status vshader = false then begin
    let log = GL.Shader.log vshader in
    let msg = Printf.sprintf "Error while compiling vertex shader : %s" log in
    raise (Compilation_error msg)
  end;
  if GL.Shader.status fshader = false then begin
    let log = GL.Shader.log fshader in
    let msg = Printf.sprintf "Error while compiling fragment shader : %s" log in
    raise (Compilation_error msg)
  end;
  GL.Program.attach program vshader;
  GL.Program.attach program fshader;
  GL.Program.link program;
  if GL.Program.status program = false then begin
    let log = GL.Program.log program in
    let msg = Printf.sprintf "Error while linking GLSL program : %s" log in
    raise (Linking_error msg)
  end;
  let rec uniforms = function
    |0 -> []
    |n -> begin
      let name = GL.Program.uname program (n - 1) in
      let kind = GL.Program.utype program (n - 1) in
      let location = GL.Program.uloc program name in
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
      let name = GL.Program.aname program (n - 1) in
      let kind = GL.Program.atype program (n - 1) in
      let location = GL.Program.aloc program name in
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
    uniforms = uniforms (GL.Program.ucount program);
    attributes = attributes (GL.Program.acount program);
  }
 

let from_source_list st ~vertex_source ~fragment_source =
  let list_vshader = 
    List.sort (fun (v,_) (v',_) -> - (compare v v')) vertex_source
  in
  let list_fshader = 
    List.sort (fun (v,_) (v',_) -> - (compare v v')) fragment_source
  in
  try 
    let best_vshader = 
      List.find (fun (v,_) -> State.is_glsl_version_supported st v) list_vshader
      |> snd
    in
    let best_fshader = 
      List.find (fun (v,_) -> State.is_glsl_version_supported st v) list_fshader
      |> snd
    in
    from_source ~vertex_source:best_vshader ~fragment_source:best_fshader
  with Not_found -> raise (Invalid_version "No supported GLSL version provided")


let from_source_pp st ~vertex_source ~fragment_source =
  let vertex_source   = to_source vertex_source   in
  let fragment_source = to_source fragment_source in
  let version = State.glsl_version st in
  let vsource = Printf.sprintf "#version %i\n\n%s" version vertex_source in
  let fsource = Printf.sprintf "#version %i\n\n%s" version fragment_source in
  from_source 
    ~vertex_source:(`String vsource)
    ~fragment_source:(`String fsource)


module LL = struct

  let use state prog = 
    match prog with
    |None when State.LL.linked_program state <> None -> begin
      State.LL.set_linked_program state None;
      GL.Program.use None
    end
    |Some(p) when State.LL.linked_program state <> Some p.program -> begin
      State.LL.set_linked_program state (Some p.program);
      GL.Program.use (Some p.program);
    end
    | _ -> ()


  let iter_uniforms prog f = List.iter f prog.uniforms

  let iter_attributes prog f = List.iter f prog.attributes

end
