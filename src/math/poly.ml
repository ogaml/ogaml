
type t = float array

let cube corner size = 
  let open Vector3f in
  let bdl, bul, bur, bdr, 
      fdl, ful, fur, fdr 
      =
      corner,
      add corner {x = 0.; y = size.y; z = 0.},
      add corner {x = size.x; y = size.y; z = 0.},
      add corner {x = size.x; y = 0.; z = 0.},
      add corner {x = 0.; y = 0.; z = size.z},
      add corner {x = 0.; y = size.y; z = size.z},
      add corner {x = size.x; y = size.y; z = size.z},
      add corner {x = size.x; y = 0.; z = size.z}
  in
  [|
    fdl; ful; fur;
    fdl; fur; fdr;

    ful; bul; bur;
    ful; bur; fur;

    bul; bdl; bdr;
    bul; bdr; bur;

    bdl; fdl; fdr;
    bdl; fdr; bdr;

    fdr; fur; bur;
    fdr; bur; bdr;

    bdl; bul; ful;
    bdl; ful; fdl;
  |]
  |> convert_array
   

let cube_n corner size = 
  let open Vector3f in
  let f, b, u, d, l, r =
    {x =  0.; y =  0.; z =  1.},
    {x =  0.; y =  0.; z = -1.},
    {x =  0.; y =  1.; z =  0.},
    {x =  0.; y = -1.; z =  0.},
    {x = -1.; y =  0.; z =  0.},
    {x =  1.; y =  0.; z =  0.}
  in
  let norm_array = 
    [|
      f; f; f; f; f; f;
      u; u; u; u; u; u;
      b; b; b; b; b; b;
      d; d; d; d; d; d;
      r; r; r; r; r; r;
      l; l; l; l; l; l;
    |]
  in
  Array.concat [
    (cube corner size);
    (convert_array norm_array)
  ]

let axis start length = 
  let a = start in
  let b = start +. length in
  [|
    a ; 0.; 0.;
    b ; 0.; 0.;
    0.; a ; 0.;
    0.; b ; 0.;
    0.; 0.; a ;
    0.; 0.; b 
  |]

let sphere radius precision = 
  let nb_triangles = 8 * (precision + 1) + (precision + 1) * precision * 8 * 2 in
  let sphere = Array.make (nb_triangles * 3) Vector3f.({x = 0.; y = 0.; z = 0.}) in
  let subdivs = 4 * (precision + 1) in
  let unit_angle = 3.141592 *. 2. /. (float_of_int subdivs) in
  for i = 0 to subdivs - 1 do
    let fi = float_of_int i in
    let ii = 6 * i * (2 * precision + 1) in
    for j = 0 to precision - 1 do
      let fj = float_of_int j in

      (* north hemisphere *)
      let jj = 12 * j in
      let p1, p2, p3, p4 = Vector3fs.(
        {r = radius; t = fi         *. unit_angle; p = fj         *. unit_angle} |> to_cartesian,
        {r = radius; t = (fi +. 1.) *. unit_angle; p = fj         *. unit_angle} |> to_cartesian,
        {r = radius; t = (fi +. 1.) *. unit_angle; p = (fj +. 1.) *. unit_angle} |> to_cartesian,
        {r = radius; t = fi         *. unit_angle; p = (fj +. 1.) *. unit_angle} |> to_cartesian
      ) in
      sphere.(ii + jj    ) <- p1; sphere.(ii + jj + 1) <- p4; sphere.(ii + jj + 2) <- p3;
      sphere.(ii + jj + 3) <- p1; sphere.(ii + jj + 4) <- p3; sphere.(ii + jj + 5) <- p2;
      
      (* south hemisphere *)
      let jj = 12 * j + 6 in
      let p1, p2, p3, p4 = Vector3fs.(
        {r = radius; t = fi         *. unit_angle; p = -. fj         *. unit_angle} |> to_cartesian,
        {r = radius; t = (fi +. 1.) *. unit_angle; p = -. fj         *. unit_angle} |> to_cartesian,
        {r = radius; t = (fi +. 1.) *. unit_angle; p = -. (fj +. 1.) *. unit_angle} |> to_cartesian,
        {r = radius; t = fi         *. unit_angle; p = -. (fj +. 1.) *. unit_angle} |> to_cartesian
      ) in
      sphere.(ii + jj    ) <- p4; sphere.(ii + jj + 1) <- p1; sphere.(ii + jj + 2) <- p2;
      sphere.(ii + jj + 3) <- p4; sphere.(ii + jj + 4) <- p2; sphere.(ii + jj + 5) <- p3;

    done;
    let fj = float_of_int precision in

    (* north pole *)
    let jj = 12 * precision in
    let p1, p2, p3 = Vector3fs.(
      {r = radius; t = fi         *. unit_angle; p = fj         *. unit_angle} |> to_cartesian,
      {r = radius; t = (fi +. 1.) *. unit_angle; p = fj         *. unit_angle} |> to_cartesian,
      {r = radius; t = fi         *. unit_angle; p = (fj +. 1.) *. unit_angle} |> to_cartesian
    ) in
    sphere.(ii + jj) <- p3; sphere.(ii + jj + 1) <- p2; sphere.(ii + jj + 2) <- p1;

    (* south pole *)
    let jj = 12 * precision + 3 in
    let p1, p2, p3 = Vector3fs.(
      {r = radius; t = fi         *. unit_angle; p = -. fj         *. unit_angle} |> to_cartesian,
      {r = radius; t = (fi +. 1.) *. unit_angle; p = -. fj         *. unit_angle} |> to_cartesian,
      {r = radius; t = fi         *. unit_angle; p = -. (fj +. 1.) *. unit_angle} |> to_cartesian
    ) in
    sphere.(ii + jj) <- p1; sphere.(ii + jj + 1) <- p2; sphere.(ii + jj + 2) <- p3;
  done;
  Vector3f.convert_array sphere


let sphere_n radius precision = 
  let sp = sphere radius precision in
  let n = Array.length sp in
  let norms = Array.make n 0. in
  for i = 0 to (n/9-1) do
    let ii = i * 9 in
    let a,b,c = 
      Vector3f.({x = sp.(ii + 0); y = sp.(ii + 1); z = sp.(ii + 2)}),
      Vector3f.({x = sp.(ii + 3); y = sp.(ii + 4); z = sp.(ii + 5)}),
      Vector3f.({x = sp.(ii + 6); y = sp.(ii + 7); z = sp.(ii + 8)})
    in
    let n = Vector3f.triangle_normal a b c in
    norms.(ii + 0) <- n.Vector3f.x; norms.(ii + 1) <- n.Vector3f.y; norms.(ii + 2) <- n.Vector3f.z;
    norms.(ii + 3) <- n.Vector3f.x; norms.(ii + 4) <- n.Vector3f.y; norms.(ii + 5) <- n.Vector3f.z;
    norms.(ii + 6) <- n.Vector3f.x; norms.(ii + 7) <- n.Vector3f.y; norms.(ii + 8) <- n.Vector3f.z;
  done;
  Array.concat [sp; norms]

