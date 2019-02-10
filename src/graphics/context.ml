open OgamlUtils
open Result.Operators

type capabilities = {
  max_3D_texture_size       : int;
  max_array_texture_layers  : int;
  max_color_texture_samples : int;
  max_cube_map_texture_size : int;
  max_depth_texture_samples : int;
  max_elements_indices      : int;
  max_elements_vertices     : int;
  max_integer_samples       : int;
  max_renderbuffer_size     : int;
  max_texture_buffer_size   : int;
  max_texture_image_units   : int;
  max_texture_size          : int;
  max_color_attachments     : int;
  max_draw_buffers          : int;
}

module ID_Pool = struct

  type t = {  
    mutable next_id  : int;
    mutable free_ids : int list
  }

  let create next_id = {
    next_id;
    free_ids = []
  }

  let get_next t = 
    match t.free_ids with
    | [] -> 
      t.next_id <- t.next_id + 1;
      t.next_id - 1
    | h::tail ->
      t.free_ids <- tail;
      h

  let free t i = 
    t.free_ids <- i :: t.free_ids

end

type t = {
  capabilities : capabilities;
  major : int;
  minor : int;
  glsl  : int;
  sprite_program : ProgramInternal.t;
  shape_program  : ProgramInternal.t;
  text_program   : ProgramInternal.t;
  mutable msaa   : bool;
  mutable culling_mode     : DrawParameter.CullingMode.t;
  mutable polygon_mode     : DrawParameter.PolygonMode.t;
  mutable depth_test       : bool;
  mutable depth_writing    : bool;
  mutable depth_function   : DrawParameter.DepthTest.t;
  mutable texture_pool     : ID_Pool.t;
  mutable texture_unit     : int;
  mutable pooled_tex_array : bool array;
  mutable bound_texture    : (GL.Texture.t * int * GLTypes.TextureTarget.t) option array;
  mutable program_pool     : ID_Pool.t;
  mutable linked_program   : (GL.Program.t * int) option;
  mutable vbo_pool         : ID_Pool.t;
  mutable bound_vbo        : (GL.VBO.t * int) option;
  mutable vao_pool         : ID_Pool.t;
  mutable bound_vao        : (GL.VAO.t * int) option;
  mutable ebo_pool         : ID_Pool.t;
  mutable bound_ebo        : (GL.EBO.t * int) option;
  mutable fbo_pool         : ID_Pool.t;
  mutable rbo_pool         : ID_Pool.t;
  mutable bound_fbo        : (GL.FBO.t * int) option;
  mutable color            : Color.t;
  mutable blending         : bool;
  mutable blend_equation   : DrawParameter.BlendMode.t;
  mutable viewport         : OgamlMath.IntRect.t
}

let capabilities t = t.capabilities

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

