
type t = {x : int; y : int; width : int; height : int}

let create pos size = 
  {x = pos.Vector2i.x; 
   y = pos.Vector2i.y;
   width  = size.Vector2i.x; 
   height = size.Vector2i.y}

let corner t =
  {Vector2i.x = t.x;
   Vector2i.y = t.y}

let center t = 
  {Vector2i.x = (t.x + t.width ) / 2; 
   Vector2i.y = (t.y + t.height) / 2}

let area t = t.width * t.height

let scale t s = 
  {t with width  = s.Vector2i.x * t.width;
          height = s.Vector2i.y * t.height}

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

