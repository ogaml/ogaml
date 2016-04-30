
exception Invalid_state of string

type t = {
  major : int;
  minor : int;
  glsl  : int;
  textures : int;
  mutable msaa : bool;
  mutable culling_mode  : DrawParameter.CullingMode.t;
  mutable polygon_mode  : DrawParameter.PolygonMode.t;
  mutable depth_test : bool;
  mutable depth_function : DrawParameter.DepthTest.t;
  mutable texture_id : int;
  mutable texture_unit  : int;
  mutable bound_texture : (int * GLTypes.TextureTarget.t) option array;
  mutable program_id    : int;
  mutable linked_program : int option;
  mutable bound_vbo : int option;
  mutable vao_id    : int;
  mutable bound_vao : int option;
  mutable ebo_id    : int;
  mutable bound_ebo : int option;
  mutable fbo_id    : int;
  mutable bound_fbo : int;
  mutable color    : Color.t;
  mutable blending : bool;
  mutable blend_equation : DrawParameter.BlendMode.t;
  mutable viewport : OgamlMath.IntRect.t
}

let error msg = raise (Invalid_state msg)

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

let max_textures s = 
  GL.Pervasives.max_textures ()

let assert_no_error s = 
  assert (GL.Pervasives.error () = None)


module LL = struct
  
  let create () =
    let convert v = 
      if v < 10 then v*10 else v
    in
    let major, minor = 
      let str = GL.Pervasives.gl_version () in
      Scanf.sscanf str "%i.%i" (fun a b -> (a, convert b))
    in
    let glsl = 
      let str = GL.Pervasives.glsl_version () in
      Scanf.sscanf str "%i.%i" (fun a b -> a * 100 + (convert b))
    in
    let textures = GL.Pervasives.max_textures () in
    {
      major   ;
      minor   ;
      glsl    ;
      textures;
      msaa = false;
      culling_mode = DrawParameter.CullingMode.CullNone;
      polygon_mode = DrawParameter.PolygonMode.DrawFill;
      depth_test = false;
      depth_function = DrawParameter.DepthTest.Less;
      texture_id   = 0;
      texture_unit = 0;
      bound_texture = Array.make textures None;
      program_id = 0;
      linked_program = None;
      bound_vbo = None;
      vao_id = 0;
      bound_vao = None;
      ebo_id = 0;
      bound_ebo = None;
      fbo_id = 1;
      bound_fbo = 0;
      color = `RGB (Color.RGB.transparent);
      blending = false;
      blend_equation = DrawParameter.BlendMode.(
        {color = Equation.Add (Factor.One, Factor.Zero);
         alpha = Equation.Add (Factor.One, Factor.Zero)});
      viewport = OgamlMath.IntRect.({x = 0; y = 0; width = 0; height = 0}) 
    }

  let culling_mode s =
    s.culling_mode

  let polygon_mode s =
    s.polygon_mode

  let depth_test s = 
    s.depth_test

  let depth_function s = 
    s.depth_function

  let clear_color s = 
    s.color

  let set_culling_mode s m =
    s.culling_mode <- m

  let set_polygon_mode s m =
    s.polygon_mode <- m

  let set_depth_test s v = 
    s.depth_test <- v

  let set_depth_function s f = 
    s.depth_function <- f

  let msaa s = s.msaa

  let set_msaa s b = s.msaa <- b

  let textures s = 
    s.textures

  let texture_unit s = 
    s.texture_unit

  let set_texture_unit s i = 
    s.texture_unit <- i

  let texture_id s = 
    s.texture_id <- s.texture_id + 1;
    s.texture_id - 1

  let bound_texture s i = 
    if i >= s.textures || i < 0 then
      Printf.ksprintf error "Invalid texture unit %i" i;
    match s.bound_texture.(i) with
    | None       -> None
    | Some (t,_) -> Some t

  let bound_target s i = 
    if i >= s.textures || i < 0 then
      Printf.ksprintf error "Invalid texture unit %i" i;
    match s.bound_texture.(i) with
    | None       -> None
    | Some (_,t) -> Some t

  let set_bound_texture s i t = 
    if i >= s.textures || i < 0 then
      Printf.ksprintf error "Invalid texture unit %i" i;
    s.bound_texture.(i) <- t

  let linked_program s = 
    s.linked_program

  let set_linked_program s p =
    s.linked_program <- p

  let program_id s = 
    s.program_id <- s.program_id + 1;
    s.program_id - 1

  let bound_vbo s = 
    s.bound_vbo

  let set_bound_vbo s v = 
    s.bound_vbo <- v

  let bound_vao s = 
    s.bound_vao

  let set_bound_vao s v = 
    s.bound_vao <- v

  let vao_id s = 
    s.vao_id <- s.vao_id + 1;
    s.vao_id - 1

  let bound_ebo s = 
    s.bound_ebo

  let set_bound_ebo s v = 
    s.bound_ebo <- v

  let ebo_id s = 
    s.ebo_id <- s.ebo_id + 1;
    s.ebo_id - 1

  let bound_fbo s = 
    s.bound_fbo

  let set_bound_fbo s i = 
    s.bound_fbo <- i

  let fbo_id s = 
    s.fbo_id <- s.fbo_id + 1;
    s.fbo_id - 1

  let set_clear_color s c = 
    s.color <- c

  let blending s = s.blending

  let set_blending s b = s.blending <- b

  let blend_equation s = s.blend_equation

  let set_blend_equation s eq = s.blend_equation <- eq

  let viewport s = s.viewport

  let set_viewport s v = s.viewport <- v

end
