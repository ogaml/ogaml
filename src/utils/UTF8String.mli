
type code = int

type t

exception UTF8_error of string

exception Out_of_bounds of string

val empty : unit -> t

val make : int -> code -> t

val get : t -> int -> code

val set : t -> int -> code -> unit

val length : t -> int

val byte_length : t -> int

val from_string : string -> t

val to_string : t -> string

val iter : t -> (code -> unit) -> unit

val fold : t -> (code -> 'a -> 'a) -> 'a -> 'a

val map : t -> (code -> code) -> t

