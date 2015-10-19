
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

  external create : int -> int -> int -> int -> t = "caml_cocoa_create_nsrect"

end

module OGApplication = struct

  type t

  (* Abstract functions *)
  external abstract_create : unit -> t = "caml_cocoa_create_app"

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

  (* Abstract functions *)
  external abstract_create : NSRect.t option -> t = "caml_cocoa_create_window"

  (* Exposed functions *)
  let create ?frame () =
    abstract_create frame

end
