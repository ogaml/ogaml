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
        | WS_ClipChildren
        | WS_ClipSiblings

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

    val set_style : t -> WindowStyle.t -> unit

    val get_style : t -> WindowStyle.t 

    val set_text : t -> string -> unit

    val fullscreen_size : unit -> (int * int)

    val get_rect : t -> (int * int * int * int)

    val screen_to_client : t -> (int * int) -> (int * int)

    val client_to_screen : t -> (int * int) -> (int * int)

    val adjust_rect : t -> (int * int * int * int) -> WindowStyle.t -> (int * int * int * int)
    
    val move : t -> (int * int * int * int) -> bool -> bool -> unit

    val attach_userdata : t -> 'a -> unit

    val swap_buffers : t -> unit

    val process_events : t -> unit

    val has_focus : t -> bool

    val close : t -> unit

    val destroy : t -> unit

    val show_cursor : t -> bool -> unit

    val set_fullscreen_devmode : t -> int -> int -> bool

    val unset_fullscreen_devmode : t -> bool

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

    type mouse_button = 
        | LButton
        | RButton
        | MButton
        | XButton1
        | XButton2

    type t =
        | Unknown
        | Closed
        | Resize of bool (* True iff it is not a minimization *)
        | StartResize
        | StopResize
        | KeyDown of key * modifiers
        | KeyUp of key * modifiers
        | MouseVWheel of int * int * int * modifiers
        | MouseHWheel of int * int * int * modifiers
        | ButtonUp of mouse_button * int * int * modifiers
        | ButtonDown of mouse_button * int * int * modifiers

    val async_key_state : key -> bool 

    val cursor_position : unit -> (int * int)

    val set_cursor_position : (int * int) -> unit

    val async_mouse_state : mouse_button -> bool

    val swap_button : unit -> bool

end

