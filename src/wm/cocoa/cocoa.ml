
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

  external a_create : float -> float -> float -> float -> t = "caml_cocoa_create_nsrect"

  let create x y w h =
    let f = float_of_int in
    a_create (f x) (f y) (f w) (f h)

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
  external abstract_create : NSRect.t -> style_mask list -> backing_store -> t =
    "caml_cocoa_create_window"

  (* Exposed functions *)
  let create ~frame ~style_mask ~backing () =
    abstract_create frame style_mask backing

end
