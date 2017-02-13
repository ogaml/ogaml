
type t = {x : int; y : int; width : int; height : int}

let create v1 v2 = 
  let open Vector2i in
  { x = v1.x; y = v1.y;
    width = v2.x; height = v2.y }

let create_from_points v1 v2 = 
  create v1 (Vector2i.sub v2 v1)

let zero = {
  x = 0; y = 0;
  width = 0; height = 0
}

let one = {
  x = 0; y = 0;
  width = 1; height = 1
}

let position t = {
  Vector2i.x = t.x;
  Vector2i.y = t.y;
}

let corner t = {
  Vector2i.x = t.x + t.width;
  Vector2i.y = t.y + t.height;
}

let abs_position t = {
  Vector2i.x = min t.x (t.x + t.width);
  Vector2i.y = min t.y (t.y + t.height);
}

let abs_corner t = {
  Vector2i.x = max t.x (t.x + t.width);
  Vector2i.y = max t.y (t.y + t.height)
}

let size t = {
  Vector2i.x = t.width;
  Vector2i.y = t.height;
}

let abs_size t = {
  Vector2i.x = abs t.width;
  Vector2i.y = abs t.height;
}

let center t = {
  Vector2f.x = float_of_int t.x +. float_of_int t.width  /. 2.;
  Vector2f.y = float_of_int t.y +. float_of_int t.height /. 2.;
}

let normalize t = 
  create (abs_position t) (abs_size t)

let area t = 
  let s = abs_size t in 
  let open Vector2i in
  s.x * s.y

let extend t v = 
  {t with width = t.width + v.Vector2i.x;
          height = t.height + v.Vector2i.y}

let scale t v = 
  {t with
    width  = t.width  * v.Vector2i.x;
    height = t.height * v.Vector2i.y;
  } 

let translate t v = {t with
  x = t.x + v.Vector2i.x;
  y = t.y + v.Vector2i.y;
}

let intersects t1 t2 = 
  let t1 = normalize t1 in
  let t2 = normalize t2 in
  not ((t1.x + t1.width  < t2.x) ||
       (t2.x + t2.width  < t1.x) ||
       (t1.y + t1.height < t2.y) ||
       (t2.y + t2.height < t1.y))

let includes t1 t2 = 
  let t1 = normalize t1 in
  let t2 = normalize t2 in
  t2.x >= t1.x && 
  t2.y >= t1.y && 
  (t2.width + t2.x) <= (t1.width + t1.x) &&
  (t2.height + t2.y) <= (t1.height + t1.y)

let contains1D x posx sizex strict = 
  if sizex >= 0 then begin
    if strict then x >= posx && x < posx + sizex
    else x >= posx && x <= posx + sizex
  end else begin
    if strict then x <= posx && x > posx + sizex
    else x <= posx && x >= posx + sizex
  end

let contains ?strict:(strict=false) t pt = 
  contains1D pt.Vector2i.x t.x t.width  strict &&
  contains1D pt.Vector2i.y t.y t.height strict

let iter1D posx sizex strict f = 
  let s = if strict then 1 else 0 in
  if sizex >= 0 then 
    for i = posx to posx + sizex - s do 
      f i
    done
  else
    for i = posx downto posx + sizex + s do
      f i
    done

let iter ?strict:(strict=true) t f = 
  iter1D t.x t.width strict 
    (fun i ->
      iter1D t.y t.height strict 
        (fun j -> f Vector2i.({x = i; y = j}))
    )

let fold ?strict:(strict=true) t f u = 
  let r = ref u in
  iter1D t.x t.width strict 
    (fun i ->
      iter1D t.y t.height strict 
        (fun j -> r := f Vector2i.({x = i; y = j}) !r)
    );
  !r

let to_string t = 
  Printf.sprintf "(x = %i; y = %i; width = %i; height = %i)" t.x t.y t.width t.height
