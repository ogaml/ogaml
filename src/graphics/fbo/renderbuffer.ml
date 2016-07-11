open OgamlMath

module DepthBuffer = struct

  type t = {
    id : int;
    internal : GL.RBO.t;
    size : Vector2i.t
  }

  let create (type a) (module M : RenderTarget.T with type t = a) target size = 
    let internal = GL.RBO.create () in
    let state = M.state target in
    let id = State.LL.rbo_id state in
    GL.RBO.bind (Some internal);
    GL.RBO.storage GLTypes.TextureFormat.Depth24 size.Vector2i.x size.Vector2i.y;
    GL.RBO.bind None;
    {id; internal; size}

  let to_depth_attachment t = 
    Attachment.DepthAttachment.DepthRBO t.internal

  let size t = t.size

end
    
