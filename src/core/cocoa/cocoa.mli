
val init_arp : unit -> unit

val screen_size : unit -> float * float

module NSString : sig

  type t

  val create : string -> t

  val get : t -> string

end

module NSRect : sig

  type t

  val create : int -> int -> int -> int -> t

  val get : t -> float * float * float * float

end

module NSColor : sig

  type t

  (** R G B A are float between 0.0 and 1.0 *)
  val rgba : float -> float -> float -> float -> t

  val black      : unit -> t
  val blue       : unit -> t
  val brown      : unit -> t
  val clear      : unit -> t
  val cyan       : unit -> t
  val dark_gray  : unit -> t
  val gray       : unit -> t
  val green      : unit -> t
  val light_gray : unit -> t
  val magenta    : unit -> t
  val orange     : unit -> t
  val purple     : unit -> t
  val red        : unit -> t
  val white      : unit -> t
  val yellow     : unit -> t

end

module Mouse : sig

  val warp : float -> float -> unit

end

module Keyboard : sig

  val is_keycode_pressed : int -> bool

  val is_char_pressed : char -> bool

end

module NSEvent : sig

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

  val get_type : t -> event_type

  (* Key event information *)

  val modifier_flags : unit -> modifier_flag list

  val character : t -> NSString.t

  val key_code : t -> int

  (* Mouse event information *)

  val mouse_location : unit -> float * float

  val proper_mouse_location : unit -> float * float

  val pressed_mouse_buttons : unit -> mouse_button list

end

module OGEvent : sig

  type t

  type key_info = {
    keycode : int ;
    characters : NSString.t ;
    modifier_flags : NSEvent.modifier_flag list
  }

  type content =
    | CocoaEvent  of NSEvent.t
    | CloseWindow
    | KeyUp       of key_info
    | KeyDown     of key_info
    | ResizedWindow

  val get_content : t -> content

end

module NSOpenGLPixelFormat : sig

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

  val init_with_attributes : attribute list -> t

end

module NSOpenGLContext : sig

  type t

  val init_with_format : NSOpenGLPixelFormat.t -> t

end

module OGApplicationDelegate : sig

  type t

  val create : unit -> t

end

module OGApplication : sig

  type t

  val init : OGApplicationDelegate.t -> unit

  (** This runs the application, letting it handle the main loop by itself.
    * It might be best not to use it to handle things in ocaml directly. *)
  val run : unit -> unit

end

module NSWindow : sig

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

  val create : frame:NSRect.t ->
               style_mask:style_mask list ->
               backing:backing_store ->
               defer:bool ->
               unit -> t

  val set_background_color : t -> NSColor.t -> unit

  val make_key_and_order_front : t -> unit

  val center : t -> unit

  val make_main : t -> unit

  val close : t -> unit

  val perform_close : t -> unit

  val frame : t -> NSRect.t

  val next_event : t -> NSEvent.t option

  val set_for_events : t -> unit

  val set_autodisplay : t -> bool -> unit

end

module OGWindowController : sig

  type t

  val init_with_window : NSWindow.t -> t

  val set_title : t -> NSString.t -> unit

  val process_event : t -> unit

  val frame : t -> NSRect.t

  val content_frame : t -> NSRect.t

  val close_window : t -> unit

  val is_window_open : t -> bool

  val release_window : t -> unit

  val pop_event : t -> OGEvent.t option

  val set_context : t -> NSOpenGLContext.t -> unit

  val flush_context : t -> unit

  val mouse_location : t -> float * float

  val proper_relative_mouse_location : t -> float * float

  val set_proper_relative_mouse_location : t -> float -> float -> unit

  val has_focus : t -> bool

end
