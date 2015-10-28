
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
    | RGBA           
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


  (* Abstract functions *)
  external abstract_choose_vinfo : 
    Display.t -> int -> attribute list -> int -> t = "caml_glx_choose_visual"


  (* Implementation of abstract functions *)
  let choose display ?screen attl =
    let att_length = 
      List.fold_left (fun v e ->
        match e with
        |RGBA |Stereo |DoubleBuffer -> v+1
        | _ -> v+2
      ) 0 attl
    in
    match screen with
    |None -> abstract_choose_vinfo 
        display 
        (Display.default_screen display) 
        attl att_length
    |Some(s) -> abstract_choose_vinfo 
        display 
        s attl
        att_length


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
    Display.t -> t -> (int * int) -> (int * int) -> int -> t
    = "caml_xcreate_simple_window"


  (* Exposed functions *)
  external attach : Display.t -> t -> GLContext.t -> unit = "caml_glx_make_current"

  external detach : Display.t -> t -> unit = "caml_glx_remove_current"

  external map : Display.t -> t -> unit = "caml_xmap_window"

  external unmap : Display.t -> t -> unit = "caml_xunmap_window"

  external destroy : Display.t -> t -> unit = "caml_xdestroy_window"

  external size : Display.t -> t -> (int * int) = "caml_size_window"

  external swap : Display.t -> t -> unit = "caml_glx_swap_buffers"


  (* Implementation of abstract functions *)
  let root_of ?screen display =
    match screen with
    |None -> abstract_root_window display (Display.default_screen display)
    |Some(s) -> abstract_root_window display s

  let create_simple ~display ~parent ~size ~origin ~background = 
    abstract_create_simple_window display parent origin size background


end


(* Atom module *)
module Atom = struct

  (* Atom type *)
  type t


  (* Abstract functions *)
  external abstract_setwm_protocols : 
    Display.t -> Window.t -> t array -> int -> unit
    = "caml_xset_wm_protocols"


  (* Exposed functions *)
  external intern : Display.t -> string -> bool -> t option = "caml_xintern_atom"


  (* Implementation *)
  let set_wm_protocols disp win plist = 
    let arr = Array.of_list plist in
    abstract_setwm_protocols disp win arr (Array.length arr)

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



