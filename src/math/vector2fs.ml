
type t = {r : float; t : float}

let zero = {r = 0.; t = 0.}

let unit_x = 
  {
   r = 1.0;
   t = 0.;
  }

let unit_y =
  {
    r = 1.0;
    t = Constants.pi /. 2.;
  }

let prop f v = 
  {
    r = v.r *. f;
    t = v.t;
  }

let div f v = 
  if f = 0. then
    raise (Invalid_argument "Vector2fs.div: division by zero")
  else
    prop (1. /. f) v

let to_cartesian v = 
  Vector2f.({
    x = v.r *. (cos v.t);
    y = v.r *. (sin v.t);
  })

let from_cartesian v = 
  Vector2f.({
    r = norm v;
    t = angle unit_x v
  })

let norm v = 
  abs_float v.r

let normalize v = 
  let n = norm v in
  if n = 0. then
    raise (Invalid_argument "Vector2fs.normalize: zero vector")
  else 
    div n v

let to_string u = 
  Printf.sprintf "(r = %f; t = %f)" u.r u.t


