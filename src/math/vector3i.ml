
type t = {x : int; y : int; z : int}

let make x y z = {x; y; z}

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
    Error `Division_by_zero
  else
    Ok {
      x = u.x / k;
      y = u.y / k;
      z = u.z / k
    }

let pointwise_product v1 v2 = 
  {x = v1.x * v2.x; y = v1.y * v2.y; z = v1.z * v2.z}

let pointwise_div v1 v2 = 
  {x = v1.x / v2.x; y = v1.y / v2.y; z = v1.z / v2.z}

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

let squared_dist v1 v2 = squared_norm (sub v2 v1)

let dist v1 v2 = norm (sub v2 v1)

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

let to_string u = 
  Printf.sprintf "(x = %i; y = %i; z = %i)" u.x u.y u.z

let raster v1 v2 = 
  let d = sub v2 v1 in 
  let a = prop 2 (map d abs) in
  let s = map d (fun x -> if x < 0 then -1 else 1) in
  let rec aux_x x y z yd zd = 
    if x = v2.x then [{x;y;z}]
    else begin
      let y', yd' = 
        if yd >= 0 then (y + s.y, yd - a.x) else y, yd
      in
      let z', zd' = 
        if zd >= 0 then (z + s.z, zd - a.x) else z, zd
      in
      let x', yd'', zd'' = 
        x + s.x, yd' + a.y, zd' + a.z
      in
      {x;y;z}::(aux_x x' y' z' yd'' zd'')
    end
  in
  let rec aux_y x y z xd zd = 
    if y = v2.y then [{x;y;z}]
    else begin
      let x', xd' = 
        if xd >= 0 then (x + s.x, xd - a.y) else x, xd
      in
      let z', zd' = 
        if zd >= 0 then (z + s.z, zd - a.y) else z, zd
      in
      let y', xd'', zd'' = 
        y + s.y, xd' + a.x, zd' + a.z
      in
      {x;y;z}::(aux_y x' y' z' xd'' zd'')
    end
  in
  let rec aux_z x y z xd yd = 
    if z = v2.z then [{x;y;z}]
    else begin
      let x', xd' = 
        if xd >= 0 then (x + s.x, xd - a.z) else x, xd
      in
      let y', yd' = 
        if yd >= 0 then (y + s.y, yd - a.z) else y, yd
      in
      let z', xd'', yd'' = 
        z + s.z, xd' + a.x, yd' + a.y
      in
      {x;y;z}::(aux_z x' y' z' xd'' yd'')
    end
  in
  if a.x >= Stdlib.max a.y a.z then
    aux_x v1.x v1.y v1.z (a.y - a.x/2) (a.z - a.x/2)
  else if a.y >= Stdlib.max a.x a.z then
    aux_y v1.x v1.y v1.z (a.x - a.y/2) (a.z - a.y/2)
  else 
    aux_z v1.x v1.y v1.z (a.x - a.z/2) (a.y - a.z/2)
  


