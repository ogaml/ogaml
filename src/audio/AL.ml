
module ALError = struct

  type t = 
    | NoError
    | InvalidName
    | InvalidEnum
    | InvalidValue
    | InvalidOperation
    | OutOfMemory

end


module ContextError = struct

  type t = 
    | NoError
    | InvalidDevice
    | InvalidContext
    | InvalidEnum
    | InvalidValue
    | OutOfMemory

end


module Pervasives = struct

  external speed_of_sound : float -> unit = "caml_speed_of_sound"

  external doppler_factor : float -> unit = "caml_doppler_factor"

  external error : unit -> ALError.t = "caml_al_error"

end


module Device = struct

  type t

  external open_ : string option -> t = "caml_alc_open_device"

  external close : t -> bool = "caml_alc_close_device"

  external error : t -> ContextError.t = "caml_alc_error"

end


module Context = struct

  type t

  external create : Device.t -> t = "caml_alc_create_context"

  external make_current : t -> bool = "caml_alc_make_current_context"

  external process : t -> unit = "caml_alc_process_context"

  external suspend : t -> unit = "caml_alc_suspend_context"

  external destroy : t -> unit = "caml_alc_destroy_context"

end


module Listener = struct

  external set_gain : float -> unit = "caml_alc_set_gain"

  external set_position : (float * float * float) -> unit = "caml_alc_set_position"

  external set_velocity : (float * float * float) -> unit = "caml_alc_set_velocity"

  external set_orientation : (float * float * float) -> (float * float * float) -> unit
    = "caml_alc_set_orientation"

  external gain : unit -> float = "caml_alc_get_gain"

  external position : unit -> (float * float * float) = "caml_alc_get_position"

  external velocity : unit -> (float * float * float) = "caml_alc_get_velocity"

  external orientation : unit -> ((float * float * float) * (float * float * float))
    = "caml_alc_get_orientation"

end


module Buffer = struct


end


module Source = struct


end


