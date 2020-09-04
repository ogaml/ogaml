
type code = int

type t

val empty : unit -> t

val make : int -> code -> (t, [> `Invalid_UTF8_code]) result

val get : t -> int -> (code, [> `Out_of_bounds]) result

val set : t -> int -> code -> (unit, [> `Out_of_bounds | `Invalid_UTF8_code]) result

val length : t -> int

val byte_length : t -> int

val from_string : string -> (t, [> `Invalid_UTF8_bytes | `Invalid_UTF8_leader]) result

val to_string : t -> string

val iter : t -> (code -> unit) -> unit

val fold : t -> (code -> 'a -> 'a) -> 'a -> 'a

val map : t -> (code -> code) -> (t, [> `Invalid_UTF8_code]) result

