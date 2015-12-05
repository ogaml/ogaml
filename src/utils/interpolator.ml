
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

let append_times b l e = 
  let dist = distance b l e in
  let rec times_aux b l acc =
    match l with
    |[] -> []
    |h::t -> 
      let new_acc = acc +. (abs_float (h -. b)) in
      let time = 
        if dist = 0. then 0. 
        else new_acc /. dist 
      in
      (time, h) :: (times_aux h t new_acc)
  in
  times_aux b l 0.

let rec append_tangents pb tb l pe = 
  match l with
  |[] -> []
  |[(t, pos)] -> 
    let mk = (pe -. pos)/.(2.*.(1. -. t)) -. (pos -. pb)/.(2.*.(t -. tb)) in
    [t,(pos,mk)]
  |(t1,pos1)::(t2,pos2)::tail -> 
    let mk = (pos2 -. pos1)/.(2.*.(t2 -. t1)) -. (pos1 -. pb)/.(2.*.(t1 -. tb)) in
    (t1,(pos1,mk))::(append_tangents pos1 t1 ((t2,pos2)::tail) pe)

let points b l e t = 
  let rec points_aux b l = 
    match l with
    |[] -> (b, (1.,e))
    |(cur_t, pt)::_ when t <= cur_t -> (b, (cur_t, pt))
    |h::tail -> points_aux h tail
  in
  points_aux (0.,b) l

let h00 t = 2. *. t *. t *. t -. 3. *. t *. t +. 1.

let h10 t = t *. t *. t -. 2. *. t *. t +. t

let h01 t = -. 2. *. t *. t *. t +. 3. *. t *. t

let h11 t = t *. t *. t -. t *. t

let linear b l e =
  let func = fun t ->
    let (t1, p1), (t2, p2) = points b l e t in
    let fact = 
      if t2 = t1 then 1.
      else (t -. t1) /. (t2 -. t1) 
    in
    (1. -. fact) *. p1 +. fact *. p2
  in
  custom func

let cst_linear b l e = 
  linear b (append_times b l e) e

let cubic b l e = 
  let l' = append_tangents (fst b) 0. l (fst e) in
  let func = fun t -> 
    let (_, (p1, tg1)), (_, (p2, tg2)) = points b l' e t in
    (h00 t) *. p1 +. (h10 t) *. tg1 +. (h01 t) *. p2 +. (h11 t) *. tg2
  in
  custom func

let cst_cubic b l e = 
  cubic b (append_times (fst b) l (fst e)) e

let compose ip1 ip2 = {
  ip1 with func = fun t -> ip2.func (ip1.func t)
}

let map ip f = {
  ip with func = fun t -> f (ip.func t)
}

let map_right = map

let map_left f ip =
  fun a -> ip.func (f a)

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



