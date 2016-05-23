open OgamlMath

type t = {
  fbo    : GL.FBO.t;
  state  : State.t;
  id     : int;
  mutable color   : bool;
  mutable depth   : bool;
  mutable stencil : bool;
  mutable size    : Vector2i.t;
  mutable color_attachments : Attachment.ColorAttachment.t option array;
  mutable depth_attachment  : Attachment.DepthAttachment.t option
}

let create (type a) (module T : RenderTarget.T with type t = a) (target : a) =
  let state = T.state target in
  let fbo = GL.FBO.create () in
  (* TODO : change to MAX_FRAMEBUFFER_SIZE *)
  let size = Vector2i.({x = 4096; y = 4096}) in
  let color_attachments = Array.make 8 None in
  let depth_attachment  = None in
  {fbo; state; size; id = State.LL.fbo_id state;
   color = false; depth = false; stencil = false;
   color_attachments; depth_attachment}

(* TODO *)
let max_color_attachments fbo = 8

let attach_color (type a) (module A : Attachment.ColorAttachable with type t = a)
                 fbo nb (attachment : a) =
  let size = A.size attachment in
  let attc = A.to_color_attachment attachment in
  fbo.size <- Vector2i.map2 fbo.size size min;
  fbo.color <- true;
  fbo.color_attachments.(nb) <- Some attc;
  RenderTarget.bind_fbo fbo.state fbo.id (Some fbo.fbo);
  match attc with
  | Attachment.ColorAttachment.Texture2D (tex, lvl) ->
    GL.FBO.texture2D (GLTypes.GlAttachement.Color nb) tex lvl

let attach_depth (type a) (module A : Attachment.DepthAttachable with type t = a)
                 fbo (attachment : a) =
  let size = A.size attachment in
  let attc = A.to_depth_attachment attachment in
  fbo.size  <- Vector2i.map2 fbo.size size min;
  fbo.depth <- true;
  fbo.depth_attachment <- Some attc;
  RenderTarget.bind_fbo fbo.state fbo.id (Some fbo.fbo);
  match attc with
  | Attachment.DepthAttachment.DepthRBO rbo -> 
    GL.FBO.renderbuffer GLTypes.GlAttachement.Depth rbo

(* TODO *)
let attach_stencil (type a) (module A : Attachment.StencilAttachable with type t = a)
                 fbo (attachment : a) =
  let size = A.size attachment in
  let attc = A.to_stencil_attachment attachment in
  fbo.size    <- Vector2i.map2 fbo.size size min;
  fbo.stencil <- true;
  RenderTarget.bind_fbo fbo.state fbo.id (Some fbo.fbo);
  ignore attc

(* TODO *)
let attach_depthstencil (type a) (module A : Attachment.DepthStencilAttachable with type t = a)
                 fbo (attachment : a) =
  let size = A.size attachment in
  let attc = A.to_depthstencil_attachment attachment in
  fbo.size    <- Vector2i.map2 fbo.size size min;
  fbo.depth   <- true;
  fbo.stencil <- true;
  RenderTarget.bind_fbo fbo.state fbo.id (Some fbo.fbo);
  ignore attc

let has_color fbo = fbo.color

let has_depth fbo = fbo.depth

let has_stencil fbo = fbo.stencil

let size fbo = fbo.size

let state fbo = fbo.state

let clear ?color:(color = Some (`RGB Color.RGB.black)) 
          ?depth:(depth = true) ?stencil:(stencil = true) fbo = 
  RenderTarget.bind_fbo fbo.state fbo.id (Some fbo.fbo);
  if fbo.color then 
    RenderTarget.clear 
      ?color
      ~depth:(depth && fbo.depth) 
      ~stencil:(stencil && fbo.stencil)
      fbo.state
  else
    RenderTarget.clear
      ~depth:(depth && fbo.depth)
      ~stencil:(stencil && fbo.stencil)
      fbo.state

let bind fbo params = 
  RenderTarget.bind_fbo fbo.state fbo.id (Some fbo.fbo);
  RenderTarget.bind_draw_parameters fbo.state fbo.size 0 params


