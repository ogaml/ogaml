
type t = {
  context     : AudioContext.t ;
  position    : OgamlMath.Vector3f.t option ;
  velocity    : OgamlMath.Vector3f.t option ;
  orientation : OgamlMath.Vector3f.t option ;
  status      : [`Playing | `Stopped | `Paused] ;
  source      : AL.Source.t option
}

let create ?position ?velocity ?orientation context = {
  context ; position ; velocity ; orientation ;
  status = `Stopped ;
  source = None
}

let play source ?pitch ?gain ?loop ?force sound =
  (* We request a source to the context. *)
  (* TODO: Choose between mono and stereo based on sound *)
  match sound with
  | `Stream str -> ()
  | `Sound buff ->
    begin match AudioContext.LL.get_available_mono_source ~force source with
    | None -> ()
    | Some s ->
        source.source := s ;
        begin match pitch with
        | Some p -> AL.Source.set_f AL.Source.Pitch p
        | None -> ()
        end ;
        begin match gain with
        | Some g -> AL.Source.set_f AL.Source.Gain g
        | None -> ()
        end ;
        begin match loop with
        | Some l -> AL.Source.set_i AL.Source.Looping l
        | None -> ()
        end ;
        let vec3f v = OgamlMath.Vector3f.(v.x, v.y, v.z) in
        begin match source.position with
        | Some p -> AL.Source.set_3f AL.Source.Position (vec3f p)
        | None -> ()
        end ;
        begin match source.velocity with
        | Some p -> AL.Source.set_3f AL.Source.Velocity (vec3f p)
        | None -> ()
        end ;
        begin match source.orientation with
        | Some p -> AL.Source.set_3f AL.Source.Direction (vec3f p)
        | None -> ()
        end ;
        AL.Source.set_buffer s (SoundBuffer.LL.buffer buff) ;
        AL.Source.play s ;
        source.status := `Playing
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
