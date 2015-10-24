type t = {x : float; y : float; z : float}

let zero   = {x = 0.; y = 0.; z = 0.}

let unit_x = {x = 1.; y = 0.; z = 0.}

let unit_y = {x = 0.; y = 1.; z = 0.}

let unit_z = {x = 0.; y = 0.; z = 1.}

let add u v = {
  x = u.x +. v.x;
  y = u.y +. v.y;
  z = u.z +. v.z
}

let sub u v = {
  x = u.x -. v.x;
  y = u.y -. v.y;
  z = u.z -. v.z
}

let prop f v = {
  x = f *. v.x;
  y = f *. v.y;
  z = f *. v.z
}

let div f v = {
  x = v.x /. f;
  y = v.y /. f;
  z = v.z /. f
}

let floor v = {
  Vector3i.x = int_of_float v.x;
  Vector3i.y = int_of_float v.y;
  Vector3i.z = int_of_float v.z
}

let from_int v = {
  x = float_of_int v.Vector3i.x;
  y = float_of_int v.Vector3i.y;
  z = float_of_int v.Vector3i.z
}

let dot u v = 
  u.x *. v.x +.
  u.y *. v.y +.
  u.z *. v.z

let cross u v = {
  x = u.y *. v.z -. u.z *. v.y;
  y = u.z *. v.x -. u.x *. v.z;
  z = u.x *. v.y -. u.y *. v.x
}

let squared_norm v = 
  dot v v

let norm v = 
  sqrt (dot v v)

let normalize v = 
  div (norm v) v

let max v = 
  max (max v.x v.y) v.z

let min v = 
  min (min v.x v.y) v.z

let angle u v =
  atan2 (dot u v) (norm (cross u v))

let direction u v = 
  sub v u
  |> normalize

let endpoint u v t =
  prop t v
  |> add u


