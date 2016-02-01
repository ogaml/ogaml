
type t = {x : int; y : int; z : int; width : int; height : int; depth : int}

let create v1 v2 = 
  let open Vector3i in
  let x = if v2.x >= 0 then v1.x else v1.x + v2.x in
  let y = if v2.y >= 0 then v1.y else v1.y + v2.y in
  let z = if v2.z >= 0 then v1.z else v1.z + v2.z in
  let width  = if v2.x >= 0 then v2.x else - v2.x in
  let height = if v2.y >= 0 then v2.y else - v2.y in
  let depth  = if v2.z >= 0 then v2.z else - v2.z in
  { x; y; z; width; height; depth }

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

let size t = {
  Vector3i.x = t.width;
  Vector3i.y = t.height;
  Vector3i.z = t.depth;
}

let center t = {
  Vector3f.x = (float_of_int (t.x + t.width))  /. 2.;
  Vector3f.y = (float_of_int (t.y + t.height)) /. 2.;
  Vector3f.z = (float_of_int (t.z + t.depth))  /. 2.
}

let normalize t = 
  create (position t) (size t)

let volume t = t.width * t.height * t.depth

let scale t v = 
  {t with
    width  = t.width  * v.Vector3i.x;
    height = t.height * v.Vector3i.y;
    depth  = t.depth  * v.Vector3i.z;
  } |> normalize

let translate t v = {t with
  x = t.x + v.Vector3i.x;
  y = t.y + v.Vector3i.y;
  z = t.z + v.Vector3i.z;
}

let intersect t1 t2 = 
  not ((t1.x + t1.width  < t2.x) ||
       (t2.x + t2.width  < t1.x) ||
       (t1.y + t1.height < t2.y) ||
       (t2.y + t2.height < t1.y) ||
       (t1.z + t1.depth  < t2.z) ||
       (t2.z + t2.depth  < t1.z))

let contains t pt = 
  pt.Vector3i.x >= t.x &&
  pt.Vector3i.y >= t.y &&
  pt.Vector3i.z >= t.z &&
  pt.Vector3i.x <= t.x + t.width  &&
  pt.Vector3i.y <= t.y + t.height &&
  pt.Vector3i.z <= t.z + t.depth

let iter t f = 
  let t = normalize t in
  for i = t.x to t.x + t.width - 1 do
    for j = t.y to t.y + t.height - 1 do
      for k = t.z to t.z + t.depth - 1 do
        f i j k
      done;
    done;
  done
