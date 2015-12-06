
exception Invalid_texture_unit of int

type t = {
  major : int;
  minor : int;
  glsl  : int;
  textures : int;
  mutable msaa : bool;
  mutable culling_mode  : DrawParameter.CullingMode.t;
  mutable polygon_mode  : DrawParameter.PolygonMode.t;
  mutable depth_test    : bool;
  mutable texture_unit  : int;
  mutable bound_texture : (GL.Texture.t option) array array;
  mutable linked_program : GL.Program.t option;
  mutable bound_vbo : GL.VBO.t option;
  mutable bound_vao : GL.VAO.t option;
  mutable bound_ebo : GL.EBO.t option;
  mutable color : Color.t;
  mutable blending : bool;
  mutable blend_equation : DrawParameter.BlendMode.t
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

let polygon_mode s =
  s.polygon_mode


let depth_test s = 
  s.depth_test

let clear_color s = 
  s.color

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
      depth_test   = false;
      texture_unit = 0;
      bound_texture = Array.make_matrix textures 3 None;
      linked_program = None;
      bound_vbo = None;
      bound_vao = None;
      bound_ebo = None;
      color = `RGB (Color.RGB.transparent);
      blending = false;
      blend_equation = DrawParameter.BlendMode.(
        {color = Equation.Add (Factor.One, Factor.Zero);
         alpha = Equation.Add (Factor.One, Factor.Zero)})
    }

  let set_culling_mode s m =
    s.culling_mode <- m

  let set_polygon_mode s m =
    s.polygon_mode <- m

  let set_depth_test s v = 
    s.depth_test <- v

  let msaa s = s.msaa

  let set_msaa s b = s.msaa <- b

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

  let bound_ebo s = 
    s.bound_ebo

  let set_bound_ebo s v = 
    s.bound_ebo <- v

  let set_clear_color s c = 
    s.color <- c

  let blending s = s.blending

  let set_blending s b = s.blending <- b

  let blend_equation s = s.blend_equation

  let set_blend_equation s eq = s.blend_equation <- eq


  let bind_draw_parameters state parameters = 
    let cull_mode = DrawParameter.culling parameters in
    if state.culling_mode <> cull_mode then begin
      set_culling_mode state cull_mode;
      GL.Pervasives.culling cull_mode
    end;
    let poly_mode = DrawParameter.polygon parameters in
    if state.polygon_mode <> poly_mode then begin
      set_polygon_mode state poly_mode;
      GL.Pervasives.polygon poly_mode
    end;
    let depth_testing = DrawParameter.depth_test parameters in
    if state.depth_test <> depth_testing then begin
      set_depth_test state depth_testing;
      GL.Pervasives.depthtest depth_testing
    end;
    let blend_mode = DrawParameter.blend_mode parameters in
    DrawParameter.BlendMode.(
      let blending = (blend_mode.alpha <> Equation.None) || (blend_mode.color <> Equation.None) in
      if state.blending <> blending then begin
        set_blending state blending;
        GL.Blending.enable blending
      end;
      let blend_alpha = 
        match blend_mode.alpha with
        |Equation.None -> Equation.Add (Factor.One, Factor.Zero)
        | eq -> eq
      in
      let blend_color = 
        match blend_mode.color with
        |Equation.None -> Equation.Add (Factor.One, Factor.Zero)
        | eq -> eq
      in
      let tag_alpha = Obj.tag (Obj.repr state.blend_equation.alpha) in
      let tag_color = Obj.tag (Obj.repr state.blend_equation.color) in
      let extract_sd = function
        |Equation.Add (s,d) -> (s,d)
        |Equation.Sub (s,d) -> (s,d)
        | _ -> assert false
      in
      if (extract_sd blend_alpha <> extract_sd state.blend_equation.alpha)
      || (extract_sd blend_color <> extract_sd state.blend_equation.color)
      then begin
        let (s_rgb, d_rgb), (s_alp, d_alp) = extract_sd blend_color, extract_sd blend_alpha in
        set_blend_equation state {alpha = blend_alpha; color = blend_color};
        GL.Blending.blend_func_separate s_rgb d_rgb s_alp d_alp;
      end;
      if ((Obj.tag (Obj.repr blend_color)) <> tag_alpha)
      || ((Obj.tag (Obj.repr blend_alpha)) <> tag_color)
      then begin
        set_blend_equation state {alpha = blend_alpha; color = blend_color};
        GL.Blending.blend_equation_separate blend_color blend_alpha
      end
    )

end
