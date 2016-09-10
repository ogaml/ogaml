
exception FBO_Error of string

type t

val create : (module RenderTarget.T with type t = 'a) -> 'a -> t

val attach_color : (module Attachment.ColorAttachable with type t = 'a) 
                    -> t -> int -> 'a -> unit

val attach_depth : (module Attachment.DepthAttachable with type t = 'a)
                    -> t -> 'a -> unit

val attach_stencil : (module Attachment.StencilAttachable with type t = 'a)
                    -> t -> 'a -> unit

val attach_depthstencil : (module Attachment.DepthStencilAttachable with type t = 'a)
                    -> t -> 'a -> unit

val has_color : t -> bool

val has_depth : t -> bool

val has_stencil : t -> bool

val size : t -> OgamlMath.Vector2i.t

val context : t -> Context.t

val clear : ?color:Color.t option -> ?depth:bool -> ?stencil:bool -> t -> unit

val bind : t -> DrawParameter.t -> unit

