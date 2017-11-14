open Bigarray

type t = {
  filename  : string;
  decoder   : AL.Vorbis.decoder;
  data_buf  : AL.Vorbis.data;
  duration  : float;
  s_rate    : int;
  channels  : [`Stereo | `Mono];
  temp_buffer : AL.Buffer.t; (* For retrieving buffers in sources *)
  alloc_buffers : AL.Buffer.t list;
  mutable free_buffers : AL.Buffer.t list;
  mutable sample : int;
  mutable source : AudioSource.t option;
  mutable thread : Thread.t option;
}

let load filename = 
  match AL.Vorbis.open_file filename with
  | Ok decoder ->
    let n_channels = max (min (AL.Vorbis.channels decoder) 2) 1 in
    let data_buf = Array1.create int16_signed c_layout (32768 * n_channels) in
    let channels = 
      match n_channels with
      | 1 -> `Mono
      | 2 -> `Stereo
      | _ -> assert false
    in
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
      temp_buffer = AL.Buffer.create ();
      free_buffers = [back_buf; front_buf];
      alloc_buffers = [back_buf; front_buf];
      sample;
      source = None;
      thread = None;
    }
  | Error _ ->
    Error ()

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

let private_end stream = 
  begin match stream.source with
  | None -> ()
  | Some s -> 
    AudioSource.stop s;
    stream.source <- None;
    stream.free_buffers <- stream.alloc_buffers
  end

let detach stream = 
  private_end stream;
  begin match stream.thread with
  | Some thd -> 
    stream.thread <- None;
    Thread.kill thd
  | None -> ()
  end

let stop stream = 
  seek stream 0.0;
  detach stream

let exit stream = 
  private_end stream;
  stream.thread <- None;
  Thread.exit ()

let unqueue_buffers stream llsource = 
  let n_free_bufs = AL.Source.get_i llsource AL.Source.BuffersProcessed in
  for i = 0 to n_free_bufs - 1 do
    let bufid = AL.Source.unqueue_id llsource in
    try 
      let buf = List.find (fun b -> AL.Buffer.id b = bufid) stream.alloc_buffers in
      stream.free_buffers <- buf :: stream.free_buffers
    with
      Not_found -> ()
  done

let decode_buffer stream = 
  match stream.free_buffers with
  | [] -> None
  | buf::tail -> begin
    let n_channels, data_fun = 
      match stream.channels with
      | `Mono -> 1, AL.Buffer.data_mono
      | `Stereo -> 2, AL.Buffer.data_stereo
    in
    let qty = AL.Vorbis.get_samples stream.decoder n_channels stream.data_buf in
    if qty <> 0 then begin
      let data = AL.ShortData.of_bigarray stream.data_buf in
      data_fun buf data (AL.ShortData.length data) stream.s_rate;
      stream.free_buffers <- tail
    end;
    Some (buf, qty)
  end

let fill_push_buffer stream llsource = 
  match decode_buffer stream with
  | None -> None
  | Some (buf, qty) ->
    AL.Source.queue llsource 1 [|buf|];
    Some qty

let play_step stream = 
  match stream.source with
  | None -> 
    exit stream
  | Some src -> begin
    match AudioSource.status src, AudioSource.LL.source src with
    | `Playing, Some llsrc -> begin
      unqueue_buffers stream llsrc;
      match fill_push_buffer stream llsrc with
      | None -> ()
      | Some qty ->
        if qty = 0 && not (AL.Source.playing llsrc) then
          exit stream
    end
    | `Paused, Some _ -> ()
    | _ -> exit stream
  end

let rec loop_play stream =
  play_step stream;
  Thread.delay 0.01;
  loop_play stream

let play ?pitch ?gain ?force ?on_stop
  stream source = 
  match status stream with
  | `Playing | `Paused -> ()
  | `Stopped -> begin
    match decode_buffer stream with
    | None -> ()
    | Some (buffer, _) -> begin
      stream.source <- Some source;
      let thd = 
        Thread.create (fun stream -> 
          AudioSource.LL.play ?pitch ?gain ~loop:false ?force ?on_stop ~duration:infinity 
            ~channels:stream.channels ~buffer ~stream:true source;
          loop_play stream
        ) stream
      in
      stream.thread <- Some thd
    end
  end

