
type t = {x : float; y : float; width : float; height : float}

let create v1 v2 = 
  let open Vector2f in
  { x = v1.x; y = v1.y;
    width = v2.x; height = v2.y }

let create_from_points v1 v2 = 
  create v1 (Vector2f.sub v2 v1)

let zero = {
  x = 0.; y = 0.;
  width = 0.; height = 0.
}

let one = {
  x = 0.; y = 0.;
  width = 1.; height = 1.
}

let position t = {
  Vector2f.x = t.x;
  Vector2f.y = t.y;
}

let abs_position t = {
  Vector2f.x = min t.x (t.x +. t.width);
  Vector2f.y = min t.y (t.y +. t.height);
}

let corner t = {
  Vector2f.x = t.x +. t.width;
  Vector2f.y = t.y +. t.height;
}

let abs_corner t = {
  Vector2f.x = max t.x (t.x +. t.width);
  Vector2f.y = max t.y (t.y +. t.height)
}

let size t = {
  Vector2f.x = t.width;
  Vector2f.y = t.height;
}

let abs_size t = {
  Vector2f.x = abs_float t.width;
  Vector2f.y = abs_float t.height;
}

let center t = {
  Vector2f.x = t.x +. t.width  /. 2.;
  Vector2f.y = t.y +. t.height /. 2.;
}

let normalize t = 
  create (abs_position t) (abs_size t)

let area t = 
  let s = abs_size t in 
  let open Vector2f in
  s.x *. s.y

let scale t v = 
  {t with
    width  = t.width  *. v.Vector2f.x;
    height = t.height *. v.Vector2f.y;
  } 

let translate t v = {t with
  x = t.x +. v.Vector2f.x;
  y = t.y +. v.Vector2f.y;
}

let from_int t = {
  x = float_of_int t.IntRect.x;
  y = float_of_int t.IntRect.y;
  width  = float_of_int t.IntRect.width ;
  height = float_of_int t.IntRect.height;
}

let floor t = {
  IntRect.x = int_of_float t.x;
  IntRect.y = int_of_float t.y;
  IntRect.width  = int_of_float t.width ;
  IntRect.height = int_of_float t.height;
}

let intersects t1 t2 = 
  let t1, t2 = normalize t1, normalize t2 in
  not ((t1.x +. t1.width  < t2.x) ||
       (t2.x +. t2.width  < t1.x) ||
       (t1.y +. t1.height < t2.y) ||
       (t2.y +. t2.height < t1.y))

let contains t pt = 
  let t = normalize t in
  pt.Vector2f.x >= t.x &&
  pt.Vector2f.y >= t.y &&
  pt.Vector2f.x <= t.x +. t.width  &&
  pt.Vector2f.y <= t.y +. t.height 

