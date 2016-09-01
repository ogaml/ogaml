module WindowStyle : sig 

    type enum =
        | WS_Border
        | WS_Caption
        | WS_Maximize
        | WS_MaximizeBox
        | WS_Minimize
        | WS_MinimizeBox
        | WS_Popup
        | WS_Sysmenu
        | WS_Thickframe
        | WS_Visible

    type t

    val create : enum list -> t

end


module WindowHandle : sig

    type t

    val register_class : string -> unit

    val create : 
        classname:string ->
        name:string ->
        origin:(int * int) ->
        size:(int * int) ->
        style:WindowStyle.t -> t

end


module PixelFormat : sig

    type t

    type descriptor

    val simple_descriptor : WindowHandle.t -> int -> int -> descriptor

    val choose : WindowHandle.t -> descriptor -> t
    
    val set : WindowHandle.t -> descriptor -> t -> unit

    val destroy_descriptor : descriptor -> unit

end


module Glew : sig

    val init : unit -> string

end


module GlContext : sig

    type t

    val create : WindowHandle.t -> t

    val make_current : WindowHandle.t -> t -> unit 

    val remove_current : WindowHandle.t -> unit

    val destroy : t -> unit

    val is_null : t -> bool

end