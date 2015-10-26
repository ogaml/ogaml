open Bigarray

module Data : sig

  type ('a, 'b) t = ('a, 'b, c_layout) Array1.t

  val create : int -> ('a, 'b) kind -> ('a, 'b) t

  val create_float : int -> (float, float32_elt) t

  val create_int : int -> (int32, int32_elt) t

  val size : ('a, 'b) t -> int

end


module VBO : sig

  type t

  val create : unit -> t

  val bind : t option -> unit

  val delete : t -> unit

  val set : t -> ('a, 'b) Data.t -> unit

end




