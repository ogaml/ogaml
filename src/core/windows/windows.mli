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
        rect:(int * int * int * int) ->
        style:WindowStyle.t -> 
        uid:int -> t

    val set_text : t -> string -> unit

    val get_rect : t -> (int * int * int * int)
    
    val move : t -> (int * int * int * int) -> unit

    val attach_userdata : t -> 'a -> unit

    val swap_buffers : t -> unit

    val process_events : t -> unit

    val has_focus : t -> bool

    val close : t -> unit

    val destroy : t -> unit

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


module Event : sig

    type modifiers = {shift : bool; ctrl : bool; lock : bool; alt : bool}

    type position = {x : int; y : int}

    type key = Code of int | Char of char

    type t =
        | Unknown
        | Closed
        | Resize of bool (* True iff it is not a minimization *)
        | StartResize
        | StopResize
        | KeyDown of key * modifiers
        | KeyUp of key * modifiers

    val async_key_state : key -> bool 

    val cursor_position : unit -> (int * int)

    val set_cursor_position : (int * int) -> unit

end

