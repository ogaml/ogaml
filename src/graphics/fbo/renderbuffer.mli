
module DepthBuffer : sig

  type t

  val create : (module RenderTarget.T with type t = 'a) -> 'a -> OgamlMath.Vector2i.t -> t

  val to_depth_attachment : t -> Attachment.DepthAttachment.t

  val size : t -> OgamlMath.Vector2i.t

end
