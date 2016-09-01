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