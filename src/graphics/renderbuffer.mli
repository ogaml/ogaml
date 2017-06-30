
exception RBO_Error of string


module ColorBuffer : sig

  type t

  val create : (module RenderTarget.T with type t = 'a) -> 'a -> OgamlMath.Vector2i.t -> t

  val to_color_attachment : t -> Attachment.ColorAttachment.t

  val size : t -> OgamlMath.Vector2i.t

end


module DepthBuffer : sig

  type t

  val create : (module RenderTarget.T with type t = 'a) -> 'a -> OgamlMath.Vector2i.t -> t

  val to_depth_attachment : t -> Attachment.DepthAttachment.t

  val size : t -> OgamlMath.Vector2i.t

end


module DepthStencilBuffer : sig

  type t

  val create : (module RenderTarget.T with type t = 'a) -> 'a -> OgamlMath.Vector2i.t -> t

  val to_depth_stencil_attachment : t -> Attachment.DepthStencilAttachment.t

  val size : t -> OgamlMath.Vector2i.t

end


module StencilBuffer : sig

  type t

  val create : (module RenderTarget.T with type t = 'a) -> 'a -> OgamlMath.Vector2i.t -> t

  val to_stencil_attachment : t -> Attachment.StencilAttachment.t

  val size : t -> OgamlMath.Vector2i.t

end
