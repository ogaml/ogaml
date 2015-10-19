
(* Buggued function, do not initialize the ARP *)
val init_arp : unit -> unit

val test_cocoa : unit -> unit

val open_window : unit -> unit

module NSString : sig

  type t

  val create : string -> t

  val print : t -> unit

end

module OGApplication : sig

  type t

  val create : unit -> t

end
