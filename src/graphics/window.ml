open OgamlCore

type t = {
  state : State.t;
  internal : LL.Window.t;
  settings : ContextSettings.t;
  programs : ProgramLibrary.t
}

let create ?width:(width=800) ?height:(height=600) ?title:(title="") 
           ?settings:(settings=OgamlCore.ContextSettings.create ()) () =
  let internal = LL.Window.create ~width ~height ~title ~settings in
  let state = State.LL.create () in
  State.LL.set_viewport state OgamlMath.IntRect.({x = 0; y = 0; width; height});
  let programs = ProgramLibrary.create state in
  {
    state;
    internal;
    settings;
    programs;
  }

let set_title win title = LL.Window.set_title win.internal title

let close win = LL.Window.close win.internal

let rect win = LL.Window.rect win.internal

let destroy win = LL.Window.destroy win.internal

let resize win size = LL.Window.resize win.internal size

let toggle_fullscreen win = LL.Window.toggle_fullscreen win.internal

let is_open win = LL.Window.is_open win.internal

let has_focus win = LL.Window.has_focus win.internal

let size win = LL.Window.size win.internal

let poll_event win = LL.Window.poll_event win.internal

let display win = LL.Window.display win.internal

let clear ?color:(color=`RGB Color.RGB.black) win =
  if State.LL.clear_color win.state <> color then begin
    let crgb = Color.rgb color in
    State.LL.set_clear_color win.state color;
    Color.RGB.(GL.Pervasives.color crgb.r crgb.g crgb.b crgb.a)
  end;
  let depth = ContextSettings.depth_bits win.settings > 0 in
  let stencil = ContextSettings.stencil_bits win.settings > 0 in
  GL.Pervasives.clear true depth stencil

let show_cursor win b = LL.Window.show_cursor win.internal b

let state win = win.state


module LL = struct

  let internal win = win.internal

  let program win = ProgramLibrary.shape_drawing win.programs

  let sprite_program win = ProgramLibrary.sprite_drawing win.programs

  let text_program win = ProgramLibrary.atlas_drawing win.programs

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

  let bind_draw_parameters win parameters =
    let state = win.state in
    bind_culling_mode state parameters;
    bind_polygon_mode state parameters;
    bind_depth_testing state parameters;
    bind_antialiasing state (ContextSettings.aa_level win.settings) parameters;
    bind_viewport state (size win) parameters;
    bind_blend_mode state parameters

end
