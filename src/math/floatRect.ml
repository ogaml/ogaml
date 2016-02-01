
type t = {x : float; y : float; width : float; height : float}

let create v1 v2 = 
  let open Vector2f in
  let x = if v2.x >= 0. then v1.x else v1.x +. v2.x in
  let y = if v2.y >= 0. then v1.y else v1.y +. v2.y in
  let width  = if v2.x >= 0. then v2.x else -. v2.x in
  let height = if v2.y >= 0. then v2.y else -. v2.y in
  { x; y; width; height }

let create_from_points v1 v2 = 
  create v1 (Vector2f.sub v2 v1)

let zero = 
  { x = 0.; y = 0.; width = 0.; height = 0. }

let one = 
  { x = 0.; y = 0.; width = 1.; height = 1. }

let position t =
  {Vector2f.x = t.x;
   Vector2f.y = t.y}

let corner t = 
  {Vector2f.x = t.x +. t.width;
   Vector2f.y = t.y +. t.height}

let size t =
  {Vector2f.x = t.width;
   Vector2f.y = t.height}

let center t = 
  {Vector2f.x = (t.x +. t.width ) /. 2.; 
   Vector2f.y = (t.y +. t.height) /. 2.}

let normalize t = 
  create (position t) (size t)

let area t = t.width *. t.height

let scale t s = 
  {t with width  = s.Vector2f.x *. t.width;
          height = s.Vector2f.y *. t.height}
  |> normalize

let translate t v = 
  {t with x = v.Vector2f.x +. t.x;
          y = v.Vector2f.y +. t.y}

let from_int ir = 
  {x = float_of_int ir.IntRect.x;
   y = float_of_int ir.IntRect.y;
   width  = float_of_int ir.IntRect.width;
   height = float_of_int ir.IntRect.height}

let floor t = 
  {IntRect.x = int_of_float t.x;
   IntRect.y = int_of_float t.y;
   IntRect.width  = int_of_float t.width;
   IntRect.height = int_of_float t.height}

let intersect t1 t2 = 
  not ((t1.x +. t1.width  < t2.x) ||
       (t2.x +. t2.width  < t1.x) ||
       (t1.y +. t1.height < t2.y) ||
       (t2.y +. t2.height < t1.y))

let contains t pt = 
  pt.Vector2f.x >= t.x &&
  pt.Vector2f.y >= t.y &&
  pt.Vector2f.x <= t.x +. t.width &&
  pt.Vector2f.y <= t.y +. t.height

