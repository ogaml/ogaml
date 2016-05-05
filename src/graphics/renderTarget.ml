open OgamlMath

module type T = sig

  type t

  val size : t -> OgamlMath.Vector2i.t

  val state : t -> State.t

  val display : t -> unit

  val clear : ?color:Color.t -> ?depth:bool -> ?stencil:bool -> t -> unit

  val bind : t -> DrawParameter.t -> unit

end


let bind_fbo state id fbo = 
  if State.LL.bound_fbo state <> id then begin 
    State.LL.set_bound_fbo state id;
    GL.FBO.bind fbo;
  end

let clear ?color ~depth ~stencil state = 
  match color with
  | None -> GL.Pervasives.clear false depth stencil
  | Some color ->
    if (State.LL.clear_color state <> color) then begin
      let crgb = Color.rgb color in
      State.LL.set_clear_color state color;
      Color.RGB.(GL.Pervasives.color crgb.r crgb.g crgb.b crgb.a)
    end;
    GL.Pervasives.clear true depth stencil

let bind_culling_mode state parameters = 
  let cull_mode = DrawParameter.culling parameters in
  if State.LL.culling_mode state <> cull_mode then begin
    State.LL.set_culling_mode state cull_mode;
    GL.Pervasives.culling cull_mode
  end

let bind_polygon_mode state parameters = 
  let poly_mode = DrawParameter.polygon parameters in
  if State.LL.polygon_mode state <> poly_mode then begin
    State.LL.set_polygon_mode state poly_mode;
    GL.Pervasives.polygon poly_mode
  end

let bind_depth_testing state parameters =
  let depth_testing = DrawParameter.depth_test parameters in
  begin match depth_testing with 
    | DrawParameter.DepthTest.None when State.LL.depth_test state ->
      State.LL.set_depth_test state false;
      GL.Pervasives.depthtest false
    | DrawParameter.DepthTest.None -> ()
    | depthfun -> begin
      if State.LL.depth_test state = false then begin
        State.LL.set_depth_test state true;
        GL.Pervasives.depthtest true
      end;
      if State.LL.depth_function state <> depthfun then begin
        State.LL.set_depth_function state depthfun;
        GL.Pervasives.depthfunction depthfun
      end;
    end 
  end

let bind_antialiasing state level parameters = 
  let antialiasing = DrawParameter.antialiasing parameters in
  if level > 0
    && antialiasing
    && State.LL.msaa state = false
  then begin
    State.LL.set_msaa state true;
    GL.Pervasives.msaa true;
  end
  else if State.LL.msaa state = true
    && antialiasing = false
  then begin
    State.LL.set_msaa state false;
    GL.Pervasives.msaa false
  end

let bind_viewport state sizei parameters = 
  let viewport =
    DrawParameter.Viewport.(
      let open OgamlMath in
      let sizef = Vector2f.from_int sizei in
      match DrawParameter.viewport parameters with
      |Full ->
        IntRect.({x = 0; y = 0;
                  width  = sizei.Vector2i.x;
                  height = sizei.Vector2i.y})
      |Relative r ->
        FloatRect.(floor
          {x = sizef.Vector2f.x *. r.x;
          y = sizef.Vector2f.y *. r.y;
          width  = sizef.Vector2f.x *. r.width;
          height = sizef.Vector2f.y *. r.height})
      |Absolute r -> r
    )
  in
  if State.LL.viewport state <> viewport then begin
    let open OgamlMath.IntRect in
    State.LL.set_viewport state viewport;
    GL.Pervasives.viewport viewport.x viewport.y viewport.width viewport.height;
  end

let bind_blend_mode state parameters =
  let blend_mode = DrawParameter.blend_mode parameters in
  DrawParameter.BlendMode.(
    let blending = (blend_mode.alpha <> Equation.None) || (blend_mode.color <> Equation.None) in
    if State.LL.blending state <> blending then begin
      State.LL.set_blending state blending;
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
    let tag_alpha = Obj.tag (Obj.repr (State.LL.blend_equation state).alpha) in
    let tag_color = Obj.tag (Obj.repr (State.LL.blend_equation state).color) in
    let extract_sd = function
      |Equation.Add (s,d) -> (s,d)
      |Equation.Sub (s,d) -> (s,d)
      | _ -> assert false
    in
    if (extract_sd blend_alpha <> extract_sd (State.LL.blend_equation state).alpha)
    || (extract_sd blend_color <> extract_sd (State.LL.blend_equation state).color)
    then begin
      let (s_rgb, d_rgb), (s_alp, d_alp) = extract_sd blend_color, extract_sd blend_alpha in
      State.LL.set_blend_equation state {alpha = blend_alpha; color = blend_color};
      GL.Blending.blend_func_separate s_rgb d_rgb s_alp d_alp;
    end;
    if ((Obj.tag (Obj.repr blend_color)) <> tag_alpha)
    || ((Obj.tag (Obj.repr blend_alpha)) <> tag_color)
    then begin
      State.LL.set_blend_equation state {alpha = blend_alpha; color = blend_color};
      GL.Blending.blend_equation_separate blend_color blend_alpha
    end
  )

let bind_draw_parameters state size aa parameters =
  let state = state in
  bind_culling_mode state parameters;
  bind_polygon_mode state parameters;
  bind_depth_testing state parameters;
  bind_antialiasing state aa parameters;
  bind_viewport state size parameters;
  bind_blend_mode state parameters


