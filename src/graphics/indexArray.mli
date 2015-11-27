
module Source : sig

  type t

  val empty : int -> t

  val add : t -> int -> unit

  val (<<) : t -> int -> t

  val length : t -> int

end

type static

type dynamic

type 'a t 

val static : Source.t -> static t

val dynamic : Source.t -> dynamic t

val rebuild : dynamic t -> Source.t -> int -> unit

val length : 'a t -> int


module LL : sig

  val bind : State.t -> 'a t -> unit

end

