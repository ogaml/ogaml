
exception Vector3fs_exception of string

type t = {r : float; t : float; p : float}

let zero = {r = 0.; t = 0.; p = 0.}

let unit_x = 
  {
   r = 1.0;
   t = Constants.pi /. 2.;
   p = 0.
  }

let unit_y =
  {
    r = 1.0;
    t = 0.;
    p = Constants.pi /. 2.
  }

let unit_z = 
  {
    r = 1.0;
    t = 0.;
    p = 0.
  }

let prop f v = 
  {
    r = v.r *. f;
    t = v.t;
    p = v.p
  }

let div f v = 
  if f = 0. then
    raise (Vector3fs_exception "Division by zero")
  else
    prop (1. /. f) v

let to_cartesian v = 
  Vector3f.({
    x = v.r *. (cos v.p) *. (sin v.t);
    y = v.r *. (sin v.p);
    z = v.r *. (cos v.p) *. (cos v.t);
  })

let from_cartesian v = 
  Vector3f.({
    r = norm v;
    t = angle unit_z {x = v.x; y = 0.; z = v.z};
    p = Constants.pi /. 2. -. (angle unit_y v)
  })

let norm v = 
  abs_float v.r

let normalize v = 
  let n = norm v in
  if n = 0. then
    raise (Vector3fs_exception "Cannot normalize zero vector")
  else 
    div n v

let to_string u = 
  Printf.sprintf "(r = %f; t = %f; p = %f)" u.r u.t u.p


