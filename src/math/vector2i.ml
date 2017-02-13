
exception Vector2i_exception of string

type t = {x : int; y : int}

let make x y = {x; y}

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

let div k u = 
  if k = 0 then 
    raise (Vector2i_exception "Division by zero")
  else
    {
      x = u.x / k;
      y = u.y / k;
    }

let pointwise_product v1 v2 = 
  {x = v1.x * v2.x; y = v1.y * v2.y}

let pointwise_div v1 v2 = 
  {x = v1.x / v2.x; y = v1.y / v2.y}

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

let squared_dist v1 v2 = squared_norm (sub v2 v1)

let dist v1 v2 = norm (sub v2 v1)

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

let to_string u = 
  Printf.sprintf "(x = %i; y = %i)" u.x u.y

let raster v1 v2 = 
  let d = sub v2 v1 in 
  let a = prop 2 (map d abs) in
  let s = map d (fun x -> if x < 0 then -1 else 1) in
  let rec aux_x x y yd = 
    if x = v2.x then [{x;y}]
    else begin
      let y', yd' = 
        if yd >= 0 then (y + s.y, yd - a.x) else y, yd
      in
      let x', yd'' = 
        x + s.x, yd' + a.y
      in
      {x;y}::(aux_x x' y' yd'')
    end
  in
  let rec aux_y x y xd = 
    if y = v2.y then [{x;y}]
    else begin
      let x', xd' = 
        if xd >= 0 then (x + s.x, xd - a.y) else x, xd
      in
      let y', xd'' =
        y + s.y, xd' + a.x
      in
      {x;y}::(aux_y x' y' xd'')
    end
  in
  if a.x >= a.y then
    aux_x v1.x v1.y (a.y - a.x/2)
  else 
    aux_y v1.x v1.y (a.x - a.y/2)
  
