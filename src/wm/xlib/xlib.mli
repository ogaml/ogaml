type t

external screen_size    : t -> int -> (int * int) = "caml_xscreen_size"

external screen_size_mm : t -> int -> (int * int) = "caml_xscreen_sizemm"

val create : ?hostname:string -> ?display:int -> ?screen:int -> unit -> t

