
exception Vector3f_exception of string

type t = {x : float; y : float; z : float}

let zero   = {x = 0.; y = 0.; z = 0.}

let unit_x = {x = 1.; y = 0.; z = 0.}

let unit_y = {x = 0.; y = 1.; z = 0.}

let unit_z = {x = 0.; y = 0.; z = 1.}

let add u v = {
  x = u.x +. v.x;
  y = u.y +. v.y;
  z = u.z +. v.z
}

let sub u v = {
  x = u.x -. v.x;
  y = u.y -. v.y;
  z = u.z -. v.z
}

let prop f v = {
  x = f *. v.x;
  y = f *. v.y;
  z = f *. v.z
}

let div f v = 
  if f = 0. then
    raise (Vector3f_exception "Division by zero")
  else
    {
      x = v.x /. f;
      y = v.y /. f;
      z = v.z /. f
    }

let floor v = {
  Vector3i.x = int_of_float v.x;
  Vector3i.y = int_of_float v.y;
  Vector3i.z = int_of_float v.z
}

let from_int v = {
  x = float_of_int v.Vector3i.x;
  y = float_of_int v.Vector3i.y;
  z = float_of_int v.Vector3i.z
}

let project v = {
  Vector2f.x = v.x;
  Vector2f.y = v.y
}

let lift v = {
  x = v.Vector2f.x;
  y = v.Vector2f.y;
  z = 0.
}

let dot u v = 
  u.x *. v.x +.
  u.y *. v.y +.
  u.z *. v.z

let product u v = {
  x = u.x *. v.x;
  y = u.y *. v.y;
  z = u.z *. v.z
}

let cross u v = {
  x = u.y *. v.z -. u.z *. v.y;
  y = u.z *. v.x -. u.x *. v.z;
  z = u.x *. v.y -. u.y *. v.x
}

let squared_norm v = 
  dot v v

let norm v = 
  sqrt (dot v v)

let normalize v = 
  let n = norm v in
  if n = 0. then
    raise (Vector3f_exception "Cannot normalize zero vector")
  else 
    div n v

let clamp u a b = {
  x = min b.x (max u.x a.x);
  y = min b.y (max u.y a.y);
  z = min b.z (max u.z a.z)
}

let map v f = 
  {x = f v.x; y = f v.y; z = f v.z}

let map2 v w f = 
  {x = f v.x w.x; y = f v.y w.y; z = f v.z w.z}

let max v = 
  max (max v.x v.y) v.z

let min v = 
  min (min v.x v.y) v.z

let angle u v =
  atan2 (norm (cross u v)) (dot u v)

let print u = 
  Printf.sprintf "(x = %f; y = %f; z = %f)" u.x u.y u.z

let direction u v = 
  let dir = sub v u in
  let n = norm dir in
  if n = 0. then
    raise (Vector3f_exception "Cannot get normalized direction from identical points")
  else
    div n dir

let endpoint u v t =
  prop t v
  |> add u

let convert_array t = 
  let n = Array.length t in
  let new_array = Array.make (n*3) 0. in
  for i = 0 to n-1 do
    new_array.(3*i+0) <- t.(i).x;
    new_array.(3*i+1) <- t.(i).y;
    new_array.(3*i+2) <- t.(i).z;
  done; new_array

let triangle_normal a b c = 
  let u,v = sub b a, sub c a in
  normalize (cross u v)

let raytrace_points p1 p2 = 
  let intersects a b mark = 
    let s   = if a < b then 1. else -1. in
    let fst = if a < b then ceil a  else Pervasives.floor a in
    let lst = if a < b then Pervasives.floor b else ceil  b in
    let idx = 1. /. (b -. a) in
    let rec aux v = 
      if (a  < b && v > lst +. 0.00001) 
      || (a >= b && v < lst -. 0.00001) then []
      else begin
        let t = (v -. a) *. idx in
        (t, prop (-.s) mark)::(aux (v +. s))
      end
    in
    aux fst
  in
  let rebuild l = 
    let fst = {x = Pervasives.floor p1.x; 
               y = Pervasives.floor p1.y; 
               z = Pervasives.floor p1.z} 
    in
    let fstface = 
      if abs_float (p2.x -. p1.x) >= abs_float (p2.y -. p1.y)
      && abs_float (p2.x -. p1.x) >= abs_float (p2.z -. p1.z)
      then begin
        if p2.x >= p1.x then {x = -1.; y = 0.; z = 0.}
        else {x = 1.; y = 0.; z = 0.}
      end else if 
         abs_float (p2.y -. p1.y) >= abs_float (p2.x -. p1.x)
      && abs_float (p2.y -. p1.y) >= abs_float (p2.z -. p1.z)
      then begin
        if p2.y >= p1.y then {x = 0.; y = -1.; z = 0.}
        else {x = 0.; y = 1.; z = 0.}
      end else begin
        if p2.z >= p1.z then {x = 0.; y = 0.; z = -1.}
        else {x = 0.; y = 0.; z = 1.}
      end
    in
    let rec aux p = function
      |[] -> []
      |(t,face)::tail -> 
          let v = sub p face in 
          (t,v,face)::(aux v tail)
    in
    (0., fst, fstface)::(aux fst l)
  in
  let inters_x = intersects p1.x p2.x {x = 1.; y = 0.; z = 0.} in
  let inters_y = intersects p1.y p2.y {x = 0.; y = 1.; z = 0.} in
  let inters_z = intersects p1.z p2.z {x = 0.; y = 0.; z = 1.} in
  let inters   = 
    List.merge (fun (t,_) (t',_) -> compare t t') inters_x inters_y
    |> List.merge (fun (t,_) (t',_) -> compare t t') inters_z
  in
  rebuild inters

let raytrace p v t = 
  raytrace_points p (endpoint p v t)
  |> List.map (fun (t',a,b) -> (t'*.t,a,b))

