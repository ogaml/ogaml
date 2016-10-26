
module Device = struct

  type t

  external open_ : string option -> t = "caml_alc_open_device"

  external close : t -> bool = "caml_alc_close_device"

end


module Context = struct


end


module Listener = struct


end


module Buffer = struct


end


module Source = struct


end


