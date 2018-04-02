val make : ?result:'a -> 'b -> ('a, 'b) result

val (||>) : 'a -> ('b -> 'a -> 'c) -> ('b -> 'c)

val bind : ('a, 'b) result -> ('a -> ('c, 'b) result) -> ('c, 'b) result

val (>>=) : ('a, 'b) result -> ('a -> ('c, 'b) result) -> ('c, 'b) result

val apply : ('a, 'b) result -> ('a -> 'c) -> ('c, 'b) result

val (>>>=) : ('a, 'b) result -> ('a -> 'c) -> ('c, 'b) result

val assert_ok : ('a, 'b) result -> 'a

val throw : ('a, exn) result -> 'a

val catch : ('a -> 'b) -> 'a -> ('b, exn) result

val handle : ('a, 'b) result -> ('b -> 'a) -> 'a

val handle_r : ('b -> 'a) -> ('a, 'b) result -> 'a

val iter : ('a -> (unit, 'b) result) -> 'a list -> (unit, 'b) result

val map : ('a -> ('b, 'c) result) -> 'a list -> ('b list, 'c) result

val fold : ('a -> 'b -> ('a, 'c) result) -> 'a -> 'b list -> ('a, 'c) result

val fold_r : ('a -> 'b -> ('b, 'c) result) -> 'a list -> 'b -> ('b, 'c) result

val opt : ('a, 'b) result -> 'a option

val from_opt : 'a option -> ('a, unit) result
