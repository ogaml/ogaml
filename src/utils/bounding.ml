
open OgamlMath

module B3D = struct

  type aligned

  type any

  type aabb = {aabb_position : Vector3f.t;
               aabb_origin   : Vector3f.t; 
               aabb_corner   : Vector3f.t; 
               aabb_size     : Vector3f.t}

  type naabb = {naabb_position : Vector3f.t;
                naabb_origin   : Vector3f.t;
                naabb_p1       : Vector3f.t;  (*    4----6 *)
                naabb_p2       : Vector3f.t;  (*   /|   /| *)
                naabb_p3       : Vector3f.t;  (*  5----7 | *)
                naabb_p4       : Vector3f.t;  (*  | 0--|-2 *)
                naabb_p5       : Vector3f.t;  (*  |/   |/  *)
                naabb_p6       : Vector3f.t;  (*  1----3   *)
                naabb_p7       : Vector3f.t;
                naabb_p8       : Vector3f.t}

  type sphere = {sphere_position : Vector3f.t;
                 sphere_origin   : Vector3f.t;
                 sphere_radius   : float}

  type triangle = {triangle_position : Vector3f.t;
                   triangle_origin   : Vector3f.t;
                   triangle_p1       : Vector3f.t;
                   triangle_p2       : Vector3f.t;
                   triangle_p3       : Vector3f.t}

  type _ t = 
    | AABB     of aabb
    | NAABB    of naabb
    | Sphere   of sphere
    | Triangle of triangle
    | Mesh     of (any t) list

  let create_cube ?origin:(origin = Vector3f.zero) ~position ~corner ~size () =
    AABB {aabb_position = position; 
          aabb_origin   = origin  ; 
          aabb_corner   = position; 
          aabb_size     = size}

  let create_sphere ?origin:(origin = Vector3f.zero) ~position ~radius () = 
    Sphere {sphere_position = position; 
            sphere_origin   = origin  ; 
            sphere_radius   = radius}

  let create_triangle ?origin:(origin = Vector3f.zero) ~position ~point1 ~point2 ~point3 () = 
    Triangle {triangle_position = position;
              triangle_origin   = origin;
              triangle_p1       = point1; 
              triangle_p2       = point2; 
              triangle_p3       = point3}

  let merge m1 m2 = 
    match m1, m2 with
    | Mesh l, Mesh l' -> Mesh (l @ l')
    | m     , Mesh l 
    | Mesh l, m       -> Mesh (m :: l)
    | m1    , m2      -> Mesh [m1; m2]

  let rec translate m v = 
    match m with
    | Mesh l     -> Mesh (List.map (fun m' -> translate m' v) l)
    | AABB b     -> AABB {b with aabb_position = Vector3f.add b.aabb_position v}
    | Sphere s   -> Sphere {s with sphere_position = Vector3f.add s.sphere_position v}
    | Triangle t -> Triangle {t with triangle_position = Vector3f.add t.triangle_position v}
    | NAABB b    -> NAABB {b with naabb_position = Vector3f.add b.naabb_position v}

  let rotate m ~angle ~axis = 
    let mat = Matrix3D.rotation axis angle in
    let rec rotate_aux m = 
      match m with
      | Mesh l     -> Mesh (List.map (fun m' -> rotate_aux m') l)
      | AABB b     -> 
        let v1, v2 = b.aabb_corner, b.aabb_size in
        let naabb_p1, naabb_p2, naabb_p3, naabb_p4, 
            naabb_p5, naabb_p6, naabb_p7, naabb_p8 = 
          v1, 
          Vector3f.add v1 (Vector3f.({x = 0.  ; y = 0.  ; z = v2.z})),
          Vector3f.add v1 (Vector3f.({x = v2.x; y = 0.  ; z = 0.  })),
          Vector3f.add v1 (Vector3f.({x = v2.x; y = 0.  ; z = v2.z})),
          Vector3f.add v1 (Vector3f.({x = 0.  ; y = v2.y; z = 0.  })),
          Vector3f.add v1 (Vector3f.({x = 0.  ; y = v2.y; z = v2.z})),
          Vector3f.add v1 (Vector3f.({x = v2.x; y = v2.y; z = 0.  })),
          Vector3f.add v1 (Vector3f.({x = v2.x; y = v2.y; z = v2.z}))
        in
        let nab = {
          naabb_position = b.aabb_position;
          naabb_origin   = b.aabb_origin;
          naabb_p1; naabb_p2; naabb_p3; naabb_p4;
          naabb_p5; naabb_p6; naabb_p7; naabb_p8;
        } in
        rotate_aux (NAABB nab) 
      | Sphere s   -> 
        let o_rotated = Matrix3D.times mat (Vector3f.prop (-1.) s.sphere_origin) in
        let o_offset  = Vector3f.add s.sphere_origin o_rotated in
        Sphere {s with sphere_position = Vector3f.add s.sphere_position o_offset}
      | Triangle t ->
        let p1, p2, p3 = 
          Vector3f.sub t.triangle_p1 t.triangle_origin,
          Vector3f.sub t.triangle_p2 t.triangle_origin,
          Vector3f.sub t.triangle_p3 t.triangle_origin
        in
        let p1_r, p2_r, p3_r = 
          Matrix3D.times mat p1,
          Matrix3D.times mat p2,
          Matrix3D.times mat p3
        in
        Triangle {t with triangle_p1 = Vector3f.add p1_r t.triangle_origin
                       ; triangle_p2 = Vector3f.add p2_r t.triangle_origin
                       ; triangle_p3 = Vector3f.add p3_r t.triangle_origin}
      | NAABB b    ->
        let p1, p2, p3, p4, p5, p6, p7, p8 = 
          Vector3f.sub b.naabb_p1 b.naabb_origin,
          Vector3f.sub b.naabb_p2 b.naabb_origin,
          Vector3f.sub b.naabb_p3 b.naabb_origin,
          Vector3f.sub b.naabb_p4 b.naabb_origin,
          Vector3f.sub b.naabb_p5 b.naabb_origin,
          Vector3f.sub b.naabb_p6 b.naabb_origin,
          Vector3f.sub b.naabb_p7 b.naabb_origin,
          Vector3f.sub b.naabb_p8 b.naabb_origin
        in
        let p1r, p2r, p3r, p4r, p5r, p6r, p7r, p8r = 
          Matrix3D.times mat p1, Matrix3D.times mat p2,
          Matrix3D.times mat p3, Matrix3D.times mat p4,
          Matrix3D.times mat p5, Matrix3D.times mat p6,
          Matrix3D.times mat p7, Matrix3D.times mat p8
        in
        NAABB {b with naabb_p1 = Vector3f.add p1r b.naabb_origin
                    ; naabb_p2 = Vector3f.add p2r b.naabb_origin
                    ; naabb_p3 = Vector3f.add p3r b.naabb_origin
                    ; naabb_p4 = Vector3f.add p4r b.naabb_origin
                    ; naabb_p5 = Vector3f.add p5r b.naabb_origin
                    ; naabb_p6 = Vector3f.add p6r b.naabb_origin
                    ; naabb_p7 = Vector3f.add p7r b.naabb_origin
                    ; naabb_p8 = Vector3f.add p8r b.naabb_origin}
    in
    rotate_aux m

  let rec minimal_point = function
    | Mesh l ->
      let lmap = List.map minimal_point l in
      List.fold_left (fun v pt -> Vector3f.map2 v pt min) 
                     Vector3f.({x = infinity; y = infinity; z = infinity})
                     lmap
    | AABB  b -> Vector3f.add b.aabb_corner (Vector3f.add b.aabb_origin b.aabb_position)
    | NAABB b -> 
      let lpts = [b.naabb_p1; b.naabb_p2; b.naabb_p3; b.naabb_p4; 
                  b.naabb_p5; b.naabb_p6; b.naabb_p7; b.naabb_p8] in
      let lmap = List.map (Vector3f.add (Vector3f.add b.naabb_origin b.naabb_position)) lpts in
      List.fold_left (fun v pt -> Vector3f.map2 v pt min) 
                     Vector3f.({x = infinity; y = infinity; z = infinity})
                     lmap
    | Sphere s ->
      let r = -. s.sphere_radius in
      Vector3f.add s.sphere_position (Vector3f.add s.sphere_origin Vector3f.({x = r; y = r; z = r}))
    | Triangle t ->
      let offset = Vector3f.add t.triangle_position t.triangle_origin in
      let p1, p2, p3 = 
        Vector3f.add offset t.triangle_p1,
        Vector3f.add offset t.triangle_p2,
        Vector3f.add offset t.triangle_p3
      in
      Vector3f.map2 p1 (Vector3f.map2 p2 p3 min) min

  let rec maximal_point = function
    | Mesh l ->
      let lmap = List.map minimal_point l in
      List.fold_left (fun v pt -> Vector3f.map2 v pt max) 
                     Vector3f.({x = neg_infinity; y = neg_infinity; z = neg_infinity})
                     lmap
    | AABB  b -> Vector3f.add (Vector3f.add b.aabb_corner b.aabb_size) 
                              (Vector3f.add b.aabb_origin b.aabb_position)
    | NAABB b -> 
      let lpts = [b.naabb_p1; b.naabb_p2; b.naabb_p3; b.naabb_p4; 
                  b.naabb_p5; b.naabb_p6; b.naabb_p7; b.naabb_p8] in
      let lmap = List.map (Vector3f.add (Vector3f.add b.naabb_origin b.naabb_position)) lpts in
      List.fold_left (fun v pt -> Vector3f.map2 v pt max) 
                     Vector3f.({x = neg_infinity; y = neg_infinity; z = neg_infinity})
                     lmap
    | Sphere s ->
      let r = s.sphere_radius in
      Vector3f.add s.sphere_position (Vector3f.add s.sphere_origin Vector3f.({x = r; y = r; z = r}))
    | Triangle t ->
      let offset = Vector3f.add t.triangle_position t.triangle_origin in
      let p1, p2, p3 = 
        Vector3f.add offset t.triangle_p1,
        Vector3f.add offset t.triangle_p2,
        Vector3f.add offset t.triangle_p3
      in
      Vector3f.map2 p1 (Vector3f.map2 p2 p3 max) max

  let rec minimal_aabb m = 
    let min_pt = minimal_point m 
    and max_pt = maximal_point m in
    let center = Vector3f.div 2. (Vector3f.add min_pt max_pt) in
    AABB {
      aabb_origin   = Vector3f.zero;
      aabb_position = center;
      aabb_corner   = Vector3f.sub min_pt center;
      aabb_size     = Vector3f.sub max_pt min_pt;
    }

  let boundary = function
    |AABB b -> 
      let offset = Vector3f.add b.aabb_position b.aabb_origin in
      (Vector3f.add b.aabb_corner offset, b.aabb_size)
    | _ -> assert false

end



