
type samples = (int, Bigarray.int16_signed_elt, Bigarray.c_layout) Bigarray.Array1.t

type t = {
  buffer   : AL.Buffer.t ;
  duration : float ;
  samples  : samples ;
  channels : [`Stereo | `Mono]
}

let load s = assert false

let create ~samples ~channels ~rate =
  let buffer = AL.Buffer.create () in
  let data = AL.ShortData.of_bigarray samples in
  begin match channels with
  | `Stereo -> AL.Buffer.data_stereo
  | `Mono   -> AL.Buffer.data_mono
  end buffer data (AL.ShortData.length data) rate ;
  let size = AL.Buffer.get buffer AL.Buffer.Size in
  let duration =
    let mondur = float_of_int size /. float_of_int rate in
    match channels with
    | `Stereo -> mondur /. 2.
    | `Mono   -> mondur
  in
  { buffer ; duration ; samples ; channels }

let duration buff = buff.duration

let samples buff = buff.samples

let channels buff = buff.channels

module LL = struct

  let buffer buff = buff.buffer

end
