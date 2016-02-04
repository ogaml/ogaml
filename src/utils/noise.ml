open OgamlMath

(* Generate a random permutation *)
let rec fuse_rnd r = function
  |([],l) |(l,[]) -> l
  |(t1::q1,l2) when Random.State.int r 2 = 0 -> t1::(fuse_rnd r (q1,l2))
  |(l1,t2::q2) -> t2::(fuse_rnd r (l1,q2))

and split_l = function
  |[] -> ([],[])
  |[t] -> ([t],[])
  |t1::t2::q -> 
    let (l1,l2) = split_l q in
    (t1::l1,t2::l2)

and perm_l r = function
  |[] -> []
  |[t] -> [t]
  |l -> 
    let (l1,l2) = split_l l in
    fuse_rnd r (perm_l r l1, perm_l r l2)

let rec create_l = function
  |0 -> [0]
  |n -> n::(create_l (n-1))


(* Interpolation *)
let lerp(t, a, b) = a +. t *. (b -. a)
 
let fade t =
  (t *. t *. t) *. (t *. (t *. 6. -. 15.) +. 10.)

(* Create an array to use for perlin noise *)
let perlin_array rng = 
  let p = perm_l rng (create_l 255) in
  Array.of_list (List.rev (List.fold_left (fun i x -> x :: i) (List.rev p) p))


module Perlin2D = struct

  type t = int array

  let create () = 
    perlin_array (Random.get_state ())

  let create_with_seed rng = 
    perlin_array rng

  let grad (hash, x, y) =
    let h = hash land 3 in
    if h = 0 then (x +. y)
    else if h = 1 then (x -. y)
    else if h = 2 then (y -. x)
    else 0. -. (x +. y)

  let get p vec = 
    let open Vector2f in
    let x1 = (int_of_float vec.x) land 255 and
        y1 = (int_of_float vec.y) land 255 and
        xi = vec.x -. (float (int_of_float vec.x)) and
        yi = vec.y -. (float (int_of_float vec.y)) in
    let u = fade xi and
        v = fade yi and
        a = p.(x1) + y1 and
        b = p.(x1 + 1) + y1 in
    let aa = p.(a) and
        ab = p.(a + 1) and
        ba = p.(b) and
        bb = p.(b + 1) in
    lerp(v, lerp(u, (grad(p.(aa), xi    , yi    )),
                    (grad(p.(ba), xi-.1., yi    ))),
            lerp(u, (grad(p.(ab), xi    , yi-.1.)),
                    (grad(p.(bb), xi-.1., yi-.1.))))

end


module Perlin3D = struct

  type t = int array

  let create () = 
    perlin_array (Random.get_state ())

  let create_with_seed rng = 
    perlin_array rng

  let grad (hash, x, y, z) =
    let h = hash land 15 in
    let u = if (h < 8) then x else y in
    let v = if (h < 4) then y else (if (h = 12 || h = 14) then x else z) in
    (if (h land 1 = 0) then u else (0. -. u)) +.
      (if (h land 2 = 0) then v else (0. -. v))

  let get p vec = 
    let open Vector3f in
    let x1 = (int_of_float vec.x) land 255 and
        y1 = (int_of_float vec.y) land 255 and
        z1 = (int_of_float vec.z) land 255 and
        xi = vec.x -. (float (int_of_float vec.x)) and
        yi = vec.y -. (float (int_of_float vec.y)) and
        zi = vec.z -. (float (int_of_float vec.z)) in
    let u  = fade xi and
        v  = fade yi and
        w  = fade zi and
        a  = p.(x1) + y1 in
    let aa = p.(a) + z1 and
        ab = p.(a + 1) + z1 and
        b  = p.(x1 + 1) + y1 in
    let ba = p.(b) + z1 and
        bb = p.(b + 1) + z1 in
    lerp(w, lerp(v, lerp(u, (grad(p.(aa), xi, yi, zi)),
                            (grad(p.(ba), xi -. 1., yi , zi))),
                    lerp(u, (grad(p.(ab), xi , yi -. 1., zi)),
                            (grad(p.(bb), xi -. 1., yi -. 1., zi)))),
            lerp(v, lerp(u, (grad(p.(aa + 1), xi, yi, zi -. 1.)),
                            (grad(p.(ba + 1), xi -. 1., yi , zi -. 1.))),
                    lerp(u, (grad(p.(ab + 1), xi , yi -. 1., zi -.  1.)),
                            (grad(p.(bb + 1), xi -. 1., yi -.  1., zi -. 1.)))))

end





