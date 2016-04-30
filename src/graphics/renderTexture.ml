open OgamlMath

type t = {
  state    : State.t;
  programs : ProgramLibrary.t;
  size     : Vector2i.t;
  texture  : Texture.Texture2D.t;
  rbo      : GL.RBO.t;
  fbo      : GL.FBO.t;
  id       : int
}
  
let create state size = 
  let texture =
    Texture.Texture2D.create state 
      (`Image (Image.create (`Empty (size, `RGB Color.RGB.black))))
  in
  let fbo = GL.FBO.create () in
  let rbo = GL.RBO.create () in
  GL.FBO.bind (Some fbo);
  GL.FBO.texture2D GLTypes.GlAttachement.Color (Texture.Texture2D.LL.internal texture);
  GL.RBO.bind (Some rbo);
  GL.RBO.storage GLTypes.TextureFormat.Depth size.Vector2i.x size.Vector2i.y;
  GL.FBO.render GLTypes.GlAttachement.Depth rbo;
  GL.FBO.bind None;
  GL.RBO.bind None;
  {
    state;
    programs = ProgramLibrary.create state;
    size;
    texture = Texture.Texture2D.create state 
                (`Image (Image.create (`Empty (size, `RGB Color.RGB.black))));
    rbo;
    fbo;
    id = State.LL.fbo_id state
  }

let texture t = 
  t.texture

let size t = 
  t.size

let display t = 
  RenderFunctions.bind_fbo t.state t.id (Some t.fbo);
  GL.Pervasives.flush ()

let clear ?color:(color=`RGB Color.RGB.black) buf =
  RenderFunctions.bind_fbo buf.state buf.id (Some buf.fbo);
  RenderFunctions.clear ~color ~depth:true ~stencil:false buf.state


module LL = struct

  let program t = t.programs

  let bind_draw_parameters t params = 
    RenderFunctions.bind_fbo t.state t.id (Some t.fbo);
    RenderFunctions.bind_draw_parameters 
      t.state t.size 0 params

end
