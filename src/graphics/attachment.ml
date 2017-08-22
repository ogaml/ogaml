open OgamlMath

module ColorAttachment = struct

  type t = 
    | TextureCubemap of GL.Texture.t * int * int
    | Texture2D of GL.Texture.t * int
    | Texture3D of GL.Texture.t * int * int
    | Texture2DArray of GL.Texture.t * int * int
    | ColorRBO of GL.RBO.t

end

module DepthAttachment = struct

  type t = 
    | Texture2D of GL.Texture.t * int 
    | DepthRBO of GL.RBO.t

end

module StencilAttachment = struct

  type t = 
    | StencilRBO of GL.RBO.t

end

module DepthStencilAttachment = struct

  type t = 
    | DepthStencilRBO of GL.RBO.t

end


module type ColorAttachable = sig

  type t

  val to_color_attachment : t -> ColorAttachment.t

  val size : t -> Vector2i.t

end

module type DepthAttachable = sig

  type t 

  val to_depth_attachment : t -> DepthAttachment.t

  val size : t -> Vector2i.t

end

module type StencilAttachable = sig

  type t

  val to_stencil_attachment : t -> StencilAttachment.t

  val size : t -> Vector2i.t

end

module type DepthStencilAttachable = sig

  type t

  val to_depthstencil_attachment : t -> DepthStencilAttachment.t

  val size : t -> Vector2i.t

end