let check_errors s = 
  match GL.Pervasives.error () with
  | Some GLTypes.GlError.Invalid_enum    -> Error `Invalid_enum
  | Some GLTypes.GlError.Invalid_value   -> Error `Invalid_value
  | Some GLTypes.GlError.Invalid_op      -> Error `Invalid_op
  | Some GLTypes.GlError.Invalid_fbop    -> Error `Invalid_fbop
  | Some GLTypes.GlError.Out_of_memory   -> Error `Out_of_memory
  | Some GLTypes.GlError.Stack_overflow  -> Error `Stack_overflow
  | Some GLTypes.GlError.Stack_underflow -> Error `Stack_underflow
  | None -> Ok ()

let flush s = 
  GL.Pervasives.flush ()

let finish s = 
  GL.Pervasives.finish ()

module LL = struct
  
  let mk_init_error fmt = 
    Printf.ksprintf (fun s -> Error (`Context_initialization_error s)) fmt

  let handle_program_error = function
    | Ok prog -> Ok prog
    | Error `Context_failure ->
      mk_init_error "GLSL not supported"
    | Error `Fragment_compilation_error (log) ->
      mk_init_error "Failed to compile internal fragment shader: %s" log
    | Error `Vertex_compilation_error (log) ->
      mk_init_error "Failed to compile internal vertex shader: %s" log
    | Error `Linking_failure ->
      mk_init_error "Failed to link internal shader"
    | Error `Unsupported_GLSL_type ->
      mk_init_error "Unsupported GLSL features in internal shader"
  
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
    assert (GL.Pervasives.error () = None);
    let capabilities = {
      max_3D_texture_size       = GL.Pervasives.get_integerv GLTypes.Parameter.Max3DTextureSize      ;
      max_array_texture_layers  = GL.Pervasives.get_integerv GLTypes.Parameter.MaxArrayTextureLayers ;
      max_color_texture_samples = GL.Pervasives.get_integerv GLTypes.Parameter.MaxColorTextureSamples;
      max_cube_map_texture_size = GL.Pervasives.get_integerv GLTypes.Parameter.MaxCubeMapTextureSize ;
      max_depth_texture_samples = GL.Pervasives.get_integerv GLTypes.Parameter.MaxDepthTextureSamples;
      max_elements_indices      = GL.Pervasives.get_integerv GLTypes.Parameter.MaxElementsIndices    ;
      max_elements_vertices     = GL.Pervasives.get_integerv GLTypes.Parameter.MaxElementsVertices   ;
      max_integer_samples       = GL.Pervasives.get_integerv GLTypes.Parameter.MaxIntegerSamples     ;
      max_renderbuffer_size     = GL.Pervasives.get_integerv GLTypes.Parameter.MaxRenderbufferSize   ;
      max_texture_buffer_size   = GL.Pervasives.get_integerv GLTypes.Parameter.MaxTextureBufferSize  ;
      max_texture_image_units   = GL.Pervasives.get_integerv GLTypes.Parameter.MaxTextureImageUnits  ;
      max_texture_size          = GL.Pervasives.get_integerv GLTypes.Parameter.MaxTextureSize        ;
      max_color_attachments     = GL.Pervasives.get_integerv GLTypes.Parameter.MaxColorAttachments   ;
      max_draw_buffers          = GL.Pervasives.get_integerv GLTypes.Parameter.MaxDrawBuffers        ;
    }
    in
    (* A bit ugly, but Invalid_enum occurs sometimes even if a feature is supported... *)
    ignore (GL.Pervasives.error ());
    ProgramInternal.Sources.create_sprite (-3) glsl |> handle_program_error >>= 
    fun sprite_program ->
    ProgramInternal.Sources.create_shape (-2) glsl |> handle_program_error >>= 
    fun shape_program ->
    ProgramInternal.Sources.create_text (-1) glsl |> handle_program_error >>>= 
    fun text_program ->
    {
      capabilities;
      major   ;
      minor   ;
      glsl    ;
      sprite_program;
      shape_program ;
      text_program  ;
      msaa             = false;
      culling_mode     = DrawParameter.CullingMode.CullNone;
      polygon_mode     = DrawParameter.PolygonMode.DrawFill;
      depth_test       = false;
      depth_writing    = true;
      depth_function   = DrawParameter.DepthTest.Less;
      texture_pool     = ID_Pool.create 0;
      texture_unit     = 0;
      pooled_tex_array = Array.make capabilities.max_texture_image_units true;
      bound_texture    = Array.make capabilities.max_texture_image_units None;
      program_pool     = ID_Pool.create 0;
      linked_program   = None;
      vbo_pool         = ID_Pool.create 0;
      bound_vbo        = None;
      vao_pool         = ID_Pool.create 0;
      bound_vao        = None;
      ebo_pool         = ID_Pool.create 0;
      bound_ebo        = None;
      fbo_pool         = ID_Pool.create 1; (* ID 0 corresponds to the default framebuffer *)
      bound_fbo        = None;
      rbo_pool         = ID_Pool.create 0;
      color            = `RGB (Color.RGB.transparent);
      blending         = false;
      blend_equation   = DrawParameter.BlendMode.(
        {color = Equation.Add (Factor.One, Factor.Zero);
         alpha = Equation.Add (Factor.One, Factor.Zero)});
      viewport = OgamlMath.IntRect.({x = 0; y = 0; width = 0; height = 0}) 
    }

  let sprite_drawing s = s.sprite_program

  let shape_drawing s = s.shape_program

  let text_drawing s = s.text_program

  let culling_mode s =
    s.culling_mode

  let polygon_mode s =
    s.polygon_mode

  let depth_test s = 
    s.depth_test

  let depth_writing s = 
    s.depth_writing

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

  let set_depth_writing s v = 
    s.depth_writing <- v

  let set_depth_function s f = 
    s.depth_function <- f

  let msaa s = s.msaa

  let set_msaa s b = s.msaa <- b

  let texture_unit s = 
    s.texture_unit

  let set_texture_unit s i = 
    s.texture_unit <- i

  let texture_pool s = 
    s.texture_pool

  let bound_texture s i = 
    match s.bound_texture.(i) with
    | None       -> None
    | Some (_,t,_) -> Some t

  let bound_target s i = 
    match s.bound_texture.(i) with
    | None       -> None
    | Some (_,_,t) -> Some t

  let set_bound_texture s i t = 
    s.bound_texture.(i) <- t

  let pooled_texture_array s = 
    s.pooled_tex_array

  let linked_program s = 
    match s.linked_program with
    | None -> None
    | Some (_,t) -> Some t

  let set_linked_program s p =
    s.linked_program <- p

  let program_pool s = 
    s.program_pool

  let bound_vbo s = 
    match s.bound_vbo with
    | None -> None
    | Some (_,t) -> Some t

  let set_bound_vbo s v = 
    s.bound_vbo <- v

  let vbo_pool s = 
    s.vbo_pool

  let bound_vao s = 
    match s.bound_vao with
    | None -> None
    | Some (_,t) -> Some t

  let set_bound_vao s v = 
    s.bound_vao <- v

  let vao_pool s = 
    s.vao_pool

  let bound_ebo s = 
    match s.bound_ebo with
    | None -> None
    | Some (_,t) -> Some t

  let set_bound_ebo s v = 
    s.bound_ebo <- v

  let ebo_pool s = 
    s.ebo_pool

  let bound_fbo s = 
    match s.bound_fbo with
    | None -> 0
    | Some (_,t) -> t

  let set_bound_fbo s i = 
    s.bound_fbo <- i

  let fbo_pool s = 
    s.fbo_pool

  let rbo_pool s = 
    s.rbo_pool

  let set_clear_color s c = 
    s.color <- c

  let blending s = s.blending

  let set_blending s b = s.blending <- b

  let blend_equation s = s.blend_equation

  let set_blend_equation s eq = s.blend_equation <- eq

  let viewport s = s.viewport

  let set_viewport s v = s.viewport <- v

end
