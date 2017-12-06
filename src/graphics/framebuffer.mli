module OutputBuffer = GLTypes.FBOOutputBuffer

type t

val create : (module RenderTarget.T with type t = 'a) -> 'a -> t

val attach_color : (module Attachment.ColorAttachable with type t = 'a) 
                    -> t -> int -> 'a -> 
                    (unit, [> `Attachment_too_large | `Too_many_color_attachments]) result

val attach_depth : (module Attachment.DepthAttachable with type t = 'a)
                    -> t -> 'a -> (unit, [> `Attachment_too_large]) result

val attach_stencil : (module Attachment.StencilAttachable with type t = 'a)
                    -> t -> 'a -> (unit, [> `Attachment_too_large]) result

val attach_depthstencil : (module Attachment.DepthStencilAttachable with type t = 'a)
                    -> t -> 'a -> (unit, [> `Attachment_too_large]) result

val has_color : t -> bool

val has_depth : t -> bool

val has_stencil : t -> bool

val size : t -> OgamlMath.Vector2i.t

val context : t -> Context.t

val clear : ?buffers:OutputBuffer.t list -> ?color:Color.t option -> 
            ?depth:bool -> ?stencil:bool -> t -> 
            (unit, [> `Duplicate_color_buffer | `Invalid_color_buffer | `Too_many_draw_buffers]) result

val bind : t -> ?buffers:OutputBuffer.t list -> DrawParameter.t -> 
            (unit, [> `Duplicate_color_buffer | `Invalid_color_buffer | `Too_many_draw_buffers]) result

