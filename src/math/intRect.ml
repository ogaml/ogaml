
type t = {x : int; y : int; width : int; height : int}

let create v1 v2 = 
  let open Vector2i in
  let x = if v2.x >= 0 then v1.x else v1.x + v2.x in
  let y = if v2.y >= 0 then v1.y else v1.y + v2.y in
  let width  = if v2.x >= 0 then v2.x else - v2.x in
  let height = if v2.y >= 0 then v2.y else - v2.y in
  { x; y; width; height }

let create_from_points v1 v2 = 
  create v1 (Vector2i.sub v2 v1)

let zero = 
  { x = 0; y = 0; width = 0; height = 0 }

let one = 
  { x = 0; y = 0; width = 1; height = 1 }

let position t =
  {Vector2i.x = t.x;
   Vector2i.y = t.y}

let corner t = 
  {Vector2i.x = t.x + t.width;
   Vector2i.y = t.y + t.height}

let size t =
  {Vector2i.x = t.width;
   Vector2i.y = t.height}

let center t = 
  {Vector2f.x = (float_of_int (t.x + t.width )) /. 2.; 
   Vector2f.y = (float_of_int (t.y + t.height)) /. 2.}

let normalize t = 
  create (position t) (size t)

let area t = t.width * t.height

let scale t s = 
  {t with width  = s.Vector2i.x * t.width;
          height = s.Vector2i.y * t.height}
  |> normalize

let translate t v = 
  {t with x = v.Vector2i.x + t.x;
          y = v.Vector2i.y + t.y}

let intersect t1 t2 = 
  not ((t1.x + t1.width  < t2.x) ||
       (t2.x + t2.width  < t1.x) ||
       (t1.y + t1.height < t2.y) ||
       (t2.y + t2.height < t1.y))

let contains t pt = 
  pt.Vector2i.x >= t.x &&
  pt.Vector2i.y >= t.y &&
  pt.Vector2i.x <= t.x + t.width &&
  pt.Vector2i.y <= t.y + t.height

let iter t f = 
  let t = normalize t in 
  for i = t.x to t.x + t.width - 1 do
    for j = t.y to t.y + t.height - 1 do
      f i j
    done;
  done
