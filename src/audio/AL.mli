module ShortData : sig

  type t  

  (** Clears some data *)
  val clear : t -> unit

  (** Append the second array at the end of the first one *)
  val append : t -> t -> unit

  (** Creates some data, the integer must be the expected size *)
  val create : int -> t

  (** Adds an int to the data *)
  val add_int : t -> int -> unit

  (** Returns the data associated to a bigarray *)
  val of_bigarray : (int, Bigarray.int16_signed_elt, Bigarray.c_layout) Bigarray.Array1.t -> t

  (** Returns the length of some data*)
  val length : t -> int

  (** Returns the data at position i (debug only) *)
  val get : t -> int -> int

  (** Iters through data *)
  val iter : t -> (int -> unit) -> unit

  (** Maps through data (without changing its type) *)
  val map : t -> (int -> int) -> t

  (** Debug *)
  val print : t -> unit

end


module ALError : sig

  type t = 
    | NoError
    | InvalidName
    | InvalidEnum
    | InvalidValue
    | InvalidOperation
    | OutOfMemory

end


module ContextError : sig

  type t = 
    | NoError
    | InvalidDevice
    | InvalidContext
    | InvalidEnum
    | InvalidValue
    | OutOfMemory

end


module Pervasives : sig

  val speed_of_sound : float -> unit

  val doppler_factor : float -> unit

  val error : unit -> ALError.t

end


module Device : sig

  type t

  val open_ : string option -> t

  val close : t -> bool

  val error : t -> ContextError.t

end


module Context : sig

  type t

  val create : Device.t -> t

  val make_current : t -> bool

  val process : t -> unit

  val suspend : t -> unit

  val destroy : t -> unit

end


module Listener : sig

  val set_gain : float -> unit

  val set_position : (float * float * float) -> unit

  val set_velocity : (float * float * float) -> unit

  val set_orientation : (float * float * float) -> (float * float * float) -> unit

  val gain : unit -> float

  val position : unit -> (float * float * float)

  val velocity : unit -> (float * float * float)

  val orientation : unit -> ((float * float * float) * (float * float * float))

end


module Buffer : sig

  type t

  type property =
    | Frequency
    | Bits
    | Channels
    | Size

  val create : unit -> t

  val data : t -> ShortData.t -> int -> int -> unit

  val set : t -> property -> int -> unit

  val get : t -> property -> int

end


module Source : sig


end


