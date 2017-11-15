type 'a t

val empty : 'a t

val is_empty : 'a t -> bool

val singleton : 'a -> 'a t

val push : 'a t -> 'a -> 'a t

val peek : 'a t -> ('a, unit) result

val pop : 'a t -> ('a * 'a t, unit) result

val push_front : 'a t -> 'a -> 'a t

val peek_back : 'a t -> ('a, unit) result

val pop_back : 'a t -> ('a * 'a t, unit) result

