
module type Priority = sig

  type t

  val compare : t -> t -> int

end


module type Q = sig

  type priority

  type 'a t

  val empty : 'a t

  val is_empty : 'a t -> bool

  val singleton : priority -> 'a -> 'a t

  val merge : 'a t -> 'a t -> 'a t

  val insert : 'a t -> priority -> 'a -> 'a t

  val top : 'a t -> ('a, unit) result

  val pop : 'a t -> ('a t, unit) result

  val extract : 'a t -> ('a * 'a t, unit) result

end


module Make : functor (P : Priority) -> Q with type priority = P.t

