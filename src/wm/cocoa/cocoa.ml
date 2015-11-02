
external init_arp : unit -> unit = "caml_init_arp"

external screen_size : unit -> float * float = "caml_cocoa_display_size"

module NSString = struct

  type t

  external create : string -> t = "caml_cocoa_gen_string"

  external get : t -> string = "caml_cocoa_get_string"

end

module NSRect = struct

  type t

  external a_create : float -> float -> float -> float -> t
    = "caml_cocoa_create_nsrect"

  external get : t -> float * float * float * float
    = "caml_cocoa_get_nsrect"

  let create x y w h =
    let f = float_of_int in
    a_create (f x) (f y) (f w) (f h)

end

module NSColor = struct

  type t

  external rgba : float -> float -> float -> float -> t
    = "caml_cocoa_color_rgba"

  external black      : unit -> t = "caml_cocoa_color_black"
  external blue       : unit -> t = "caml_cocoa_color_blue"
  external brown      : unit -> t = "caml_cocoa_color_brown"
  external clear      : unit -> t = "caml_cocoa_color_clear"
  external cyan       : unit -> t = "caml_cocoa_color_cyan"
  external dark_gray  : unit -> t = "caml_cocoa_color_dark_gray"
  external gray       : unit -> t = "caml_cocoa_color_gray"
  external green      : unit -> t = "caml_cocoa_color_green"
  external light_gray : unit -> t = "caml_cocoa_color_light_gray"
  external magenta    : unit -> t = "caml_cocoa_color_magenta"
  external orange     : unit -> t = "caml_cocoa_color_orange"
  external purple     : unit -> t = "caml_cocoa_color_purple"
  external red        : unit -> t = "caml_cocoa_color_red"
  external white      : unit -> t = "caml_cocoa_color_white"
  external yellow     : unit -> t = "caml_cocoa_color_yellow"

end

module Mouse = struct

  external warp : float -> float -> unit = "caml_cg_warp_mouse_cursor_position"

end

module NSEvent = struct

  type t

  type event_type =
    | LeftMouseDown
    | LeftMouseUp
    | RightMouseDown
    | RightMouseUp
    | MouseMoved
    | LeftMouseDragged
    | RightMouseDragged
    | MouseEntered
    | MouseExited
    | KeyDown
    | KeyUp
    | FlagsChanged
    | AppKitDefined
    | SystemDefined
    | ApplicationDefined
    | Periodic
    | CursorUpdate
    | ScrollWheel
    | TabletPoint
    | TabletProximity
    | OtherMouseDown
    | OtherMouseUp
    | OtherMouseDragged
    | EventTypeGesture
    | EventTypeMagnify
    | EventTypeSwipe
    | EventTypeRotate
    | EventTypeBeginGesture
    | EventTypeEndGesture
    | EventTypeSmartMagnify
    | EventTypeQuickLook
    | EventTypePressure

  type modifier_flag =
    | NSAlphaShiftKeyMask
    | NSShiftKeyMask
    | NSControlKeyMask
    | NSAlternateKeyMask
    | NSCommandKeyMask
    | NSNumericPadKeyMask
    | NSHelpKeyMask
    | NSFunctionKeyMask
    | NSDeviceIndependentModifierFlagsMask

  type mouse_button =
    | ButtonLeft
    | ButtonRight
    | ButtonOther

  external get_type : t -> event_type = "caml_cocoa_event_type"

  external modifier_flags : t -> modifier_flag list
    = "caml_cocoa_event_modifier_flags"

  external character : t -> NSString.t = "caml_cocoa_event_characters"

  external key_code : t -> int = "caml_cocoa_event_key_code"

  external mouse_location : unit -> float * float = "caml_cocoa_mouse_location"

  external proper_mouse_location : unit -> float * float
    = "caml_cocoa_proper_mouse_location"

  external pressed_mouse_buttons : unit -> mouse_button list
    = "caml_cocoa_event_pressed_mouse_buttons"

end

module OGEvent = struct

  type t

  type content =
    | CocoaEvent of NSEvent.t
    | CloseWindow

  external get_content : t -> content = "caml_ogevent_get_content"

end

