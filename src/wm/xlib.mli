(** Xlib implementation in Ocaml *)

module rec Display : sig

  exception X_display_error of string

  type t

  val create : unit -> t

  val screen : t -> int -> Screen.t

end


and Screen : sig

  type t

  val root : t -> Window.t

end


and Window : sig 

  type t

end

