module WindowStyle = struct

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

    external create : enum list -> t = "caml_mkstyle_W"

end


module WindowHandle = struct

    type t

    external register_class : string -> unit = "caml_register_class_W"

    external create_private : 
        string -> string -> (int * int * int * int) -> WindowStyle.t -> int -> t 
        = "caml_create_window_W"
    
    external get_style : 
        t -> WindowStyle.t
        = "caml_get_window_style"

    external set_style : 
        t -> WindowStyle.t -> unit
        = "caml_set_window_style"

    external set_text : 
        t -> string -> unit 
        = "caml_set_window_text"

    external screen_to_client : 
        t -> (int * int) -> (int * int)
        = "caml_screen_to_client"

    external client_to_screen : 
        t -> (int * int) -> (int * int)
        = "caml_client_to_screen"

    external get_rect :
        t -> (int * int * int * int)
        = "caml_get_window_rect"

    external fullscreen_size :
        unit -> (int * int)
        = "caml_fullscreen_size"

    external adjust_rect : 
        t -> (int * int * int * int) -> WindowStyle.t -> (int * int * int * int)
        = "caml_adjust_window_rect"

    external move : 
        t -> (int * int * int * int) -> bool -> bool -> unit 
        = "caml_move_window"

    external attach_userdata : 
        t -> 'a -> unit
        = "caml_attach_userdata" 

    external swap_buffers : 
        t -> unit
        = "caml_swap_buffers"

    external process_events :
        t -> unit
        = "caml_process_events"

    external has_focus :
        t -> bool
        = "caml_window_has_focus"

    external close :
        t -> unit
        = "caml_close_window"

    external destroy :
        t -> unit
        = "caml_destroy_window"

    external show_cursor : 
        t -> bool -> unit
        = "caml_show_cursor"

    external set_fullscreen_devmode : 
        t -> int -> int -> bool
        = "caml_set_fullscreen_devmode"

    external unset_fullscreen_devmode :
        t -> bool
        = "caml_unset_fullscreen_devmode"

    let create ~classname ~name ~rect ~style ~uid = 
        create_private classname name rect style uid

end


module PixelFormat = struct

    type t

    type descriptor

    external simple_descriptor : WindowHandle.t -> int -> int -> descriptor 
        = "caml_simple_pfmt_descriptor"
        
    external choose : WindowHandle.t -> descriptor -> t
        = "caml_choose_pixelformat"

    external set : WindowHandle.t -> descriptor -> t -> unit
        = "caml_set_pixelformat"

    external destroy_descriptor : descriptor -> unit
        = "caml_destroy_pfmt_descriptor"

end


module Glew = struct

    external init : unit -> string
        = "caml_glew_init"

end


module GlContext = struct

    type t

    external create : WindowHandle.t -> t = "caml_wgl_create_context"

    external make_current : WindowHandle.t -> t -> unit = "caml_wgl_make_current"

    external remove_current : WindowHandle.t -> unit = "caml_wgl_remove_current"

    external destroy : t -> unit = "caml_wgl_destroy"

    external is_null : t -> bool = "caml_wgl_isnull"

end


module Event = struct

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
        | MouseMoved of int * int

    external async_key_state : key -> bool = "caml_get_async_key_state"

    external cursor_position : unit -> (int * int) = "caml_cursor_position"

    external set_cursor_position : (int * int) -> unit = "caml_set_cursor_position"

    external async_mouse_state : mouse_button -> bool = "caml_get_async_mouse_state"

    external swap_button : unit -> bool = "caml_button_swap"

end


module Utils = struct

    external get_full_path : string -> string = "caml_get_full_path"

end