module NSOpenGLPixelFormat = struct

  type t

  type profile =
    | NSOpenGLProfileVersionLegacy
    | NSOpenGLProfileVersion3_2Core

  type attribute =
    | NSOpenGLPFAAllRenderers
    | NSOpenGLPFADoubleBuffer
    | NSOpenGLPFATripleBuffer
    | NSOpenGLPFAStereo
    | NSOpenGLPFAAuxBuffers         of int
    | NSOpenGLPFAColorSize          of int
    | NSOpenGLPFAAlphaSize          of int
    | NSOpenGLPFADepthSize          of int
    | NSOpenGLPFAStencilSize        of int
    | NSOpenGLPFAAccumSize          of int
    | NSOpenGLPFAMinimumPolicy
    | NSOpenGLPFAMaximumPolicy
    | NSOpenGLPFAOffScreen
    | NSOpenGLPFAFullScreen
    | NSOpenGLPFASampleBuffers      of int
    | NSOpenGLPFASamples            of int
    | NSOpenGLPFAAuxDepthStencil
    | NSOpenGLPFAColorFloat
    | NSOpenGLPFAMultisample
    | NSOpenGLPFASupersample
    | NSOpenGLPFASampleAlpha
    | NSOpenGLPFARendererID         of int
    | NSOpenGLPFASingleRenderer
    | NSOpenGLPFANoRecovery
    | NSOpenGLPFAAccelerated
    | NSOpenGLPFAClosestPolicy
    | NSOpenGLPFARobust
    | NSOpenGLPFABackingStore
    | NSOpenGLPFAMPSafe
    | NSOpenGLPFAWindow
    | NSOpenGLPFAMultiScreen
    | NSOpenGLPFACompliant
    | NSOpenGLPFAScreenMask         of int (* TODO int is for mask, go list *)
    | NSOpenGLPFAPixelBuffer
    | NSOpenGLPFARemotePixelBuffer
    | NSOpenGLPFAAllowOfflineRenderers
    | NSOpenGLPFAAcceleratedCompute
    | NSOpenGLPFAOpenGLProfile      of profile
    | NSOpenGLPFAVirtualScreenCount of int

  external abstract_init_with_attributes : int array -> t
    = "caml_cocoa_init_pixelformat_with_attributes"

  let init_with_attributes attributes =
    let profile_to_int = function
      | NSOpenGLProfileVersionLegacy  -> 0x1000
      | NSOpenGLProfileVersion3_2Core -> 0x3200
    in
    let to_ints = function
      | NSOpenGLPFAAllRenderers          -> [1]
      | NSOpenGLPFADoubleBuffer          -> [5]
      | NSOpenGLPFATripleBuffer          -> [3]
      | NSOpenGLPFAStereo                -> [6]
      | NSOpenGLPFAAuxBuffers i          -> [7;i]
      | NSOpenGLPFAColorSize i           -> [8;i]
      | NSOpenGLPFAAlphaSize i           -> [11;i]
      | NSOpenGLPFADepthSize i           -> [12;i]
      | NSOpenGLPFAStencilSize i         -> [13;i]
      | NSOpenGLPFAAccumSize i           -> [14;i]
      | NSOpenGLPFAMinimumPolicy         -> [51]
      | NSOpenGLPFAMaximumPolicy         -> [52]
      | NSOpenGLPFAOffScreen             -> [53]
      | NSOpenGLPFAFullScreen            -> [54]
      | NSOpenGLPFASampleBuffers i       -> [55;i]
      | NSOpenGLPFASamples i             -> [56;i]
      | NSOpenGLPFAAuxDepthStencil       -> [57]
      | NSOpenGLPFAColorFloat            -> [58]
      | NSOpenGLPFAMultisample           -> [59]
      | NSOpenGLPFASupersample           -> [60]
      | NSOpenGLPFASampleAlpha           -> [61]
      | NSOpenGLPFARendererID i          -> [70;i]
      | NSOpenGLPFASingleRenderer        -> [71]
      | NSOpenGLPFANoRecovery            -> [72]
      | NSOpenGLPFAAccelerated           -> [73]
      | NSOpenGLPFAClosestPolicy         -> [74]
      | NSOpenGLPFARobust                -> [75]
      | NSOpenGLPFABackingStore          -> [76]
      | NSOpenGLPFAMPSafe                -> [78]
      | NSOpenGLPFAWindow                -> [80]
      | NSOpenGLPFAMultiScreen           -> [81]
      | NSOpenGLPFACompliant             -> [83]
      | NSOpenGLPFAScreenMask i          -> [84;i]
      | NSOpenGLPFAPixelBuffer           -> [90]
      | NSOpenGLPFARemotePixelBuffer     -> [91]
      | NSOpenGLPFAAllowOfflineRenderers -> [96]
      | NSOpenGLPFAAcceleratedCompute    -> [97]
      | NSOpenGLPFAOpenGLProfile p       -> [99;profile_to_int p]
      | NSOpenGLPFAVirtualScreenCount i  -> [128;i]
    in
    let rec map0 f = function
      | e :: r -> (f e) :: (map0 f r)
      | []     -> [[0]]
    in
    let arg = Array.of_list (List.flatten (map0 to_ints attributes)) in
    abstract_init_with_attributes arg

