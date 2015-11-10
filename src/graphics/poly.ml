open OgamlMath

let cube src corner size = 
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
  let nx, ny, nz, nmx, nmy, nmz =
    unit_x, unit_y, unit_z,
    prop (-1.) unit_x,
    prop (-1.) unit_y,
    prop (-1.) unit_z
  in
  let uv1, uv2, uv3, uv4 = 
    Vector2f.({x = 0.; y = 0.}),
    Vector2f.({x = 0.; y = 1.}),
    Vector2f.({x = 1.; y = 1.}),
    Vector2f.({x = 1.; y = 0.})
  in
  let cx, cy, cz, cmx, cmy, cmz = 
    `RGB Color.RGB.blue,
    `RGB Color.RGB.green,
    `RGB Color.RGB.yellow,
    `RGB Color.RGB.red,
    `RGB Color.RGB.magenta,
    `RGB Color.RGB.cyan
  in
  let add src (pt,n,col,uv) = 
    let open VertexArray in
    let vertex = 
      Vertex.create
        ?position:(if Source.requires_position src then Some pt else None)
        ?color:(if Source.requires_color src then Some col else None)
        ?texcoord:(if Source.requires_uv src then Some uv else None)
        ?normal:(if Source.requires_normal src then Some n else None) ()
    in
    Source.add src vertex
  in
  [
    (fdl,nz,cz,uv1); (ful,nz,cz,uv2); (fur,nz,cz,uv3);
    (fdl,nz,cz,uv1); (fur,nz,cz,uv3); (fdr,nz,cz,uv4);

    (ful,ny,cy,uv1); (bul,ny,cy,uv2); (bur,ny,cy,uv3);
    (ful,ny,cy,uv1); (bur,ny,cy,uv3); (fur,ny,cy,uv4);

    (bul,nmz,cmz,uv1); (bdl,nmz,cmz,uv2); (bdr,nmz,cmz,uv3);
    (bul,nmz,cmz,uv1); (bdr,nmz,cmz,uv3); (bur,nmz,cmz,uv4);

    (bdl,nmy,cmy,uv1); (fdl,nmy,cmy,uv2); (fdr,nmy,cmy,uv3);
    (bdl,nmy,cmy,uv1); (fdr,nmy,cmy,uv3); (bdr,nmy,cmy,uv4);

    (fdr,nx,cx,uv1); (fur,nx,cx,uv2); (bur,nx,cx,uv3);
    (fdr,nx,cx,uv1); (bur,nx,cx,uv3); (bdr,nx,cx,uv4);

    (bdl,nmx,cmx,uv1); (bul,nmx,cmx,uv2); (ful,nmx,cmx,uv3);
    (bdl,nmx,cmx,uv1); (ful,nmx,cmx,uv3); (fdl,nmx,cmx,uv4);
  ]
  |> List.iter (add src); src


let axis src start length =
  let add src (pt,col,n,uv) = 
    let open VertexArray in
    let vertex = 
      Vertex.create
        ?position:(if Source.requires_position src then Some pt else None)
        ?color:(if Source.requires_color src then Some col else None)
        ?texcoord:(if Source.requires_uv src then Some uv else None)
        ?normal:(if Source.requires_normal src then Some n else None) ()
    in
    Source.add src vertex
  in
  let v1 = start in
  let v2 = Vector3f.add start length in
  let begx, begy, begz, 
      endx, endy, endz =
      Vector3f.(prop v1.x unit_x),
      Vector3f.(prop v1.y unit_y),
      Vector3f.(prop v1.z unit_z),
      Vector3f.(prop v2.x unit_x),
      Vector3f.(prop v2.y unit_y),
      Vector3f.(prop v2.z unit_z)
  in
  let colx, coly, colz = 
    `RGB Color.RGB.red,
    `RGB Color.RGB.green,
    `RGB Color.RGB.blue
  in
  let n = Vector3f.zero in
  let uv = Vector2f.zero in
  [ 
    (begx, colx, n, uv); (endx, colx, n, uv);
    (begy, coly, n, uv); (endy, coly, n, uv);
    (begz, colz, n, uv); (endz, colz, n, uv)
  ]
  |> List.iter (add src); src

