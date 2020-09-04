
type t = {x : float; y : float}

let make x y = {x; y}

let zero   = {x = 0.; y = 0.}

let unit_x = {x = 1.; y = 0.}

let unit_y = {x = 0.; y = 1.}

let add u v = {
  x = u.x +. v.x;
  y = u.y +. v.y;
}

let sub u v = {
  x = u.x -. v.x;
  y = u.y -. v.y;
}

let prop f v = {
  x = f *. v.x;
  y = f *. v.y;
}

let div f v = 
  if f = 0. then 
    Error `Division_by_zero
  else 
    Ok {x = v.x /. f; y = v.y /. f}

let pointwise_product v1 v2 = 
  {x = v1.x *. v2.x; y = v1.y *. v2.y}

let pointwise_div v1 v2 = 
  {x = v1.x /. v2.x; y = v1.y /. v2.y}

let to_int v = {
  Vector2i.x = int_of_float v.x;
  Vector2i.y = int_of_float v.y;
}

let from_int v = {
  x = float_of_int v.Vector2i.x;
  y = float_of_int v.Vector2i.y;
}

let dot u v = 
  u.x *. v.x +.
  u.y *. v.y

let product u v = {
  x = u.x *. v.x;
  y = u.y *. v.y;
}

let det u v = 
  u.x *. v.y -. u.y *. v.x

let squared_norm v = 
  dot v v

let norm v = 
  sqrt (dot v v)

let squared_dist v1 v2 = squared_norm (sub v2 v1)

let dist v1 v2 = norm (sub v2 v1)

let normalize v = 
  let n = norm v in
  div n v

let clamp u a b = {
  x = min b.x (max u.x a.x);
  y = min b.y (max u.y a.y)
}

let map v f = 
  {x = f v.x; y = f v.y}

let map2 v w f = 
  {x = f v.x w.x; y = f v.y w.y}

let max v = 
  max v.x v.y

let min v = 
  min v.x v.y

let angle u v =
  atan2 (det u v) (dot u v)

let to_string u = 
  Printf.sprintf "(x = %f; y = %f)" u.x u.y

let direction u v = 
  let dir = sub v u in
  let n = norm dir in
  div n dir

let endpoint u v t =
  prop t v
  |> add u

let raytrace_points p1 p2 = 
  let intersects a b mark = 
    let s   = if a < b then 1. else -1. in
    let fst = if a < b then ceil a  else Stdlib.floor a in
    let lst = if a < b then Stdlib.floor b else ceil  b in
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
    let fst = {x = Stdlib.floor p1.x; y = Stdlib.floor p1.y} in
    let fstface = 
      if abs_float (p2.x -. p1.x) >= abs_float (p2.y -. p1.y) then begin
        if p2.x >= p1.x then {x = -1.; y = 0.}
        else {x = 1.; y = 0.}
      end else begin
        if p2.y >= p1.y then {x = 0.; y = -1.}
        else {x = 0.; y = 1.}
      end
    in
    let rec aux p = function
      |[] -> []
      |(t,face)::tail -> 
        (* Ignore the first result if the ray starts on integer coordinates 
         * and if we cross a face with negative normal (that is, we are
         * entering a square, not leaving one) *)
        if t = 0. && face.x +. face.y < 0. then 
          (aux p tail)
        else begin
          let v = sub p face in 
          (t,v,face)::(aux v tail)
        end
    in
    (0., fst, fstface)::(aux fst l)
  in
  let inters_x = intersects p1.x p2.x {x = 1.; y = 0.} in
  let inters_y = intersects p1.y p2.y {x = 0.; y = 1.} in
  let inters   = List.merge (fun (t,_) (t',_) -> compare t t') inters_x inters_y in
  rebuild inters

let raytrace p v t = 
  raytrace_points p (endpoint p v t)
  |> List.map (fun (t',a,b) -> (t'*.t,a,b))
