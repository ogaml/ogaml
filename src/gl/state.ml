
exception Invalid_texture_unit of int

type t = {
  major : int;
  minor : int;
  glsl  : int;
  textures : int;
  mutable culling_mode  : Enum.CullingMode.t;
  mutable polygon_mode  : Enum.PolygonMode.t;
  mutable texture_unit  : int;
  mutable bound_texture : (Internal.Texture.t option) array array;
  mutable linked_program : Internal.Program.t option;
  mutable bound_vbo : Internal.VBO.t option;
  mutable bound_vao : Internal.VAO.t option;
}

external ext_gl_version : unit -> string = "caml_gl_version"

external ext_glsl_version : unit -> string = "caml_glsl_version"

external ext_max_textures : unit -> int = "caml_max_textures"

let create () =
  let convert v = 
    if v < 10 then v*10 else v
  in
  let major, minor = 
    let str = ext_gl_version () in
    Scanf.sscanf str "%i.%i" (fun a b -> (a, convert b))
  in
  let glsl = 
    let str = ext_glsl_version () in
    Scanf.sscanf str "%i.%i" (fun a b -> a * 100 + (convert b))
  in
  let textures = ext_max_textures () in
  {
    major   ;
    minor   ;
    glsl    ;
    textures;
    culling_mode = Enum.CullingMode.CullNone;
    polygon_mode = Enum.PolygonMode.DrawFill;
    texture_unit = 0;
    bound_texture = Array.make_matrix textures 3 None;
    linked_program = None;
    bound_vbo = None;
    bound_vao = None
  }

let version s = 
  (s.major, s.minor)

let is_version_supported s (maj, min) = 
  let convert v = 
    if v < 10 then v*10 else v
  in
  maj < s.major || (maj = s.major && (convert min) <= s.minor)

let glsl_version s = 
  s.glsl

let is_glsl_version_supported s v = 
  v <= s.glsl

let culling_mode s =
  s.culling_mode

let set_culling_mode s m =
  s.culling_mode <- m

let polygon_mode s =
  s.polygon_mode

let set_polygon_mode s m =
  s.polygon_mode <- m

let textures s = 
  s.textures

let texture_unit s = 
  s.texture_unit

let set_texture_unit s i = 
  s.texture_unit <- i

let bound_texture s i targ = 
  if i >= s.textures then
    raise (Invalid_texture_unit i);
  s.bound_texture.(i).(Obj.magic targ)

let set_bound_texture s i targ t = 
  if i >= s.textures then
    raise (Invalid_texture_unit i);
  s.bound_texture.(i).(Obj.magic targ) <- t

let linked_program s = 
  s.linked_program

let set_linked_program s p =
  s.linked_program <- p

let bound_vbo s = 
  s.bound_vbo

let set_bound_vbo s v = 
  s.bound_vbo <- v

let bound_vao s = 
  s.bound_vao

let set_bound_vao s v = 
  s.bound_vao <- v
