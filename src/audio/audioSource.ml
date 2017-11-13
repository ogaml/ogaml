open OgamlMath

exception NoSourceAvailable

type t = {
  mutable context     : AudioContext.t ;
  mutable position    : Vector3f.t ;
  mutable velocity    : Vector3f.t ;
  mutable orientation : Vector3f.t ;
  mutable status      : [`Playing | `Stopped | `Paused] ;
  mutable source      : AL.Source.t option;
  mutable channels    : [`Mono | `Stereo];
  mutable duration    : float;
  mutable start       : float;
  mutable on_stop      : unit -> unit
}

let create ?position:(position = Vector3f.zero)
           ?velocity:(velocity = Vector3f.zero)
           ?orientation:(orientation = Vector3f.zero) context = {
  context ;
  position ;
  velocity ;
  orientation ;
  status = `Stopped ;
  source = None ;
  channels = `Mono ;
  duration = 0. ;
  start = 0. ;
  on_stop = (fun () -> ())
}

(* Utility for options *)
let may f = function
  | None -> ()
  | Some x -> f x

(* Utility for Vector3fs *)
let vec3f v = Vector3f.(v.x, v.y, v.z)

let allocate_source source force channels duration =
  match source.source with
  | None -> begin
    let src_candidate = 
      match channels with
      | `Stereo ->
        AudioContext.LL.get_available_stereo_source ~force source.context
      | `Mono ->
        AudioContext.LL.get_available_mono_source ~force source.context
    in
    match src_candidate with
    | None when force -> raise NoSourceAvailable
    | None -> ()
    | Some s -> begin
      source.source <- Some s;
      match channels with
      | `Stereo ->
        AudioContext.LL.allocate_stereo_source source.context s duration
          (fun () -> source.source <- None)
      | `Mono ->
        AudioContext.LL.allocate_mono_source source.context s duration
          (fun () -> source.source <- None)
    end
  end
  | Some s -> begin
    match channels with
    | `Stereo ->
      AudioContext.LL.reallocate_stereo_source source.context s duration
    | `Mono ->
      AudioContext.LL.reallocate_mono_source source.context s duration
  end

let stop source =
  may AL.Source.stop source.source ;
  begin match source.channels with
  | `Mono -> may (AudioContext.LL.deallocate_mono_source source.context) source.source;
  | `Stereo -> may (AudioContext.LL.deallocate_stereo_source source.context) source.source;
  end;
  source.source <- None;
  source.status <- `Stopped;
  source.on_stop ()

let update_status source = 
  match source.status with
  | `Playing ->
    if Unix.gettimeofday () -. source.start >= source.duration then begin
      stop source;
    end
  | _ -> ()

let status source = 
  update_status source; 
  source.status

let pause source =
  match source.source with
  | Some s when status source = `Playing ->
    AL.Source.pause s;
    source.status <- `Paused;
    begin match source.channels with
    | `Mono -> AudioContext.LL.reallocate_mono_source source.context s infinity
    | `Stereo -> AudioContext.LL.reallocate_stereo_source source.context s infinity
    end;
    source.duration <- source.duration -. (Unix.gettimeofday () -. source.start);
  | _ -> ()

let resume source =
  match source.source with
  | Some s when status source = `Paused -> 
    begin match source.channels with
    | `Mono -> AudioContext.LL.reallocate_mono_source source.context s source.duration
    | `Stereo -> AudioContext.LL.reallocate_stereo_source source.context s source.duration
    end;
    AL.Source.play s;
    AL.Source.set_3f s AL.Source.Position (vec3f source.position);
    AL.Source.set_3f s AL.Source.Velocity (vec3f source.velocity);
    AL.Source.set_3f s AL.Source.Direction (vec3f source.orientation);
    source.status <- `Playing;
    source.start <- Unix.gettimeofday ()
  | _ -> ()

let position source = source.position

let set_position source pos =
  source.position <- pos ;
  match status source with
  | `Playing ->
    may
      (fun s -> AL.Source.set_3f s AL.Source.Position (vec3f pos))
      source.source
  | _ -> ()

let velocity source = source.velocity

let set_velocity source vel =
  source.velocity <- vel ;
  match status source with
  | `Playing ->
    may
      (fun s -> AL.Source.set_3f s AL.Source.Velocity (vec3f vel))
      source.source
  | _ -> ()

let orientation source = source.orientation

let set_orientation source ori =
  source.orientation <- ori ;
  match status source with
  | `Playing ->
    may
      (fun s -> AL.Source.set_3f s AL.Source.Direction (vec3f ori))
      source.source
  | _ -> ()

module LL = struct

  let play ?pitch ?gain ?loop ?(force = false) ?(on_stop = fun () -> ()) 
    ~duration ~channels ~buffer source = 
    let src_status = status source in
    (* We request a source to the context. *)
    match src_status with
    | `Stopped ->
      allocate_source source force channels duration;
      begin match source.source with
      | None -> ()
      | Some s ->
          may (fun p -> AL.Source.set_f s AL.Source.Pitch p) pitch ;
          may (fun g -> AL.Source.set_f s AL.Source.Gain g) gain ;
          may (fun l -> AL.Source.set_i s AL.Source.Looping (if l then 1 else 0))
              loop ;
          AL.Source.set_3f s AL.Source.Position (vec3f source.position) ;
          AL.Source.set_3f s AL.Source.Velocity (vec3f source.velocity) ;
          AL.Source.set_3f s AL.Source.Direction (vec3f source.orientation) ;
          AL.Source.set_buffer s buffer ;
          AL.Source.play s ;
          source.duration <- duration ;
          source.status <- `Playing ;
          source.channels <- channels ;
          source.start <- Unix.gettimeofday () ;
          source.on_stop <- on_stop
        end
      | _ -> ()

end
