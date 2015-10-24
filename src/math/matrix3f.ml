
type t = (float, Bigarray.float32_elt, Bigarray.c_layout) Bigarray.Array1.t

let get i j m = m.{i + j*4} (* column major order *)

let set i j m v = m.{i + j*4} <- v
