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

  val to_string : t -> string

end


module ContextError : sig

  type t = 
    | NoError
    | InvalidDevice
    | InvalidContext
    | InvalidEnum
    | InvalidValue
    | OutOfMemory

  val to_string : t -> string

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

  val max_mono_sources : t -> int

  val max_stereo_sources : t -> int

end


module Context : sig

  type t

  val create : Device.t -> t

  val make_current : t -> bool

  val remove_current : unit -> bool

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

  (** [data_mono buf data n rate] stores the [n] samples [data] in [buf],
    * assuming a sample rate/frequency of [rate] *)
  val data_mono : t -> ShortData.t -> int -> int -> unit

  val data_stereo : t -> ShortData.t -> int -> int -> unit

  val set : t -> property -> int -> unit

  val get : t -> property -> int

end


module Source : sig

  type t

  type property_f =
    | Pitch
    | Gain
    | MaxDistance
    | RolloffFactor
    | ReferenceDistance
    | MinGain
    | MaxGain
    | ConeOuterGain
    | ConeInnerAngle
    | ConeOuterAngle
    | SecOffset
    | SampleOffset
    | ByteOffset

  type property_3f =
    | Position
    | Velocity
    | Direction

  type property_i =
    | SourceRelative
    | SourceType
    | Looping
    | SourceState
    | BuffersQueued
    | BuffersProcessed

  val create : unit -> t

  val set_f : t -> property_f -> float -> unit

  val set_3f : t -> property_3f -> (float * float * float) -> unit

  val set_i : t -> property_i -> int -> unit

  val set_buffer : t -> Buffer.t -> unit

  val get_f : t -> property_f -> float

  val get_3f : t -> property_3f -> (float * float * float)

  val get_i : t -> property_i -> int 

  val play : t -> unit

  val pause : t -> unit

  val stop : t -> unit

  val rewind : t -> unit

  val queue : t -> int -> Buffer.t array -> unit

  val unqueue : t -> int -> unit

end


