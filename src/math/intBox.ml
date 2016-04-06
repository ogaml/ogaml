
type t = {x : int; y : int; z : int; width : int; height : int; depth : int}

let create v1 v2 = 
  let open Vector3i in
  { x = v1.x; y = v1.y; z = v1.z; 
    width = v2.x; height = v2.y; depth = v2.z }

let create_from_points v1 v2 = 
  create v1 (Vector3i.sub v2 v1)

let zero = {
  x = 0; y = 0; z = 0;
  width = 0; height = 0; depth = 0
}

let one = {
  x = 0; y = 0; z = 0;
  width = 1; height = 1; depth = 1
}

let position t = {
  Vector3i.x = t.x;
  Vector3i.y = t.y;
  Vector3i.z = t.z;
}

let corner t = {
  Vector3i.x = t.x + t.width;
  Vector3i.y = t.y + t.height;
  Vector3i.z = t.z + t.depth;
}

let abs_position t = {
  Vector3i.x = min t.x (t.x + t.width);
  Vector3i.y = min t.y (t.y + t.height);
  Vector3i.z = min t.z (t.z + t.depth);
}

let size t = {
  Vector3i.x = t.width;
  Vector3i.y = t.height;
  Vector3i.z = t.depth;
}

let abs_size t = {
  Vector3i.x = abs t.width;
  Vector3i.y = abs t.height;
  Vector3i.z = abs t.depth;
}

let center t = {
  Vector3f.x = float_of_int t.x +. float_of_int t.width  /. 2.;
  Vector3f.y = float_of_int t.y +. float_of_int t.height /. 2.;
  Vector3f.z = float_of_int t.z +. float_of_int t.depth  /. 2.
}

let normalize t = 
  create (abs_position t) (abs_size t)

let volume t = 
  let s = abs_size t in 
  let open Vector3i in
  s.x * s.y * s.z

let scale t v = 
  {t with
    width  = t.width  * v.Vector3i.x;
    height = t.height * v.Vector3i.y;
    depth  = t.depth  * v.Vector3i.z;
  } 

let translate t v = {t with
  x = t.x + v.Vector3i.x;
  y = t.y + v.Vector3i.y;
  z = t.z + v.Vector3i.z;
}

let intersects t1 t2 = 
  let t1 = normalize t1 in
  let t2 = normalize t2 in
  not ((t1.x + t1.width  < t2.x) ||
       (t2.x + t2.width  < t1.x) ||
       (t1.y + t1.height < t2.y) ||
       (t2.y + t2.height < t1.y) ||
       (t1.z + t1.depth  < t2.z) ||
       (t2.z + t2.depth  < t1.z))

let contains1D x posx sizex strict = 
  if sizex >= 0 then begin
    if strict then x >= posx && x < posx + sizex
    else x >= posx && x <= posx + sizex
  end else begin
    if strict then x <= posx && x > posx + sizex
    else x <= posx && x >= posx + sizex
  end

let contains ?strict:(strict=false) t pt = 
  contains1D pt.Vector3i.x t.x t.width  strict &&
  contains1D pt.Vector3i.y t.y t.height strict &&
  contains1D pt.Vector3i.z t.z t.depth  strict 

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
        (fun j ->
          iter1D t.z t.height strict 
            (fun k -> f Vector3i.({x = i; y = j; z = k}))
        )
    )

let fold ?strict:(strict=true) t f u = 
  let r = ref u in
  iter1D t.x t.width strict 
    (fun i ->
      iter1D t.y t.height strict 
        (fun j ->
          iter1D t.z t.height strict 
            (fun k -> r := f Vector3i.({x = i; y = j; z = k}) !r)
        )
    );
  !r


