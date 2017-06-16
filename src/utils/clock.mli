
type t

val create : unit -> t

val restart : t -> unit

val tick : t -> unit

val time : t -> float

val ticks : t -> int

val tps : t -> float

val spt : t -> float

