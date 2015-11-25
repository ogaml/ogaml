
exception Empty

type 'a t

val empty : 'a t

val is_empty : 'a t -> bool

val singleton : 'a -> 'a t

val push : 'a t -> 'a -> 'a t

val peek : 'a t -> 'a

val pop : 'a t -> ('a * 'a t)

val push_front : 'a t -> 'a -> 'a t

val peek_back : 'a t -> 'a

val pop_back : 'a t -> ('a * 'a t)

