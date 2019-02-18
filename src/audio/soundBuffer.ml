open OgamlUtils.Result.Operators

type samples = (int, Bigarray.int16_signed_elt, Bigarray.c_layout) Bigarray.Array1.t

type t = {
  buffer   : AL.Buffer.t ;
  duration : float ;
  samples  : samples ;
  channels : [`Stereo | `Mono]
}

let create ~samples ~channels ~rate =
  let buffer = AL.Buffer.create () in
  let data = AL.ShortData.of_bigarray samples in
  begin match channels with
  | `Stereo -> AL.Buffer.data_stereo
  | `Mono   -> AL.Buffer.data_mono
  end buffer data (AL.ShortData.length data) rate ;
  let duration =
    let mondur = float_of_int (AL.ShortData.length data) /. float_of_int rate in
    match channels with
    | `Stereo -> mondur /. 2.
    | `Mono   -> mondur
  in
  { buffer ; duration ; samples ; channels }

let load s =
  if (not (Sys.file_exists s)) || (Sys.is_directory s) then
    Error (`FileNotFound s)
  else begin
    let (channels_nb, rate, samples) = AL.Vorbis.decode_file s in
    let channels =
      match channels_nb with
      | 1 -> Ok `Mono
      | 2 -> Ok `Stereo
      | _ -> Error `UnsupportedNumberOfChannels
    in
    channels >>= fun channels ->
    let sound = create ~samples ~rate ~channels in
    AL.Vorbis.free_data samples;
    Ok sound
  end

let play ?pitch ?gain ?loop ?force ?on_stop buff source =
  AudioSource.LL.play
    ?pitch
    ?gain
    ?loop
    ?force
    ?on_stop
    ~duration:buff.duration
    ~channels:buff.channels
    ~buffer:buff.buffer
    ~stream:false
    source

let duration buff = buff.duration

let samples buff = buff.samples

let channels buff = buff.channels
