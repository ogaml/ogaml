
type t = {x : float; y : float}

let zero   = {x = 0.; y = 0.}

let unit_x = {x = 1.; y = 0.}

let unit_y = {x = 0.; y = 1.}

let add u v = {
  x = u.x +. v.x;
  y = u.y +. v.y;
}

let sub u v = {
  x = u.x -. v.x;
  y = u.y -. v.y;
}

let prop f v = {
  x = f *. v.x;
  y = f *. v.y;
}

let div f v = {
  x = v.x /. f;
  y = v.y /. f;
}

let floor v = {
  Vector2i.x = int_of_float v.x;
  Vector2i.y = int_of_float v.y;
}

let from_int v = {
  x = float_of_int v.Vector2i.x;
  y = float_of_int v.Vector2i.y;
}

let dot u v = 
  u.x *. v.x +.
  u.y *. v.y

let product u v = {
  x = u.x *. v.x;
  y = u.y *. v.y;
}

let det u v = 
  u.x *. v.y -. u.y *. v.x

let squared_norm v = 
  dot v v

let norm v = 
  sqrt (dot v v)

let normalize v = 
  div (norm v) v

let clamp u a b = {
  x = min b.x (max u.x a.x);
  y = min b.y (max u.y a.y)
}

let map v f = 
  {x = f v.x; y = f v.y}

let map2 v w f = 
  {x = f v.x w.x; y = f v.y w.y}

let max v = 
  max v.x v.y

let min v = 
  min v.x v.y

let angle u v =
  atan2 (det u v) (dot u v)

let print u = 
  Printf.sprintf "(x = %f; y = %f)" u.x u.y

let direction u v = 
  sub v u
  |> normalize

let endpoint u v t =
  prop t v
  |> add u

