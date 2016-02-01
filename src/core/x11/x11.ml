
(* Display module *)
module Display = struct

  (* Display type *)
  type t


  (* Abstract functions (not exposed) *)
  external abstract_open  : string option -> t = "caml_xopen_display"

  external abstract_screen_size    : t -> int -> (int * int) = "caml_xscreen_size"

  external abstract_screen_size_mm : t -> int -> (int * int) = "caml_xscreen_sizemm"

  
  (* Exposed functions *)
  external screen_count : t -> int = "caml_xscreen_count"
  
  external default_screen : t -> int = "caml_xdefault_screen"

  external flush : t -> unit = "caml_xflush"


  (* Implementation of abstract functions *)
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

end


(* VisualInfo module *)
module VisualInfo = struct

  type t

  type attribute = 
    | BufferSize     of int
    | Level          of int
    | DoubleBuffer
    | Stereo         
    | AuxBuffers     of int
    | RedSize        of int
    | GreenSize      of int
    | BlueSize       of int
    | AlphaSize      of int
    | DepthSize      of int
    | StencilSize    of int
    | AccumRedSize   of int
    | AccumBlueSize  of int
    | AccumAlphaSize of int
    | AccumGreenSize of int
    | Renderable
    | Samples        of int
    | SampleBuffers  of int


  (* Abstract functions *)
  external abstract_choose_vinfo : 
    Display.t -> int -> attribute list -> int -> t = "caml_glx_choose_visual"


  (* Implementation of abstract functions *)
  let choose display ?screen attl =
    match screen with
    |None -> abstract_choose_vinfo 
        display 
        (Display.default_screen display)
        attl (List.length attl * 2)
    |Some(s) -> abstract_choose_vinfo 
        display 
        s attl
        (List.length attl * 2)


end


(* GLContext module *)
module GLContext = struct

  type t

  (* Exposed functions *)
  external create : Display.t -> VisualInfo.t -> t = "caml_glx_create_context"

  external destroy : Display.t -> t -> unit = "caml_glx_destroy_context"

end


(* Window module *)
module Window = struct

  (* Window type *)
  type t


  (* Abstract functions *)
  external abstract_root_window : Display.t -> int -> t = "caml_xroot_window"

  external abstract_create_simple_window : 
    Display.t -> t -> (int * int) -> (int * int) -> VisualInfo.t -> t
    = "caml_xcreate_simple_window"


  (* Exposed functions *)
  external attach : Display.t -> t -> GLContext.t -> unit = "caml_glx_make_current"

  external map : Display.t -> t -> unit = "caml_xmap_window"

  external unmap : Display.t -> t -> unit = "caml_xunmap_window"

  external destroy : Display.t -> t -> unit = "caml_xdestroy_window"

  external position : Display.t -> t -> (int * int) = "caml_xwindow_position"

  external size : Display.t -> t -> (int * int) = "caml_size_window"

  external resize : Display.t -> t -> int -> int -> unit = "caml_resize_window"

  external swap : Display.t -> t -> unit = "caml_glx_swap_buffers"

  external has_focus : Display.t -> t -> bool = "caml_has_focus"

  external set_title : Display.t -> t -> string -> unit = "caml_xwindow_set_title"

  external set_size_hints : Display.t -> t -> (int * int) -> (int * int) -> unit = "caml_set_wm_size_hints"

  external title : Display.t -> t -> string = "caml_xwindow_get_title"


  (* Implementation of abstract functions *)
  let root_of ?screen display =
    match screen with
    |None -> abstract_root_window display (Display.default_screen display)
    |Some(s) -> abstract_root_window display s

  let create_simple ~display ~parent ~size ~origin ~visual = 
    abstract_create_simple_window display parent origin size visual


end


