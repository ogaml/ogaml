module ShortData = struct

  type batype = (int, Bigarray.int16_signed_elt, Bigarray.c_layout) Bigarray.Array1.t

  type t = {
    mutable data   : batype;
    mutable size   : int;
    mutable length : int
  }

  let clear d = 
    d.length <- 0

  let create i = 
    let arr = 
      Bigarray.Array1.create 
        Bigarray.int16_signed
        Bigarray.c_layout
        (max i 1)
    in
    {data = arr; size = (max i 4); length = 0}

  let double t = 
    let arr = 
      Bigarray.Array1.create
        Bigarray.int16_signed
        Bigarray.c_layout
        (t.size * 2)
    in
    Bigarray.Array1.sub arr 0 t.size 
    |> Bigarray.Array1.blit t.data;
    t.size <- t.size * 2;
    t.data <- arr

  let rec alloc t i = 
    let space = t.size - t.length in
    if space < i then begin
      double t;
      alloc t i
    end

  let append t1 t2 = 
    let n = t1.length in
    alloc t1 t2.length;
    Bigarray.Array1.sub t1.data n t2.length
    |> Bigarray.Array1.blit t2.data;
    t1.length <- n + t2.length

  let add_int t (i : int) =
    alloc t 1;
    Bigarray.Array1.unsafe_set t.data (t.length) i;
    t.length <- t.length+1

  let of_bigarray m = {
    data = m;
    size = Bigarray.Array1.dim m;
    length = Bigarray.Array1.dim m
  }

  let length t = t.length

  let get t i = t.data.{i}
  
  let iter t f = 
    for i = 0 to t.length - 1 do
      f t.data.{i}
    done

  let map t f = 
    let data = 
      Bigarray.Array1.create 
        Bigarray.int16_signed
        Bigarray.c_layout
        t.size
    in
    let newt = 
      {data; size = t.size; length = t.length}
    in
    for i = 0 to t.length - 1 do
      newt.data.{i} <- (f t.data.{i})
    done;
    newt

  let print t = 
    Printf.printf "[";
    for i = 0 to t.length - 1 do
      Printf.printf "%i; " t.data.{i}
    done;
    Printf.printf "]\n%!"

end


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

  type t

  type property = 
    | Frequency
    | Bits
    | Channels
    | Size

  external create : unit -> t = "caml_al_create_buffer"

  external data : t -> ShortData.t -> int -> int -> unit = "caml_al_buffer_data"

  external set : t -> property -> int -> unit = "caml_al_set_buffer_property"

  external get : t -> property -> int = "caml_al_get_buffer_property"

end


module Source = struct


end


