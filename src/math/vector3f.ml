
exception Vector3f_exception of string

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

let div f v = 
  if f = 0. then
    raise (Vector3f_exception "Division by zero")
  else
    {
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

let project v = {
  Vector2f.x = v.x;
  Vector2f.y = v.y
}

let lift v = {
  x = v.Vector2f.x;
  y = v.Vector2f.y;
  z = 0.
}

let dot u v = 
  u.x *. v.x +.
  u.y *. v.y +.
  u.z *. v.z

let product u v = {
  x = u.x *. v.x;
  y = u.y *. v.y;
  z = u.z *. v.z
}

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
  let n = norm v in
  if n = 0. then
    raise (Vector3f_exception "Cannot normalize zero vector")
  else 
    div n v

let clamp u a b = {
  x = min b.x (max u.x a.x);
  y = min b.y (max u.y a.y);
  z = min b.z (max u.z a.z)
}

let map v f = 
  {x = f v.x; y = f v.y; z = f v.z}

let map2 v w f = 
  {x = f v.x w.x; y = f v.y w.y; z = f v.z w.z}

let max v = 
  max (max v.x v.y) v.z

let min v = 
  min (min v.x v.y) v.z

let angle u v =
  atan2 (norm (cross u v)) (dot u v)

let print u = 
  Printf.sprintf "(x = %f; y = %f; z = %f)" u.x u.y u.z

let direction u v = 
  let dir = sub v u in
  let n = norm dir in
  if n = 0. then
    raise (Vector3f_exception "Cannot get normalized direction from identical points")
  else
    div n dir

let endpoint u v t =
  prop t v
  |> add u

let convert_array t = 
  let n = Array.length t in
  let new_array = Array.make (n*3) 0. in
  for i = 0 to n-1 do
    new_array.(3*i+0) <- t.(i).x;
    new_array.(3*i+1) <- t.(i).y;
    new_array.(3*i+2) <- t.(i).z;
  done; new_array

let triangle_normal a b c = 
  let u,v = sub b a, sub c a in
  normalize (cross u v)
