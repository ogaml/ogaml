
type 'a t = {
  func : float -> 'a;
  start : float;
  duration : float
}

exception Invalid_interpolator of string

let mod_neg t =
  let vt = mod_float t 1. in
  if vt < 0. then vt +. 1.
  else vt

let mod_neg2 t = 
  let vt = mod_float t 2. in
  if vt < 0. then 2. +. vt
  else if vt > 1. then 2. -. vt
  else vt

let clamp t = min (max t 0.) 1.

let get ip t = ip.func t

let current ip = 
  let dt = (Unix.gettimeofday () -. ip.start) /. ip.duration in
  if ip.duration = 0. then get ip dt
  else get ip 0.

let start ip t dt = 
  {ip with start = t; duration = dt}

let repeat ip = {
  ip with func = fun t -> ip.func (mod_neg t)
}

let loop ip = {
  ip with func = fun t -> ip.func (mod_neg2 t)
}

let custom f = {
  func = (fun t -> f (clamp t));
  start = 0.;
  duration = 0.
}

let copy f = {
  func = f;
  start = 0.;
  duration = 0.
}

let constant f = {
  func = (fun t -> f);
  start = 0.;
  duration = 0.
}

let rec distance b l e =
  match l with
  |[] -> abs_float (e -. b)
  |h::t -> abs_float (h -. b) +. (distance h t e)

let times b l e = 
  let dist = distance b l e in
  let rec times_aux b l acc =
    match l with
    |[] -> []
    |h::t -> 
      let new_acc = acc +. (abs_float (h -. b)) in
      (new_acc /. dist, h) :: (times_aux h t new_acc)
  in
  times_aux b l 0.

let linear b l e = constant 0.

let cst_linear b l e = 
  linear b (times b l e) e

let quadratic b l e = constant 0.

let cst_quadratic b l e = 
  quadratic b (times b l e) e

let cubic b l e = constant 0.

let cst_cubic b l e =
  cubic b (times b l e) e

let compose ip1 ip2 = {
  ip1 with func = fun t -> ip2.func (ip1.func t)
}

let map ip f = {
  ip with func = fun t -> f (ip.func t)
}

let pair ip1 ip2 = {
  func = (fun t -> (ip1.func t, ip2.func t));
  start = 0.;
  duration = 0.
}

let collapse ipl = {
  func = (fun t -> List.map (fun ip -> ip.func t) ipl);
  start = 0.;
  duration = 0.
}

let vector3f ip1 ip2 ip3 = {
  func = (fun t -> OgamlMath.Vector3f.({x = ip1.func t; y = ip2.func t; z = ip3.func t}));
  start = 0.;
  duration = 0.
}

let vector2f ip1 ip2 = {
  func = (fun t -> OgamlMath.Vector2f.({x = ip1.func t; y = ip2.func t}));
  start = 0.;
  duration = 0.
}



