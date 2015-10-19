
(* Buggued function, do not initialize the ARP *)
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

  val create : ?frame:NSRect.t -> unit -> t

end
