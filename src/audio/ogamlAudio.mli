
module AL : sig

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


  end


  module Source : sig


  end

end