(* Atom module *)
module Atom = struct

  (* Atom type *)
  type t


  (* Abstract functions *)
  external abstract_wm_add : unit -> t = "caml_wm_add"

  external abstract_wm_remove : unit -> t = "caml_wm_remove"

  external abstract_wm_toggle : unit -> t = "caml_wm_toggle"

  external abstract_setwm_protocols : 
    Display.t -> Window.t -> t array -> int -> unit
    = "caml_xset_wm_protocols"

  external abstract_change_property :
    Display.t -> Window.t -> t -> t array -> int -> unit
    = "caml_xchange_property"

  external abstract_send_event :
    Display.t -> Window.t -> t -> t array -> int -> unit
    = "caml_xsend_event"

  (* Exposed functions *)
  external intern : Display.t -> string -> bool -> t option = "caml_xintern_atom"



  (* Implementation *)
  let set_wm_protocols disp win plist = 
    let arr = Array.of_list plist in
    abstract_setwm_protocols disp win arr (Array.length arr)

  let change_property disp win atom plist = 
    let arr = Array.of_list plist in
    abstract_change_property disp win atom arr (Array.length arr)

  let send_event disp win atom plist = 
    let arr = Array.of_list plist in
    abstract_send_event disp win atom arr (Array.length arr)

  let wm_add = abstract_wm_add ()

  let wm_remove = abstract_wm_remove ()

  let wm_toggle = abstract_wm_toggle ()

end


(* Event module *)
module Event = struct

  type t

  type modifiers = {shift : bool; ctrl : bool; lock : bool; alt : bool}

  type position = {x : int; y : int}

  type key = Code of int | Char of char

  (* Event enum *)
  type enum = 
    | Unknown
    | KeyPress      of key * modifiers
    | KeyRelease    of key * modifiers
    | ButtonPress   of int * position * modifiers
    | ButtonRelease of int * position * modifiers
    | MotionNotify  of position
    | EnterNotify     
    | LeaveNotify     
    | FocusIn         
    | FocusOut        
    | KeymapNotify    
    | Expose          
    | GraphicsExpose  
    | NoExpose        
    | VisibilityNotify
    | CreateNotify    
    | DestroyNotify   
    | UnmapNotify     
    | MapNotify       
    | MapRequest      
    | ReparentNotify  
    | ConfigureNotify 
    | ConfigureRequest
    | GravityNotify   
    | ResizeRequest   
    | CirculateNotify 
    | CirculateRequest
    | PropertyNotify  
    | SelectionClear  
    | SelectionRequest
    | SelectionNotify 
    | ColormapNotify  
    | ClientMessage of Atom.t
    | MappingNotify   
    | GenericEvent    

  (* Event masks enum *)
  type mask = 
    | KeyPressMask            
    | KeyReleaseMask          
    | ButtonPressMask         
    | ButtonReleaseMask       
    | EnterWindowMask         
    | LeaveWindowMask         
    | PointerMotionMask       
    | PointerMotionHintMask   
    | Button1MotionMask       
    | Button2MotionMask       
    | Button3MotionMask       
    | Button4MotionMask       
    | Button5MotionMask       
    | ButtonMotionMask        
    | KeymapStateMask         
    | ExposureMask            
    | VisibilityChangeMask    
    | StructureNotifyMask     
    | ResizeRedirectMask      
    | SubstructureNotifyMask  
    | SubstructureRedirectMask
    | FocusChangeMask         
    | PropertyChangeMask      
    | ColormapChangeMask      
    | OwnerGrabButtonMask     


  (* Exposed functions *)
  external set_mask : Display.t -> Window.t -> mask list -> unit 
    = "caml_xselect_input"

  external next : Display.t -> Window.t -> t option = "caml_xnext_event"

  external data : t -> enum = "caml_event_type"

end


module Mouse = struct

  external warp : Display.t -> Window.t -> int -> int -> unit 
    = "caml_xwarp_pointer"

  external position : Display.t -> Window.t -> int * int
    = "caml_xquery_pointer_position"

  external button_down : Display.t -> Window.t -> int -> bool
    = "caml_xquery_button_down"

end


module Keyboard = struct

  external key_down : Display.t -> Event.key -> bool 
    = "caml_is_key_down"

end
