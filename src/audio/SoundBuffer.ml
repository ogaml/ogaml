
type t = unit

type samples = (int, Bigarray.int16_signed_elt, Bigarray.c_layout) Bigarray.Array1.t

let load s = ()

let create ~samples ~channels ~rate = ()

let duration buff = 0.

let samples buff = assert false

let channels buff = `Mono

module LL = struct

  let buffer buff = assert false

end
