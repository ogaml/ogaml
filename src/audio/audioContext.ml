open OgamlMath

let cerror fmt =
  Printf.ksprintf (fun s -> Error (`Creation_error s)) fmt

let derror fmt =
  Printf.ksprintf (fun s -> Error (`Destruction_error s)) fmt

type t =
  {
    mutable position : Vector3f.t;
    mutable velocity : Vector3f.t;
    mutable look_at  : Vector3f.t;
    mutable up_dir   : Vector3f.t;
    device : AL.Device.t;
    context : AL.Context.t;
    max_s_sources : int;
    max_m_sources : int;
    mutable n_s_sources : int;
    mutable n_m_sources : int;
    mutable s_sources : (float * float * AL.Source.t * (unit -> unit)) list;
    mutable m_sources : (float * float * AL.Source.t * (unit -> unit)) list;
    mutable all_sources : AL.Source.t list
  }

let create
    ?position:(position = Vector3f.zero)
    ?velocity:(velocity = Vector3f.zero)
    ?look_at:(look_at = Vector3f.({x = 0.; y = 0.; z = -1.}))
    ?up_dir:(up_dir = Vector3f.unit_y) () =
  let device = AL.Device.open_ None in
  let context = AL.Context.create device in
  if not (AL.Context.make_current context) then begin
    match AL.Device.error device with
    | AL.ContextError.NoError ->
      cerror "Error associating OpenAL context"
    | e ->
      cerror "Error associating OpenAL context : %s" (AL.ContextError.to_string e)
  end else begin
    let max_m_sources, max_s_sources =
      AL.Device.max_mono_sources device,
      AL.Device.max_stereo_sources device
    in
    AL.Listener.set_position Vector3f.(position.x, position.y, position.z);
    AL.Listener.set_velocity Vector3f.(velocity.x, velocity.y, velocity.z);
    AL.Listener.set_orientation
      Vector3f.(look_at.x, look_at.y, look_at.z)
      Vector3f.(up_dir.x, up_dir.y, up_dir.z);
    Ok {
      position;
      velocity;
      look_at;
      up_dir;
      device;
      context;
      max_m_sources;
      max_s_sources;
      n_s_sources = 0;
      n_m_sources = 0;
      s_sources = [];
      m_sources = [];
      all_sources = []
    }
  end

let destroy t =
  if not (AL.Context.remove_current ()) then begin
    match AL.Device.error t.device with
    | AL.ContextError.NoError ->
      derror "Error detaching OpenAL context"
    | e ->
      derror "Error detaching OpenAL context : %s" (AL.ContextError.to_string e)
  end
  else begin
    AL.Context.destroy t.context;
    if not (AL.Device.close t.device) then begin
      match AL.Device.error t.device with
      | AL.ContextError.NoError ->
        derror "Error closing OpenAL device"
      | e ->
        derror "Error closing OpenAL device : %s" (AL.ContextError.to_string e)
    end
    else Ok ()
  end

let position t =
  t.position

let set_position t p =
  if p <> t.position then begin
    t.position <- p;
    AL.Listener.set_position Vector3f.(p.x, p.y, p.z);
  end

let velocity t =
  t.velocity

let set_velocity t v =
  if v <> t.velocity then begin
    t.velocity <- v;
    AL.Listener.set_velocity Vector3f.(v.x, v.y, v.z);
  end

let look_at t =
  t.look_at

let set_look_at t v =
  if v <> t.look_at then begin
    t.look_at <- v;
    AL.Listener.set_orientation
      Vector3f.(v.x, v.y, v.z)
      Vector3f.(t.up_dir.x, t.up_dir.y, t.up_dir.z)
  end

let up_dir t =
  t.up_dir

let set_up_dir t v =
  if v <> t.up_dir then begin
    t.up_dir <- v;
    AL.Listener.set_orientation
      Vector3f.(t.look_at.x, t.look_at.y, t.look_at.z)
      Vector3f.(v.x, v.y, v.z)
  end

let max_stereo_sources t =
  t.max_s_sources

let max_mono_sources t =
  t.max_m_sources

let has_stereo_source_available t =
  let time = Unix.gettimeofday () in
  let reuse_available =
    match t.s_sources with
    | [] -> false
    | (start, dur, _, _) :: _ -> start +. dur < time
  in
  (t.n_s_sources < t.max_s_sources) || reuse_available

