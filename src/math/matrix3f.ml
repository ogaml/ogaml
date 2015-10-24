
type t = (float, Bigarray.float32_elt, Bigarray.c_layout) Bigarray.Array1.t

(* Utils, not exposed *)
let create () = Bigarray.Array1.create Bigarray.float32 Bigarray.c_layout 16

let get i j m = m.{i + j*4} (* column major order *)

let set i j m v = m.{i + j*4} <- v


let to_bigarray m = m

let zero () = 
  let m = create () in
  for i = 0 to 3 do
    for j = 0 to 3 do
      set i j m 0.
    done;
  done; m

let identity () = 
  let m = zero () in
  for i = 0 to 3 do
    set i i m 1.
  done; m

let print m = 
  for i = 0 to 3 do
    print_string "|";
    for j = 0 to 2 do
      print_float (get i j m);
      print_string "; ";
    done;
    print_float (get i 3 m);
    print_endline "|";
  done

let translation v = 
  let open Vector3f in
  let m = identity () in
  set 0 3 m v.x;
  set 1 3 m v.y;
  set 2 3 m v.z;
  m

let scaling v = 
  let open Vector3f in
  let m = zero () in
  set 0 0 m v.x;
  set 1 1 m v.y;
  set 2 2 m v.z;
  set 3 3 m 1.; 
  m

let rotation v t = 
  let open Vector3f in
  let m = identity () in
  let c = cos t in
  let ic = 1. -. c in
  let s = sin t in
  let vn = normalize v in
  let (x,y,z) = (vn.x, vn.y, vn.z) in
  set 0 0 m (x *. x +. (1. -. x *. x) *. c);
  set 0 1 m (ic *. x *. y -. z *. s);
  set 0 2 m (ic *. x *. z +. y *. s);
  set 1 0 m (ic *. x *. y +. z *. s);
  set 1 1 m (y *. y +. (1. -. y *. y) *. c);
  set 1 2 m (ic *. y *. z -. x *. s);
  set 2 0 m (ic *. x *. z -. y *. s);
  set 2 1 m (ic *. y *. z +. x *. s);
  set 2 2 m (z *. z +. (1. -. z *. z) *. c);
  m

let product m1 m2 = 
  let m = create () in
  m.{0}  <- m1.{0} *. m2.{0}  +. m1.{4} *. m2.{1}  +. m1.{8}  *. m2.{2}  +. m1.{12} *. m2.{3};
  m.{1}  <- m1.{1} *. m2.{0}  +. m1.{5} *. m2.{1}  +. m1.{9}  *. m2.{2}  +. m1.{13} *. m2.{3};
  m.{2}  <- m1.{2} *. m2.{0}  +. m1.{6} *. m2.{1}  +. m1.{10} *. m2.{2}  +. m1.{14} *. m2.{3};
  m.{3}  <- m1.{3} *. m2.{0}  +. m1.{7} *. m2.{1}  +. m1.{11} *. m2.{2}  +. m1.{15} *. m2.{3};
  m.{4}  <- m1.{0} *. m2.{4}  +. m1.{4} *. m2.{5}  +. m1.{8}  *. m2.{6}  +. m1.{12} *. m2.{7};
  m.{5}  <- m1.{1} *. m2.{4}  +. m1.{5} *. m2.{5}  +. m1.{9}  *. m2.{6}  +. m1.{13} *. m2.{7};
  m.{6}  <- m1.{2} *. m2.{4}  +. m1.{6} *. m2.{5}  +. m1.{10} *. m2.{6}  +. m1.{14} *. m2.{7};
  m.{7}  <- m1.{3} *. m2.{4}  +. m1.{7} *. m2.{5}  +. m1.{11} *. m2.{6}  +. m1.{15} *. m2.{7};
  m.{8}  <- m1.{0} *. m2.{8}  +. m1.{4} *. m2.{9}  +. m1.{8}  *. m2.{10} +. m1.{12} *. m2.{11};
  m.{9}  <- m1.{1} *. m2.{8}  +. m1.{5} *. m2.{9}  +. m1.{9}  *. m2.{10} +. m1.{13} *. m2.{11};
  m.{10} <- m1.{2} *. m2.{8}  +. m1.{6} *. m2.{9}  +. m1.{10} *. m2.{10} +. m1.{14} *. m2.{11};
  m.{11} <- m1.{3} *. m2.{8}  +. m1.{7} *. m2.{9}  +. m1.{11} *. m2.{10} +. m1.{15} *. m2.{11};
  m.{12} <- m1.{0} *. m2.{12} +. m1.{4} *. m2.{13} +. m1.{8}  *. m2.{14} +. m1.{12} *. m2.{15};
  m.{13} <- m1.{1} *. m2.{12} +. m1.{5} *. m2.{13} +. m1.{9}  *. m2.{14} +. m1.{13} *. m2.{15};
  m.{14} <- m1.{2} *. m2.{12} +. m1.{6} *. m2.{13} +. m1.{10} *. m2.{14} +. m1.{14} *. m2.{15};
  m.{15} <- m1.{3} *. m2.{12} +. m1.{7} *. m2.{13} +. m1.{11} *. m2.{14} +. m1.{15} *. m2.{15};
  m

let translate v m = product (translation v) m

let scale v m = product (scaling v) m

let rotate v t m = product (rotation v t) m

let times m v = 
  let open Vector3f in
  {
    x = v.x *. m.{0} +. v.y *. m.{4} +. v.z *. m.{8} +. m.{12};
    y = v.x *. m.{1} +. v.y *. m.{5} +. v.z *. m.{9} +. m.{12};
    z = v.x *. m.{2} +. v.y *. m.{6} +. v.z *. m.{10} +. m.{12}
  }


