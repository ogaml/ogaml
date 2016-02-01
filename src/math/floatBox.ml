
type t = {x : float; y : float; z : float; width : float; height : float; depth : float}

let create v1 v2 = {
  x = v1.Vector3f.x;
  y = v1.Vector3f.y;
  z = v1.Vector3f.z;
  width  = v2.Vector3f.x;
  height = v2.Vector3f.y;
  depth  = v2.Vector3f.z
}

let one = {
  x = 0.; y = 0.; z = 0.;
  width = 0.; height = 0.; depth = 0.
}

let corner t = {
  Vector3f.x = t.x;
  Vector3f.y = t.y;
  Vector3f.z = t.z;
}

let position = corner

let size t = {
  Vector3f.x = t.width;
  Vector3f.y = t.height;
  Vector3f.z = t.depth;
}

let center t = {
  Vector3f.x = (t.x +. t.width)  /. 2.;
  Vector3f.y = (t.y +. t.height) /. 2.;
  Vector3f.z = (t.z +. t.depth)  /. 2.
}

let volume t = t.width *. t.height *. t.depth

let scale t v = {t with
  width  = t.width  *. v.Vector3f.x;
  height = t.height *. v.Vector3f.y;
  depth  = t.depth  *. v.Vector3f.z;
}

let translate t v = {t with
  x = t.x +. v.Vector3f.x;
  y = t.y +. v.Vector3f.y;
  z = t.z +. v.Vector3f.z;
}

let from_int t = {
  x = float_of_int t.IntBox.x;
  y = float_of_int t.IntBox.y;
  z = float_of_int t.IntBox.z;
  width  = float_of_int t.IntBox.width ;
  height = float_of_int t.IntBox.height;
  depth  = float_of_int t.IntBox.depth ;
}

let floor t = {
  IntBox.x = int_of_float t.x;
  IntBox.y = int_of_float t.y;
  IntBox.z = int_of_float t.z;
  IntBox.width  = int_of_float t.width ;
  IntBox.height = int_of_float t.height;
  IntBox.depth  = int_of_float t.depth ;
}

let intersect t1 t2 = 
  not ((t1.x +. t1.width  < t2.x) ||
       (t2.x +. t2.width  < t1.x) ||
       (t1.y +. t1.height < t2.y) ||
       (t2.y +. t2.height < t1.y) ||
       (t1.z +. t1.depth  < t2.z) ||
       (t2.z +. t2.depth  < t1.z))

let contains t pt = 
  pt.Vector3f.x >= t.x &&
  pt.Vector3f.y >= t.y &&
  pt.Vector3f.z >= t.z &&
  pt.Vector3f.x <= t.x +. t.width  &&
  pt.Vector3f.y <= t.y +. t.height &&
  pt.Vector3f.z <= t.z +. t.depth

