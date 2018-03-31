open OgamlMath
open OgamlUtils
open OgamlUtils.Result

module ColorBuffer = struct

  type t = {
    id : int;
    internal : GL.RBO.t;
    size : Vector2i.t
  }

  let create (type a) (module M : RenderTarget.T with type t = a) target size = 
    let internal = GL.RBO.create () in
    let context = M.context target in
    let idpool = Context.LL.rbo_pool context in
    let id = Context.ID_Pool.get_next idpool in
    let capabilities = Context.capabilities context in
    begin if size.Vector2i.x >= capabilities.Context.max_renderbuffer_size 
    || size.Vector2i.y >= capabilities.Context.max_renderbuffer_size then
      Error `RBO_too_large
    else
      Ok ()
    end >>>= fun () ->
    GL.RBO.bind (Some internal);
    GL.RBO.storage GLTypes.TextureFormat.RGBA8 size.Vector2i.x size.Vector2i.y;
    GL.RBO.bind None;
    let finalize _ = Context.ID_Pool.free idpool id in
    let buf = {id; internal; size} in
    Gc.finalise finalize buf;
    buf

  let to_color_attachment t = 
    Attachment.ColorAttachment.ColorRBO t.internal

  let size t = t.size

end


module DepthBuffer = struct

  type t = {
    id : int;
    internal : GL.RBO.t;
    size : Vector2i.t
  }

  let create (type a) (module M : RenderTarget.T with type t = a) target size = 
    let internal = GL.RBO.create () in
    let context = M.context target in
    let idpool = Context.LL.rbo_pool context in
    let id = Context.ID_Pool.get_next idpool in
    let capabilities = Context.capabilities context in
    begin if size.Vector2i.x >= capabilities.Context.max_renderbuffer_size 
    || size.Vector2i.y >= capabilities.Context.max_renderbuffer_size then
      Error `RBO_too_large
    else
      Ok ()
    end >>>= fun () ->
    GL.RBO.bind (Some internal);
    GL.RBO.storage GLTypes.TextureFormat.Depth24 size.Vector2i.x size.Vector2i.y;
    GL.RBO.bind None;
    let finalize _ = Context.ID_Pool.free idpool id in
    let buf = {id; internal; size} in
    Gc.finalise finalize buf;
    buf

  let to_depth_attachment t = 
    Attachment.DepthAttachment.DepthRBO t.internal

  let size t = t.size

end


module DepthStencilBuffer = struct

  type t = {
    id : int;
    internal : GL.RBO.t;
    size : Vector2i.t
  }

  let create (type a) (module M : RenderTarget.T with type t = a) target size = 
    let internal = GL.RBO.create () in
    let context = M.context target in
    let idpool = Context.LL.rbo_pool context in
    let id = Context.ID_Pool.get_next idpool in
    let capabilities = Context.capabilities context in
    begin if size.Vector2i.x >= capabilities.Context.max_renderbuffer_size
    || size.Vector2i.y >= capabilities.Context.max_renderbuffer_size then
      Error `RBO_too_large
    else
      Ok ()
    end >>>= fun () ->
    GL.RBO.bind (Some internal);
    GL.RBO.storage GLTypes.TextureFormat.Depth24Stencil8 size.Vector2i.x size.Vector2i.y;
    GL.RBO.bind None;
    let finalize _ = Context.ID_Pool.free idpool id in
    let buf = {id; internal; size} in
    Gc.finalise finalize buf;
    buf

  let to_depth_stencil_attachment t = 
    Attachment.DepthStencilAttachment.DepthStencilRBO t.internal

  let size t = t.size

end   


module StencilBuffer = struct

  type t = {
    id : int;
    internal : GL.RBO.t;
    size : Vector2i.t
  }

  let create (type a) (module M : RenderTarget.T with type t = a) target size = 
    let internal = GL.RBO.create () in
    let context = M.context target in
    let idpool = Context.LL.rbo_pool context in
    let id = Context.ID_Pool.get_next idpool in
    let capabilities = Context.capabilities context in
    begin if size.Vector2i.x >= capabilities.Context.max_renderbuffer_size 
    || size.Vector2i.y >= capabilities.Context.max_renderbuffer_size then
      Error `RBO_too_large
    else
      Ok ()
    end >>>= fun () ->
    GL.RBO.bind (Some internal);
    GL.RBO.storage GLTypes.TextureFormat.Stencil8 size.Vector2i.x size.Vector2i.y;
    GL.RBO.bind None;
    let finalize _ = Context.ID_Pool.free idpool id in
    let buf = {id; internal; size} in
    Gc.finalise finalize buf;
    buf

  let to_stencil_attachment t = 
    Attachment.StencilAttachment.StencilRBO t.internal

  let size t = t.size

end   