end

module NSOpenGLContext = struct

  type t

  external init_with_format : NSOpenGLPixelFormat.t -> t
    = "caml_cocoa_init_context_with_format"

end

module OGApplicationDelegate = struct

  type t

  (* Abstract functions *)
  external abstract_create : unit -> t = "caml_cocoa_create_appdgt"

  (* Exposed functions *)
  let create () = abstract_create ()

end

module OGApplication = struct

  type t

  (* Abstract functions *)
  external abstract_init : OGApplicationDelegate.t -> unit
    = "caml_cocoa_init_app"

  external run : unit -> unit = "caml_cocoa_run_app"

  (* Exposed functions *)
  let init delegate = abstract_init delegate

end

module NSWindow = struct

  type t

  type style_mask =
    | Borderless
    | Titled
    | Closable
    | Miniaturizable
    | Resizable
    | TexturedBackground
    | UnifiedTitleAndToolbar
    | FullScreen
    | FullSizeContent

  type backing_store =
    | Retained
    | NonRetained
    | Buffered

  (* Abstract functions *)
  external abstract_create : NSRect.t ->
                             style_mask list ->
                             backing_store ->
                             bool -> t
    = "caml_cocoa_create_window"

  external set_background_color : t -> NSColor.t -> unit
    = "caml_cocoa_window_set_bg_color"

  external make_key_and_order_front : t -> unit
    = "caml_cocoa_window_make_key_and_order_front"

  external center : t -> unit = "caml_cocoa_window_center"

  external make_main : t -> unit = "caml_cocoa_window_make_main"

  external close : t -> unit = "caml_cocoa_window_close"

  external perform_close : t -> unit = "caml_cocoa_window_perform_close"

  external frame : t -> NSRect.t = "caml_cocoa_window_frame"

  external next_event : t -> NSEvent.t option = "caml_cocoa_window_next_event"

  external set_for_events : t -> unit = "caml_cocoa_window_set_for_events"

  external set_autodisplay : t -> bool -> unit
    = "caml_cocoa_window_set_autodisplay"

  (* Exposed functions *)
  let create ~frame ~style_mask ~backing ~defer () =
    abstract_create frame style_mask backing defer

end

module OGWindowController = struct

  type t

  external init_with_window : NSWindow.t -> t
    = "caml_cocoa_window_controller_init_with_window"

  external process_event : t -> unit
    = "caml_cocoa_window_controller_process_event"

  external frame : t -> NSRect.t = "caml_cocoa_controller_frame"

  external content_frame : t -> NSRect.t = "caml_cocoa_controller_content_frame"

  external close_window : t -> unit = "caml_cocoa_window_controller_close"

  external is_window_open : t -> bool = "caml_cocoa_controller_is_window_open"

  external release_window : t -> unit
    = "caml_cocoa_window_controller_release_window"

  external pop_event : t -> OGEvent.t option
    = "caml_cocoa_window_controller_pop_event"

  external set_context : t -> NSOpenGLContext.t -> unit
    = "caml_cocoa_controller_set_glctx"

  external flush_context : t -> unit = "caml_cocoa_controller_flush_glctx"

  external mouse_location : t -> float * float
    = "caml_cocoa_controller_mouse_location"

  external proper_relative_mouse_location : t -> float * float
    = "caml_cocoa_proper_relative_mouse_location"

  external set_proper_relative_mouse_location : t -> float -> float -> unit
    = "caml_cocoa_set_proper_relative_mouse_location"

end
