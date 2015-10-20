
external init_arp : unit -> unit = "caml_init_arp"

external test_cocoa : unit -> unit = "caml_cocoa_test"

external open_window : unit -> unit = "caml_open_window"

module NSString = struct

  type t

  external create : string -> t = "caml_cocoa_gen_string"

  external print : t -> unit = "caml_cocoa_print_string"

end

module NSRect = struct

  type t

  external a_create : float -> float -> float -> float -> t
    = "caml_cocoa_create_nsrect"

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

module OGApplication = struct

  type t

  (* Abstract functions *)
  external abstract_create : unit -> t = "caml_cocoa_create_app"

  external run : unit -> unit = "caml_cocoa_run_app"

  (* Exposed functions *)
  let create () = abstract_create ()

end

module OGApplicationDelegate = struct

  type t

  (* Abstract functions *)
  external abstract_create : unit -> t = "caml_cocoa_create_appdgt"

  (* Exposed functions *)
  let create () = abstract_create ()

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

  (* Exposed functions *)
  let create ~frame ~style_mask ~backing ~defer () =
    abstract_create frame style_mask backing defer

end
