
val init_arp : unit -> unit

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

  val get_type : t -> event_type

end

module OGEvent : sig

  type t

  type content =
    | CocoaEvent of NSEvent.t
    | CloseWindow

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

  (* TODO Change int *)
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

  val process_event : t -> unit

  val frame : t -> NSRect.t

  val close_window : t -> unit

  val is_window_open : t -> bool

  val release_window : t -> unit

  val pop_event : t -> OGEvent.t option

  val set_context : t -> NSOpenGLContext.t -> unit

  val flush_context : t -> unit

end
