type t = {r : float; i : float; j : float; k : float}

let zero = {r = 0.; i = 0.; j = 0.; k = 0.}

let one = {r = 1.; i = 0.; j = 0.; k = 0.}

let real r = {r; i = 0.; j = 0.; k = 0.}

let add q1 q2 = {
  r = q1.r +. q2.r;
  i = q1.i +. q2.i;
  j = q1.j +. q2.j;
  k = q1.k +. q2.k}

let times q1 q2 = {
  r = q1.r *. q2.r -. q1.i *. q2.i -. q1.j *. q2.j -. q1.k *. q2.k;
  i = q1.r *. q2.i +. q1.i *. q2.r +. q1.j *. q2.k -. q1.k *. q2.j;
  j = q1.r *. q2.j +. q1.j *. q2.r +. q1.k *. q2.i -. q1.i *. q2.k;
  k = q1.r *. q2.k +. q1.k *. q2.r +. q1.i *. q2.j -. q1.j *. q2.i}

let prop p q1 = {
  r = p *. q1.r;
  i = p *. q1.i;
  j = p *. q1.j;
  k = p *. q1.k}

let sub q1 q2 = {
  r = q1.r -. q2.r;
  i = q1.i -. q2.i;
  j = q1.j -. q2.j;
  k = q1.k -. q2.k}

let rotation v theta = 
  let theta = theta /. 2. in
  {r = cos theta;
   i = v.Vector3f.x *. sin theta;
   j = v.Vector3f.y *. sin theta;
   k = v.Vector3f.z *. sin theta}

let conj q = 
  {r = q.r;
   i = -. q.i;
   j = -. q.j;
   k = -. q.k}

let squared_norm q = 
  q.i *. q.i +. q.j *. q.j +. q.k *. q.k +. q.r *. q.r

let norm q = sqrt (squared_norm q)

let normalize q = 
  let n = norm q in
  if n = 0. then Error `Division_by_zero
  else Ok (prop (1. /. n) q)

let inverse q = 
  let nq = squared_norm q in
  if nq = 0. then Error `Division_by_zero
  else Ok (prop (1. /. nq) (conj q))


