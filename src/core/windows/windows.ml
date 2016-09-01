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

    let create ~classname ~name ~origin ~size ~style = 
        create_private classname name origin size style

end