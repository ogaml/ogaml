
module Display : sig

  type t

  val create : ?hostname:string -> ?display:int -> ?screen:int -> unit -> t

  val screen_count : t -> int

  val default_screen : t -> int

  val flush : t -> unit

  val screen_size : ?screen:int -> t -> (int * int)

  val screen_size_mm : ?screen:int -> t -> (int * int)

end


module Window : sig

  type t

  val root_of : ?screen:int -> Display.t -> t

  val create_simple : display:Display.t -> parent:t -> size:(int * int) -> 
                      origin:(int * int) -> background:int -> t

  val map : Display.t -> t -> unit

  val unmap : Display.t -> t -> unit

  val destroy : Display.t -> t -> unit

  val size : Display.t -> t -> (int * int)

end


module Atom : sig

  type t

  val intern : Display.t -> string -> bool -> t option

  val set_wm_protocols : Display.t -> Window.t -> t list -> unit

end


module Event : sig

  type t

  type modifiers = {shift : bool; ctrl : bool; lock : bool; alt : bool}

  type position = {x : int; y : int}

  type key = Code of int | Char of char

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
    
  val set_mask : Display.t -> Window.t -> mask list -> unit

  val next : Display.t -> Window.t -> t option

  val data : t -> enum

end



