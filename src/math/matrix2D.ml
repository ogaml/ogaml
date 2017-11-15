
type t = (float, Bigarray.float32_elt, Bigarray.c_layout) Bigarray.Array1.t

(* Utils, not exposed *)
let create () = Bigarray.Array1.create Bigarray.float32 Bigarray.c_layout 9

let get i j m = Bigarray.Array1.unsafe_get m (i + j*3) (* column major order *)

let set i j m v = Bigarray.Array1.unsafe_set m (i + j*3) v

let to_bigarray m = m

let zero () = 
  let m = create () in
  for i = 0 to 2 do
    for j = 0 to 2 do
      set i j m 0.
    done;
  done; m

let identity () = 
  let m = zero () in
  for i = 0 to 2 do
    set i i m 1.
  done; m

let to_string m = 
  let s = ref "" in
  for i = 0 to 2 do
    s := Printf.sprintf "%s|" !s;
    for j = 0 to 1 do
      s := Printf.sprintf "%s%f; " !s (get i j m) ;
    done;
    s := Printf.sprintf "%s%f|\n" !s (get i 2 m);
  done;
  !s

let translation v = 
  let open Vector2f in
  let m = identity () in
  set 0 2 m v.x;
  set 1 2 m v.y;
  m

let scaling v = 
  let m = zero () in
  let open Vector2f in
  set 0 0 m v.x;
  set 1 1 m v.y;
  set 2 2 m 1.;
  m

let rotation t = 
  let open Vector2f in
  let m = identity () in
  set 0 0 m (cos t);
  set 1 1 m (cos t);
  set 0 1 m (-. (sin t));
  set 1 0 m (sin t);
  m

let product m1 m2 = 
  let m = create () in
  Bigarray.Array1.unsafe_set m 0 (m1.{0} *. m2.{0} +. m1.{3} *. m2.{1} +. m1.{6} *. m2.{2});
  Bigarray.Array1.unsafe_set m 1 (m1.{1} *. m2.{0} +. m1.{4} *. m2.{1} +. m1.{7} *. m2.{2});
  Bigarray.Array1.unsafe_set m 2 (m1.{2} *. m2.{0} +. m1.{5} *. m2.{1} +. m1.{8} *. m2.{2});
  Bigarray.Array1.unsafe_set m 3 (m1.{0} *. m2.{3} +. m1.{3} *. m2.{4} +. m1.{6} *. m2.{5});
  Bigarray.Array1.unsafe_set m 4 (m1.{1} *. m2.{3} +. m1.{4} *. m2.{4} +. m1.{7} *. m2.{5});
  Bigarray.Array1.unsafe_set m 5 (m1.{2} *. m2.{3} +. m1.{5} *. m2.{4} +. m1.{8} *. m2.{5});
  Bigarray.Array1.unsafe_set m 6 (m1.{0} *. m2.{6} +. m1.{3} *. m2.{7} +. m1.{6} *. m2.{8});
  Bigarray.Array1.unsafe_set m 7 (m1.{1} *. m2.{6} +. m1.{4} *. m2.{7} +. m1.{7} *. m2.{8});
  Bigarray.Array1.unsafe_set m 8 (m1.{2} *. m2.{6} +. m1.{5} *. m2.{7} +. m1.{8} *. m2.{8});
  m

let transpose m' = 
  let m = create () in
  m.{0}  <- m'.{0}; m.{1}  <- m'.{3}; m.{2}  <- m'.{6};
  m.{3}  <- m'.{1}; m.{4}  <- m'.{4}; m.{5}  <- m'.{7};
  m.{6}  <- m'.{2}; m.{7}  <- m'.{5}; m.{8}  <- m'.{8};
  m

let translate v m = product (translation v) m

let scale v m = product (scaling v) m

let rotate t m = product (rotation t) m

let times m v = 
  let open Vector2f in
  {
    x = v.x *. m.{0} +. v.y *. m.{3} +. m.{6};
    y = v.x *. m.{1} +. v.y *. m.{4} +. m.{7};
  }

let projection ~size = 
  let m = identity () in
  if size.Vector2f.x = 0. || size.Vector2f.y = 0. then
    raise (Invalid_argument "Matrix2D.projection: invalid projection vector (0 coordinate)");
  set 0 2 m (-1.);
  set 1 2 m 1.;
  set 0 0 m (2. /. size.Vector2f.x);
  set 1 1 m (-. 2. /. size.Vector2f.y);
  m

let iprojection ~size = 
  let m = identity () in
  set 0 0 m (size.Vector2f.x /. 2.);
  set 1 1 m (-. size.Vector2f.y /. 2.);
  set 0 2 m (size.Vector2f.x /. 2.);
  set 1 2 m (size.Vector2f.y /. 2.);
  m

let transformation ~translation ~rotation ~scale ~origin =
  let m = zero () in
  let tx, ty, rx, ry, sx, sy, ox, oy = Vector2f.(
    translation.x, translation.y,
    cos rotation, sin rotation,
    scale.x, scale.y,
    origin.x, origin.y)
  in
  set 0 0 m (rx *. sx);
  set 0 1 m (-. ry *. sy);
  set 0 2 m (-. ox *. sx *. rx +. oy *. sy *. ry +. tx);
  set 1 0 m (ry *. sx);
  set 1 1 m (rx *. sy);
  set 1 2 m (-. ox *. sx *. ry -. oy *. sy *. rx +. ty);
  set 2 2 m 1.;
  m
