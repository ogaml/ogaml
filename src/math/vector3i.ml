
exception Vector3i_exception of string

type t = {x : int; y : int; z : int}

let zero = {x = 0; y = 0; z = 0}

let unit_x = {x = 1; y = 0; z = 0}

let unit_y = {x = 0; y = 1; z = 0}

let unit_z = {x = 0; y = 0; z = 1}

let add u v = {
  x = u.x + v.x;
  y = u.y + v.y;
  z = u.z + v.z
}

let sub u v = {
  x = u.x - v.x;
  y = u.y - v.y;
  z = u.z - v.z
}

let prop k u = {
  x = k * u.x;
  y = k * u.y;
  z = k * u.z
}

let div k u = 
  if k = 0 then 
    raise (Vector3i_exception "Division by zero")
  else
    {
      x = u.x / k;
      y = u.y / k;
      z = u.z / k
    }


let project v = {
  Vector2i.x = v.x;
  Vector2i.y = v.y
}

let lift v = {
  x = v.Vector2i.x;
  y = v.Vector2i.y;
  z = 0
}

let dot v1 v2 = 
  v1.x * v2.x + 
  v1.y * v2.y + 
  v1.z * v2.z

let product u v = {
  x = u.x * v.x;
  y = u.y * v.y;
  z = u.z * v.z
}

let cross u v = {
  x = u.y * v.z - u.z * v.y;
  y = u.z * v.x - u.x * v.z;
  z = u.x * v.y - u.y * v.x
}

let squared_norm v = 
  dot v v

let norm v = 
  sqrt (float_of_int (dot v v))

let angle u v =
  atan2 (norm (cross u v)) (float_of_int (dot u v))

let clamp u a b = {
  x = min b.x (max u.x a.x);
  y = min b.y (max u.y a.y);
  z = min b.z (max u.z a.z)
}

let map u f = 
  {x = f u.x; y = f u.y; z = f u.z}

let map2 v w f = 
  {x = f v.x w.x; y = f v.y w.y; z = f v.z w.z}

let max u = 
  max (max u.x u.y) u.z

let min u = 
  min (min u.x u.y) u.z

let print u = 
  Printf.sprintf "(x = %i; y = %i; z = %i)" u.x u.y u.z


