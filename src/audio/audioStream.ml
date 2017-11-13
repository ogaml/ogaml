open Bigarray

type t = {
  filename  : string;
  decoder   : AL.Vorbis.decoder;
  data_buf  : AL.Vorbis.data;
  duration  : float;
  s_rate    : int;
  channels  : int;
  mutable back_buf  : AL.Buffer.t;
  mutable front_buf : AL.Buffer.t;
  mutable sample    : int;
  mutable source    : AudioSource.t option;
  mutable thread    : Thread.t option;
  lock : Mutex.t
}

let load filename = 
  match AL.Vorbis.open_file filename with
  | Ok decoder ->
    let channels = min (AL.Vorbis.channels decoder) 2 in
    let data_buf = Array1.create int16_signed c_layout (4096 * channels) in
    let samples = AL.Vorbis.stream_length_samples decoder in
    let s_rate = AL.Vorbis.sample_rate decoder in
    let duration = (float_of_int samples /. float_of_int s_rate) in
    let back_buf = AL.Buffer.create () in
    let front_buf = AL.Buffer.create () in
    let sample = 0 in
    AL.Vorbis.seek_frame decoder 0;
    Ok {
      filename;
      decoder;
      data_buf;
      duration;
      s_rate;
      channels;
      back_buf;
      front_buf;
      sample;
      source = None;
      thread = None;
      lock = Mutex.create ()
    }
  | Error _ ->
    Error ()

let play ?pitch ?gain ?loop ?force ?on_stop
  stream source = 
  let thd = 
    Thread.create (fun () ->
      ()
    ) ()
  in
  stream.thread <- Some thd

let duration stream = 
  stream.duration

let seek stream pos = 
  AL.Vorbis.seek_frame stream.decoder 
    (int_of_float (pos *. (float_of_int stream.s_rate)))

let current stream = 
  (float_of_int stream.sample) /. (float_of_int stream.s_rate)

let pause stream = 
  match stream.source with
  | None -> ()
  | Some s ->
    AudioSource.pause s

let resume stream = 
  match stream.source with
  | None -> ()
  | Some s ->
    AudioSource.resume s

let status stream = 
  match stream.source with
  | None -> `Stopped
  | Some s ->
    AudioSource.status s

let detach stream =
  match stream.source with
  | None -> ()
  | Some s -> 
    AudioSource.stop s;
    stream.source <- None

let stop stream = 
  detach stream;
  seek stream 0.0
