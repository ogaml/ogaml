type t = {
  filename  : string;
  decoder   : AL.Vorbis.decoder;
  data_buf  : AL.Vorbis.data;
  duration  : float;
  s_rate    : int;
  mutable back_buf  : AL.Buffer.t;
  mutable front_buf : AL.Buffer.t;
  mutable frame     : int;
  mutable source    : AudioSource.t option
}

let load filename = assert false

let play ?pitch ?gain ?loop ?force ?on_stop
  stream source = assert false

let duration stream = assert false

let seek stream pos = assert false

let current stream = assert false

let pause stream = assert false

let resume stream = assert false

let status stream = assert false

let detach stream = assert false

let attach stream source = assert false

let stop stream = assert false
