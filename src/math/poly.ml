
type t = float array

let cube corner size = 
  let open Vector3f in
  let fdl, ful, fur, fdr, 
      bdl, bul, bur, bdr 
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
