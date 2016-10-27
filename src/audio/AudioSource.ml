open OgamlMath

type t = {
  context     : AudioContext.t ;
  position    : Vector3f.t ;
  velocity    : Vector3f.t ;
  orientation : Vector3f.t ;
  mutable status : [`Playing | `Stopped | `Paused] ;
  mutable source : AL.Source.t option
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

let play source ?pitch ?gain ?loop ?force sound =
  (* We request a source to the context. *)
  (* TODO: Choose between mono and stereo based on sound *)
  match sound with
  | `Stream str -> ()
  | `Sound buff ->
    begin match AudioContext.LL.get_available_mono_source ?force source.context with
    | None -> ()
    | Some s ->
        source.source <- Some s;
        begin match pitch with
        | Some p -> AL.Source.set_f s AL.Source.Pitch p
        | None -> ()
        end ;
        begin match gain with
        | Some g -> AL.Source.set_f s AL.Source.Gain g
        | None -> ()
        end ;
        begin match loop with
        | Some l -> AL.Source.set_i s AL.Source.Looping (if l then 1 else 0)
        | None -> ()
        end ;
        let vec3f v = OgamlMath.Vector3f.(v.x, v.y, v.z) in
        AL.Source.set_3f s AL.Source.Position (vec3f source.position);
        AL.Source.set_3f s AL.Source.Velocity (vec3f source.velocity);
        AL.Source.set_3f s AL.Source.Direction (vec3f source.orientation);
        AL.Source.set_buffer s (SoundBuffer.LL.buffer buff) ;
        AL.Source.play s ;
        source.status <- `Playing
    end

let stop source = ()

let pause source = ()

let resume source = ()

let status source = source.status

let position source = source.position

let set_position source pos = ()

let velocity source = source.velocity

let set_velocity source vel = ()

let orientation source = source.orientation

let set_orientation source ori = ()
