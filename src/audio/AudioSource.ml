open OgamlMath

exception NoSourceAvailable

type t = {
  mutable context     : AudioContext.t ;
  mutable position    : Vector3f.t ;
  mutable velocity    : Vector3f.t ;
  mutable orientation : Vector3f.t ;
  mutable status      : [`Playing | `Stopped | `Paused] ;
  mutable source      : AL.Source.t option
}

let create ?position:(position = Vector3f.zero)
           ?velocity:(velocity = Vector3f.zero)
           ?orientation:(orientation = Vector3f.zero) context = {
  context ;
  position ;
  velocity ;
  orientation ;
  status = `Stopped ;
  source = None
}

(* Utility for options *)
let may f = function
  | None -> ()
  | Some x -> f x

(* Utility for Vector3fs *)
let vec3f v = Vector3f.(v.x, v.y, v.z)

let play source ?pitch ?gain ?loop ?force sound =
  (* We request a source to the context. *)
  match sound with
  | `Stream str -> () (* TODO *)
  | `Sound buff ->
    let source_candidate =
      match SoundBuffer.channels buff with
      | `Stereo ->
        AudioContext.LL.get_available_stereo_source ?force source.context
      | `Mono   ->
        AudioContext.LL.get_available_mono_source ?force source.context
    in
    begin match source_candidate with
    | None -> may (fun b -> if b then raise NoSourceAvailable) force
    | Some s ->
        source.source <- Some s ;
        may (fun p -> AL.Source.set_f s AL.Source.Pitch p) pitch ;
        may (fun g -> AL.Source.set_f s AL.Source.Gain g) gain ;
        may (fun l -> AL.Source.set_i s AL.Source.Looping (if l then 1 else 0))
            loop ;
        AL.Source.set_3f s AL.Source.Position (vec3f source.position) ;
        AL.Source.set_3f s AL.Source.Velocity (vec3f source.velocity) ;
        AL.Source.set_3f s AL.Source.Direction (vec3f source.orientation) ;
        AL.Source.set_buffer s (SoundBuffer.LL.buffer buff) ;
        AL.Source.play s ;
        source.status <- `Playing
    end

let stop source =
  may AL.Source.stop source.source ;
  source.status <- `Stopped

let pause source =
  may AL.Source.pause source.source ;
  source.status <- `Paused

let resume source =
  may AL.Source.play source.source ;
  source.status <- `Playing

let status source = source.status

let position source = source.position

let set_position source pos =
  source.position <- pos ;
  may (fun s -> AL.Source.set_3f s AL.Source.Position (vec3f pos)) source.source

let velocity source = source.velocity

let set_velocity source vel =
  source.velocity <- vel ;
  may (fun s -> AL.Source.set_3f s AL.Source.Velocity (vec3f vel)) source.source

let orientation source = source.orientation

let set_orientation source ori =
  source.orientation <- ori ;
  may
    (fun s -> AL.Source.set_3f s AL.Source.Direction (vec3f source.orientation))
    source.source
