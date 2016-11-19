open OgamlMath

exception FBO_Error of string

type t = {
  fbo    : GL.FBO.t;
  context  : Context.t;
  id     : int;
  mutable color   : bool;
  mutable depth   : bool;
  mutable stencil : bool;
  mutable color_attachments : (Vector2i.t * Attachment.ColorAttachment.t) option array;
  mutable depth_attachment  : (Vector2i.t * Attachment.DepthAttachment.t) option;
  mutable stencil_attachment  : (Vector2i.t * Attachment.StencilAttachment.t) option;
  mutable depth_stencil_attachment  : (Vector2i.t * Attachment.DepthStencilAttachment.t) option
}

let create (type a) (module T : RenderTarget.T with type t = a) (target : a) =
  let context = T.context target in
  let fbo = GL.FBO.create () in
  let maxattc = (Context.capabilities context).Context.max_color_attachments in
  let color_attachments = Array.make maxattc None in
  {fbo; context; id = Context.LL.fbo_id context;
   color = false; depth = false; stencil = false;
   color_attachments; 
   depth_attachment = None;
   stencil_attachment = None; 
   depth_stencil_attachment = None}

let attach_color (type a) (module A : Attachment.ColorAttachable with type t = a)
                 fbo nb (attachment : a) =
  let size = A.size attachment in
  let attc = A.to_color_attachment attachment in
  let capabilities = Context.capabilities fbo.context in
  if nb >= capabilities.Context.max_color_attachments then
    raise (FBO_Error "Color attachment limit exceeded");
  let max_width = 
    capabilities.Context.max_texture_size
  in
  let max_height = 
    capabilities.Context.max_texture_size
  in
  if size.Vector2i.x >= max_width || size.Vector2i.y >= max_height then
    raise (FBO_Error "Max attachment size exceeded");
  fbo.color <- true;
  fbo.color_attachments.(nb) <- Some (size, attc);
  RenderTarget.bind_fbo fbo.context fbo.id (Some fbo.fbo);
  match attc with
  | Attachment.ColorAttachment.Texture2D (tex, lvl) ->
    GL.FBO.texture2D (GLTypes.GlAttachment.Color nb) tex lvl
  | Attachment.ColorAttachment.Texture2DArray (tex, layer, lvl) ->
    GL.FBO.texture_layer (GLTypes.GlAttachment.Color nb) tex layer lvl 
  | Attachment.ColorAttachment.TextureCubemap (tex, face, lvl) ->
    GL.FBO.texture_layer (GLTypes.GlAttachment.Color nb) tex face lvl 
  | Attachment.ColorAttachment.ColorRBO rbo ->
    GL.FBO.renderbuffer (GLTypes.GlAttachment.Color nb) rbo

let attach_depth (type a) (module A : Attachment.DepthAttachable with type t = a)
                 fbo (attachment : a) =
  let size = A.size attachment in
  let attc = A.to_depth_attachment attachment in
  let capabilities = Context.capabilities fbo.context in
  let max_width = 
    capabilities.Context.max_texture_size
  in
  let max_height = 
    capabilities.Context.max_texture_size
  in
  if size.Vector2i.x >= max_width || size.Vector2i.y >= max_height then
    raise (FBO_Error "Max attachment size exceeded");
  fbo.depth <- true;
  fbo.depth_attachment <- Some (size, attc);
  if fbo.stencil_attachment <> None then
    fbo.depth_stencil_attachment <- None;
  RenderTarget.bind_fbo fbo.context fbo.id (Some fbo.fbo);
  match attc with
  | Attachment.DepthAttachment.DepthRBO rbo -> 
    GL.FBO.renderbuffer GLTypes.GlAttachment.Depth rbo

let attach_stencil (type a) (module A : Attachment.StencilAttachable with type t = a)
                 fbo (attachment : a) =
  let size = A.size attachment in
  let attc = A.to_stencil_attachment attachment in
  let capabilities = Context.capabilities fbo.context in
  let max_width = 
    capabilities.Context.max_texture_size
  in
  let max_height = 
    capabilities.Context.max_texture_size
  in
  if size.Vector2i.x >= max_width || size.Vector2i.y >= max_height then
    raise (FBO_Error "Max attachment size exceeded");
  fbo.stencil <- true;
  fbo.stencil_attachment <- Some (size, attc);
  if fbo.depth_attachment <> None then
    fbo.depth_stencil_attachment <- None;
  RenderTarget.bind_fbo fbo.context fbo.id (Some fbo.fbo);
  match attc with
  | Attachment.StencilAttachment.StencilRBO rbo -> 
    GL.FBO.renderbuffer GLTypes.GlAttachment.Stencil rbo

let attach_depthstencil (type a) (module A : Attachment.DepthStencilAttachable with type t = a)
                 fbo (attachment : a) =
  let size = A.size attachment in
  let attc = A.to_depthstencil_attachment attachment in
  let capabilities = Context.capabilities fbo.context in
  let max_width = 
    capabilities.Context.max_texture_size
  in
  let max_height = 
    capabilities.Context.max_texture_size
  in
  if size.Vector2i.x >= max_width || size.Vector2i.y >= max_height then
    raise (FBO_Error "Max attachment size exceeded");
  fbo.stencil <- true;
  fbo.depth <- true;
  fbo.depth_stencil_attachment <- Some (size, attc);
  fbo.depth_attachment <- None;
  fbo.stencil_attachment <- None;
  RenderTarget.bind_fbo fbo.context fbo.id (Some fbo.fbo);
  match attc with
  | Attachment.DepthStencilAttachment.DepthStencilRBO rbo -> 
    GL.FBO.renderbuffer GLTypes.GlAttachment.DepthStencil rbo

let has_color fbo = fbo.color

let has_depth fbo = fbo.depth

let has_stencil fbo = fbo.stencil

let size fbo = 
  let capabilities = Context.capabilities fbo.context in
  let max_width = 
    capabilities.Context.max_texture_size
  in
  let max_height = 
    capabilities.Context.max_texture_size
  in
  let msize = ref Vector2i.({x = max_width; y = max_height}) in
  for i = 0 to Array.length fbo.color_attachments - 1 do
    match fbo.color_attachments.(i) with
    | None -> ()
    | Some (s,_) -> msize := Vector2i.map2 !msize s min
  done;
  begin match fbo.depth_attachment with
  | None -> ()
  | Some (s,_) -> msize := Vector2i.map2 !msize s min
  end;
  begin match fbo.stencil_attachment with
  | None -> ()
  | Some (s,_) -> msize := Vector2i.map2 !msize s min
  end;
  begin match fbo.depth_stencil_attachment with
  | None -> ()
  | Some (s,_) -> msize := Vector2i.map2 !msize s min
  end;
  !msize

let context fbo = fbo.context

let clear ?color:(color = Some (`RGB Color.RGB.black)) 
          ?depth:(depth = true) ?stencil:(stencil = true) fbo = 
  RenderTarget.bind_fbo fbo.context fbo.id (Some fbo.fbo);
  if fbo.color then 
    RenderTarget.clear 
      ?color
      ~depth:(depth && fbo.depth) 
      ~stencil:(stencil && fbo.stencil)
      fbo.context
  else
    RenderTarget.clear
      ~depth:(depth && fbo.depth)
      ~stencil:(stencil && fbo.stencil)
      fbo.context

let bind fbo params = 
  RenderTarget.bind_fbo fbo.context fbo.id (Some fbo.fbo);
  RenderTarget.bind_draw_parameters fbo.context (size fbo) 0 params


