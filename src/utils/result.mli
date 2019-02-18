module Operators : sig

  val (>>) : ('a, 'b) result -> ('c, 'b) result -> ('c, 'b) result

  val (||>) : 'a -> ('b -> 'a -> 'c) -> ('b -> 'c)

  val (>>=) : ('a, 'b) result -> ('a -> ('c, 'b) result) -> ('c, 'b) result

  val (>>>=) : ('a, 'b) result -> ('a -> 'c) -> ('c, 'b) result

end

module List : sig

  val iter : ('a -> (unit, 'b) result) -> 'a list -> (unit, 'b) result

  val map : ('a -> ('b, 'c) result) -> 'a list -> ('b list, 'c) result

  val fold_left : ('a -> 'b -> ('a, 'c) result) -> 'a -> 'b list -> ('a, 'c) result

  val fold_right : ('a -> 'b -> ('b, 'c) result) -> 'a list -> 'b -> ('b, 'c) result

end

val make : ?result:'a -> 'b -> ('a, 'b) result

val bind : ('a, 'b) result -> ('a -> ('c, 'b) result) -> ('c, 'b) result

val apply : ('a, 'b) result -> ('a -> 'c) -> ('c, 'b) result

val is_ok : ('a, 'b) result -> bool

val is_error : ('a, 'b) result -> bool

val assert_ok : ('a, 'b) result -> 'a

val throw : ('a, exn) result -> 'a

val catch : ('a -> 'b) -> 'a -> ('b, exn) result

val handle : ('b -> 'a) -> ('a, 'b) result -> 'a

val map : ('a -> 'c) -> ('a, 'b) result -> ('c, 'b) result

val map_error : ('b -> 'c) -> ('a, 'b) result -> ('a, 'c) result

val opt : ('a, 'b) result -> 'a option

val from_opt : 'a option -> ('a, unit) result

val iteri : int -> int -> (int -> (unit, 'a) result) -> (unit, 'a) result
