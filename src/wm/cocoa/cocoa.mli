
val init_arp : unit -> unit

val test_cocoa : unit -> unit

val open_window : unit -> unit

module NSString : sig

  type t

  val create : string -> t

  val print : t -> unit

end

module NSRect : sig

  type t

  val create : int -> int -> int -> int -> t

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

module OGApplication : sig

  type t

  val create : unit -> t

  val run : unit -> unit

end

module OGApplicationDelegate : sig

  type t

  val create : unit -> t

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

end
