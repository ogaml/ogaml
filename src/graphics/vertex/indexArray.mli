
module Source : sig

  type t

  val empty : int -> t

  val add : t -> int -> unit

  val (<<) : t -> int -> t

  val length : t -> int

  val append : t -> t -> t

end

type static

type dynamic

type 'a t 

val static : (module RenderTarget.T with type t = 'a) -> 'a -> Source.t -> static t

val dynamic : (module RenderTarget.T with type t = 'a) -> 'a -> Source.t -> dynamic t

val rebuild : dynamic t -> Source.t -> int -> unit

val length : 'a t -> int


module LL : sig

  val bind : State.t -> 'a t -> unit

end

