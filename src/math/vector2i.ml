
type t = {x : int; y : int}

let zero = {x = 0; y = 0}

let unit_x = {x = 1; y = 0}

let unit_y = {x = 0; y = 1}

let add u v = {
  x = u.x + v.x;
  y = u.y + v.y;
}

let sub u v = {
  x = u.x - v.x;
  y = u.y - v.y;
}

let prop k u = {
  x = k * u.x;
  y = k * u.y;
}

let div k u = {
  x = u.x / k;
  y = u.y / k;
}

let dot v1 v2 = 
  v1.x * v2.x + 
  v1.y * v2.y 

let product u v = {
  x = u.x * v.x;
  y = u.y * v.y;
}

let det u v = 
  u.x * v.y - u.y * v.x

let squared_norm v = 
  dot v v

let norm v = 
  sqrt (float_of_int (dot v v))

let angle u v =
  atan2 (float_of_int (det u v)) (float_of_int (dot u v))

let clamp u a b = {
  x = min b.x (max u.x a.x);
  y = min b.y (max u.y a.y);
}

let map u f = 
  {x = f u.x; y = f u.y}

let map2 v w f = 
  {x = f v.x w.x; y = f v.y w.y}

let max u = 
  max u.x u.y

let min u = 
  min u.x u.y

let print u = 
  Printf.sprintf "(x = %i; y = %i)" u.x u.y


