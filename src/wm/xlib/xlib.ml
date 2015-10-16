
module Display = struct

  type t

  type window


  external abstract_open  : string option -> t = "caml_xopen_display"

  external abstract_screen_size    : t -> int -> (int * int) = "caml_xscreen_size"

  external abstract_screen_size_mm : t -> int -> (int * int) = "caml_xscreen_sizemm"

  external abstract_root_window : t -> int -> window = "caml_xroot_window"

  external abstract_create_simple_window : 
    t -> window -> (int * int) -> (int * int) -> window 
    = "caml_xcreate_simple_window"


  external screen_count : t -> int = "caml_xscreen_count"
  
  external default_screen : t -> int = "caml_xdefault_screen"

  external map_window : t -> window -> unit = "caml_xmap_window"

  external flush : t -> unit = "caml_xflush"


  let create ?hostname ?display:(display = 0) ?screen:(screen = 0) () =
    match hostname with
    |None -> abstract_open None
    |Some(s) -> abstract_open (Some (Printf.sprintf "%s:%i.%i" s display screen))

  let screen_size ?screen display = 
    match screen with
    |None -> abstract_screen_size display (default_screen display)
    |Some(s) -> abstract_screen_size display s

  let screen_size_mm ?screen display = 
    match screen with
    |None -> abstract_screen_size_mm display (default_screen display)
    |Some(s) -> abstract_screen_size_mm display s

  let root_window ?screen display =
    match screen with
    |None -> abstract_root_window display (default_screen display)
    |Some(s) -> abstract_root_window display s

  let create_simple_window ~display ~parent ~size ~origin = 
    abstract_create_simple_window display parent origin size

end