let has_mono_source_available t =
  let time = Unix.gettimeofday () in
  let reuse_available =
    match t.m_sources with
    | [] -> false
    | (start, dur, _, _) :: _ -> start +. dur < time
  in
  (t.n_m_sources < t.max_m_sources) || reuse_available

module LL = struct

  let get_available_stereo_source ?force:(force = false) t =
    let time = Unix.gettimeofday () in
    match t.s_sources with
    | [] when t.n_s_sources < t.max_s_sources ->
      let new_source =
        AL.Source.create ()
      in
      t.n_s_sources <- t.n_s_sources + 1;
      t.all_sources <- new_source :: t.all_sources;
      Some new_source
    | [] ->
      None
    | (start, dur, src, cbk)::tail ->
      if start +. dur < time then begin
        t.s_sources <- tail;
        cbk ();
        Some src
      end else if t.n_s_sources < t.max_s_sources then begin
        let new_source =
          AL.Source.create ()
        in
        t.n_s_sources <- t.n_s_sources + 1;
        t.all_sources <- new_source :: t.all_sources;
        Some new_source
      end else if force then begin
        t.s_sources <- tail;
        cbk ();
        Some src
      end else
        None

  let get_available_mono_source ?force:(force = false) t =
    let time = Unix.gettimeofday () in
    match t.m_sources with
    | [] when t.n_m_sources < t.max_m_sources ->
      let new_source =
        AL.Source.create ()
      in
      t.n_m_sources <- t.n_m_sources + 1;
      t.all_sources <- new_source :: t.all_sources;
      Some new_source
    | [] ->
      None
    | (start, dur, src, cbk)::tail ->
      if start +. dur < time then begin
        t.m_sources <- tail;
        cbk ();
        Some src
      end else if t.n_m_sources < t.max_m_sources then begin
        let new_source =
          AL.Source.create ()
        in
        t.n_m_sources <- t.n_m_sources + 1;
        t.all_sources <- new_source :: t.all_sources;
        Some new_source
      end else if force then begin
        t.m_sources <- tail;
        cbk ();
        Some src
      end else
        None

  let allocate_stereo_source t source dur cbk =
    let time = Unix.gettimeofday () in
    let rec insert = function
      | [] -> [(time, dur, source, cbk)]
      | ((start, duration, _, _)::tail) as l when time +. dur < start +. duration ->
        (time, dur, source, cbk) :: l
      | e::tail ->
        e::(insert tail)
    in
    t.s_sources <- insert t.s_sources

  let allocate_mono_source t source dur cbk =
    let time = Unix.gettimeofday () in
    let rec insert = function
      | [] -> [(time, dur, source, cbk)]
      | ((start, duration, _, _)::tail) as l when time +. dur < start +. duration ->
        (time, dur, source, cbk) :: l
      | e::tail ->
        e::(insert tail)
    in
    t.m_sources <- insert t.m_sources

  let reallocate_stereo_source t source dur =
    let rec find_remove = function
      | [] -> assert false
      | (_,_,src,cbk)::tail when src==source -> (cbk, tail)
      | e::tail ->
        let (cbk, tail) = find_remove tail in
        (cbk, e::tail)
    in
    let (cbk, ls) = find_remove t.s_sources in
    t.s_sources <- ls;
    allocate_stereo_source t source dur cbk

  let reallocate_mono_source t source dur =
    let rec find_remove = function
      | [] -> assert false
      | (_,_,src,cbk)::tail when src==source -> (cbk, tail)
      | e::tail ->
        let (cbk, tail) = find_remove tail in
        (cbk, e::tail)
    in
    let (cbk, ls) = find_remove t.m_sources in
    t.m_sources <- ls;
    allocate_mono_source t source dur cbk

  let deallocate_stereo_source t source =
    let rec find_remove = function
      | [] -> assert false
      | (_,_,src,_)::tail when src==source -> tail
      | e::tail -> e::(find_remove tail)
    in
    t.s_sources <- (0., 0., source, (fun () -> ()))::(find_remove t.s_sources)

  let deallocate_mono_source t source =
    let rec find_remove = function
      | [] -> assert false
      | (_,_,src,_)::tail when src==source -> tail
      | e::tail -> e::(find_remove tail)
    in
    t.m_sources <- (0., 0., source, (fun () -> ()))::(find_remove t.m_sources)

end
