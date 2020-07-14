open OgamlMath

module type T = sig

  module OutputBuffer : sig

    type t

  end

  type t

  val size : t -> OgamlMath.Vector2i.t

  val context : t -> Context.t

  val clear : ?buffers:OutputBuffer.t list -> ?color:Color.t option -> 
    ?depth:bool -> ?stencil:bool -> t -> 
    (unit, [> `Too_many_draw_buffers | `Duplicate_draw_buffer | `Invalid_color_buffer]) result

  val bind : t -> ?buffers:OutputBuffer.t list -> DrawParameter.t -> 
    (unit, [> `Too_many_draw_buffers | `Duplicate_draw_buffer | `Invalid_color_buffer]) result

end


let bind_fbo context id fbo = 
  if Context.LL.bound_fbo context <> id then begin 
    (match fbo with
     | None   -> Context.LL.set_bound_fbo context None
     | Some f -> Context.LL.set_bound_fbo context (Some (f,id))
    );
    GL.FBO.bind fbo;
  end

let clear ?color ~depth ~stencil context = 
  if depth && not (Context.LL.depth_writing context) then begin
    Context.LL.set_depth_writing context true;
    GL.Pervasives.depth_mask true;
  end;
  match color with
  | None -> GL.Pervasives.clear false depth stencil
  | Some color ->
    if (Context.LL.clear_color context <> color) then begin
      let crgb = Color.to_rgb color in
      Context.LL.set_clear_color context color;
      Color.RGB.(GL.Pervasives.color crgb.r crgb.g crgb.b crgb.a)
    end;
    GL.Pervasives.clear true depth stencil

let bind_culling_mode context parameters = 
  let cull_mode = DrawParameter.culling parameters in
  if Context.LL.culling_mode context <> cull_mode then begin
    Context.LL.set_culling_mode context cull_mode;
    GL.Pervasives.culling cull_mode
  end

let bind_polygon_mode context parameters = 
  let poly_mode = DrawParameter.polygon parameters in
  if Context.LL.polygon_mode context <> poly_mode then begin
    Context.LL.set_polygon_mode context poly_mode;
    GL.Pervasives.polygon poly_mode
  end

let bind_depth_testing context parameters =
  let depth_testing = DrawParameter.depth_test parameters in
  begin match depth_testing with 
    | DrawParameter.DepthTest.None when Context.LL.depth_test context ->
      Context.LL.set_depth_test context false;
      GL.Pervasives.depthtest false
    | DrawParameter.DepthTest.None -> ()
    | depthfun -> begin
      if Context.LL.depth_test context = false then begin
        Context.LL.set_depth_test context true;
        GL.Pervasives.depthtest true
      end;
      if Context.LL.depth_function context <> depthfun then begin
        Context.LL.set_depth_function context depthfun;
        GL.Pervasives.depthfunction depthfun
      end;
    end 
  end

let bind_depth_writing context parameters =
  let depth_writing = DrawParameter.depth_write parameters in
  if Context.LL.depth_writing context <> depth_writing then begin
    Context.LL.set_depth_writing context depth_writing;
    GL.Pervasives.depth_mask depth_writing;
  end

let bind_antialiasing context level parameters = 
  let antialiasing = DrawParameter.antialiasing parameters in
  if level > 0
    && antialiasing
    && Context.LL.msaa context = false
  then begin
    Context.LL.set_msaa context true;
    GL.Pervasives.msaa true;
  end
  else if Context.LL.msaa context = true
    && antialiasing = false
  then begin
    Context.LL.set_msaa context false;
    GL.Pervasives.msaa false
  end

let bind_viewport context sizei parameters = 
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
        FloatRect.(to_int
          {x = sizef.Vector2f.x *. r.x;
          y = sizef.Vector2f.y *. r.y;
          width  = sizef.Vector2f.x *. r.width;
          height = sizef.Vector2f.y *. r.height})
      |Absolute r -> r
    )
  in
  if Context.LL.viewport context <> viewport then begin
    let open OgamlMath.IntRect in
    Context.LL.set_viewport context viewport;
    GL.Pervasives.viewport viewport.x viewport.y viewport.width viewport.height;
  end

let bind_blend_mode context parameters =
  let blend_mode = DrawParameter.blend_mode parameters in
  DrawParameter.BlendMode.(
    let blending = (blend_mode.alpha <> Equation.None) || (blend_mode.color <> Equation.None) in
    if Context.LL.blending context <> blending then begin
      Context.LL.set_blending context blending;
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
    let tag_alpha = Obj.tag (Obj.repr (Context.LL.blend_equation context).alpha) in
    let tag_color = Obj.tag (Obj.repr (Context.LL.blend_equation context).color) in
    let extract_sd = function
      |Equation.Add (s,d) -> (s,d)
      |Equation.Sub (s,d) -> (s,d)
      | _ -> assert false
    in
    if (extract_sd blend_alpha <> extract_sd (Context.LL.blend_equation context).alpha)
    || (extract_sd blend_color <> extract_sd (Context.LL.blend_equation context).color)
    then begin
      let (s_rgb, d_rgb), (s_alp, d_alp) = extract_sd blend_color, extract_sd blend_alpha in
      Context.LL.set_blend_equation context {alpha = blend_alpha; color = blend_color};
      GL.Blending.blend_func_separate s_rgb d_rgb s_alp d_alp;
    end;
    if ((Obj.tag (Obj.repr blend_color)) <> tag_alpha)
    || ((Obj.tag (Obj.repr blend_alpha)) <> tag_color)
    then begin
      Context.LL.set_blend_equation context {alpha = blend_alpha; color = blend_color};
      GL.Blending.blend_equation_separate blend_color blend_alpha
    end
  )

let begin_queries parameters =
  Option.iter DrawParameter.Query.LL.begin_ (DrawParameter.samples_query parameters);
  Option.iter DrawParameter.Query.LL.begin_ (DrawParameter.any_samples_query parameters);
  Option.iter DrawParameter.Query.LL.begin_ (DrawParameter.primitives_query parameters);
  Option.iter DrawParameter.Query.LL.begin_ (DrawParameter.time_query parameters)

let end_queries parameters =
  Option.iter DrawParameter.Query.LL.end_ (DrawParameter.samples_query parameters);
  Option.iter DrawParameter.Query.LL.end_ (DrawParameter.any_samples_query parameters);
  Option.iter DrawParameter.Query.LL.end_ (DrawParameter.primitives_query parameters);
  Option.iter DrawParameter.Query.LL.end_ (DrawParameter.time_query parameters)

let bind_draw_parameters context size aa parameters =
  let context = context in
  bind_culling_mode context parameters;
  bind_polygon_mode context parameters;
  bind_depth_testing context parameters;
  bind_depth_writing context parameters;
  bind_antialiasing context aa parameters;
  bind_viewport context size parameters;
  bind_blend_mode context parameters
