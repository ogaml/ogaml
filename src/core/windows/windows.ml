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

    type t 

    external create : enum list -> t = "caml_mkstyle_W"

end


module WindowHandle = struct

    type t

    external register_class : string -> unit = "caml_register_class_W"

    external create_private : 
        string -> string -> (int * int) -> (int * int) -> WindowStyle.t -> t 
        = "caml_create_window_W"

    external get_rect :
        t -> (int * int * int * int)
        = "caml_get_window_rect"

    let create ~classname ~name ~origin ~size ~style = 
        create_private classname name origin size style

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

    type t

    type modifiers = {shift : bool; ctrl : bool; lock : bool; alt : bool}

    type position = {x : int; y : int}

    type key = Code of int | Char of char

end