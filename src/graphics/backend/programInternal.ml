
exception Program_internal_error of string


module Uniform = struct

  type t = {name : string; kind : GLTypes.GlslType.t; location : GL.Program.u_location}

  let name u = u.name

  let kind u = u.kind

  let location u = u.location

end


module Attribute = struct

  type t = {name : string; kind : GLTypes.GlslType.t; location : GL.Program.a_location}

  let name a = a.name

  let kind a = a.kind

  let location a = a.location

end


type t = 
  { 
    id : int;
    program    : GL.Program.t; 
    uniforms   : Uniform.t   list;
    attributes : Attribute.t list
  }

let last_log = ref ""

let create ~vertex ~fragment ~id =
  let program = GL.Program.create () in
  let vshader = GL.Shader.create GLTypes.ShaderType.Vertex   in
  let fshader = GL.Shader.create GLTypes.ShaderType.Fragment in
  if not (GL.Shader.valid vshader) ||
     not (GL.Shader.valid fshader) ||
     not (GL.Program.valid program) then begin
    last_log := "Context initialization failure";
    raise (Program_internal_error "Failed to create a GLSL program , the GL context may not be correctly initialized");
  end;
  GL.Shader.source vshader vertex;
  GL.Shader.source fshader fragment;
  GL.Shader.compile vshader;
  GL.Shader.compile fshader;
  if GL.Shader.status vshader = false then begin
    last_log := GL.Shader.log vshader;
    raise (Program_internal_error "GLSL compilation failure")
  end;
  if GL.Shader.status fshader = false then begin
    last_log := GL.Shader.log fshader;
    raise (Program_internal_error "GLSL compilation failure")
  end;
  GL.Program.attach program vshader;
  GL.Program.attach program fshader;
  GL.Program.link program;
  GL.Program.detach program vshader;
  GL.Program.detach program fshader;
  GL.Shader.delete vshader;
  GL.Shader.delete fshader;
  if GL.Program.status program = false then begin
    last_log := GL.Program.log program;
    raise (Program_internal_error "GLSL linking failure")
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
    id;
    uniforms = uniforms (GL.Program.ucount program);
    attributes = attributes (GL.Program.acount program);
  }

let create_list ~vertex ~fragment ~id ~version = 
  let list_vshader = 
    List.sort (fun (v,_) (v',_) -> - (compare v v')) vertex
  in
  let list_fshader = 
    List.sort (fun (v,_) (v',_) -> - (compare v v')) fragment
  in
  try 
    let best_vshader = 
      List.find (fun (v,_) -> v <= version) list_vshader
      |> snd
    in
    let best_fshader = 
      List.find (fun (v,_) -> v <= version) list_fshader
      |> snd
    in
    create ~vertex:best_vshader ~fragment:best_fshader ~id
  with Not_found -> 
    last_log := "No supported GLSL version provided";
    raise (Program_internal_error "No supported GLSL version provided")

let create_pp ~vertex ~fragment ~id ~version =
  let vsource = Printf.sprintf "#version %i\n\n%s" version vertex in
  let fsource = Printf.sprintf "#version %i\n\n%s" version fragment in
  create 
    ~id
    ~vertex:vsource
    ~fragment:fsource

module Sources = struct

  (** 2D drawing program *)
  let vertex_shader_source_130 = "
    uniform vec2 size;

    in vec3 position;
    in vec4 color;

    out vec4 frag_color;

    void main() {

      gl_Position.x = 2.0 * position.x / size.x - 1.0;
      gl_Position.y = 2.0 * (size.y - position.y) / size.y - 1.0;
      gl_Position.z = 0.0;
      gl_Position.w = 1.0;

      frag_color = color;

    }
  "

  let fragment_shader_source_130 = "
    in vec4 frag_color;

    out vec4 pixel_color;

    void main() {

      pixel_color = frag_color;

    }
  "

  let create_shape id version =
    create_pp ~version ~id ~vertex:vertex_shader_source_130
                           ~fragment:fragment_shader_source_130

  (* Sprite drawing program *)
  let vertex_shader_source_tex_130 = "
    uniform vec2 size;

    in vec3 position;
    in vec2 uv;

    out vec2 frag_uv;

    void main() {

      gl_Position.x = 2.0 * position.x / size.x - 1.0;
      gl_Position.y = 2.0 * (size.y - position.y) / size.y - 1.0;
      gl_Position.z = 0.0;
      gl_Position.w = 1.0;

      frag_uv = vec2(uv.x, 1.0 - uv.y);

    }
  "

  let fragment_shader_source_tex_130 = "
    uniform sampler2D utexture;

    in vec2 frag_uv;

    out vec4 out_color;

    void main() {

      out_color = texture(utexture, frag_uv);

    }
  "

  let create_sprite id version =
    create_pp ~version ~id ~vertex:vertex_shader_source_tex_130
                           ~fragment:fragment_shader_source_tex_130


  (* Text drawing program *)
  let vertex_shader_source_text_130 = "
    uniform vec2 window_size;
    uniform vec2 atlas_size;

    in vec3 position;
    in vec2 uv;
    in vec4 color;

    out vec2 frag_uv;
    out vec4 frag_color;

    void main() {

      gl_Position.x = 2.0 * position.x / window_size.x - 1.0;
      gl_Position.y = 2.0 * (window_size.y - position.y) / window_size.y - 1.0;
      gl_Position.z = 0.0;
      gl_Position.w = 1.0;

      frag_uv.x = uv.x / atlas_size.x;
      frag_uv.y = uv.y / atlas_size.y;

      frag_color = color;

    }
  "

  let fragment_shader_source_text_130 = "
    uniform sampler2DArray atlas;
    uniform int atlas_offset;

    in vec2 frag_uv;
    in vec4 frag_color;

    out vec4 color;

    void main() {

      color = texture(atlas, vec3(frag_uv.xy,atlas_offset)) * frag_color;

    }
  "

  let create_text id version =
    create_pp ~version ~id ~vertex:vertex_shader_source_text_130
                           ~fragment:fragment_shader_source_text_130

end
