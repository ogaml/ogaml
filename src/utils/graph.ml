
module type Vertex = sig

  type t

  val compare : t -> t -> int

end


module type G = sig

  type t

  type vertex

  val empty : t

  val vertices : t -> int

  val edges : t -> int

  val iter_vertices : t -> (vertex -> unit) -> unit

  val fold_vertices : t -> (vertex -> 'a -> 'a) -> 'a -> 'a

  val iter_edges : t -> (vertex -> vertex -> unit) -> unit

  val add_vertex : t -> vertex -> t

  val add_edge : t -> ?cost:float -> vertex -> vertex -> t

  val add : ?cost:float -> vertex -> vertex -> t -> t

  val remove_edge : t -> vertex -> vertex -> t

  val remove_vertex : t -> vertex -> t

  val neighbours : t -> vertex -> vertex list

  val iter_neighbours : t -> vertex -> (vertex -> unit) -> unit

  val merge : t -> t -> t

  val dfs : t -> vertex -> (vertex -> unit) -> unit

  val bfs : t -> vertex -> (vertex -> unit) -> unit

  val dijkstra : t -> vertex -> vertex -> (float * vertex list) option

  val astar : t -> vertex -> vertex -> (vertex -> float) -> (float * vertex list) option

end


module Make (V : Vertex) : G with type vertex = V.t = struct

  module VMap = Map.Make(V)

  module FQueue = PriorityQueue.Make (struct 

    type t = float 
    
    let compare (f1 : float) (f2 : float) = compare f1 f2

  end)

  type vertex = V.t

  type edge = {cost : float; b_point : vertex; e_point : vertex}

  type t = (edge list) VMap.t 

  let empty = VMap.empty

  let vertices g = VMap.cardinal g

  let edges g = VMap.fold (fun _ l i -> i + (List.length l)) g 0

  let iter_vertices g f = VMap.iter (fun v _ -> f v) g

  let fold_vertices g f v = VMap.fold (fun v _ vl -> f v vl) g v

  let iter_edges g f = VMap.iter (fun _ l -> List.iter (fun e -> f e.b_point e.e_point) l) g

  let add_vertex g v = 
    if VMap.mem v g then g else VMap.add v [] g

  let remove_edge g v1 v2 = 
    if VMap.mem v1 g then begin
      VMap.find v1 g
      |> List.filter (fun e -> e.e_point <> v2)
      |> fun l -> VMap.add v1 l g
    end else g

  let add_edge g ?cost:(cost = 1.) v1 v2 = 
    let edge = {cost; b_point = v1; e_point = v2} in
    if VMap.mem v1 g then begin
      let g' = remove_edge g v1 v2 in
      VMap.add v1 (edge :: (VMap.find v1 g')) g'
    end
    else VMap.add v1 [edge] g

  let add ?cost:(cost = 1.) v1 v2 g = add_edge g ~cost v1 v2

  let remove_vertex g v : t = 
    VMap.fold (fun vtx el map -> 
      if vtx = v then 
        map
      else begin
        let el' = List.filter (fun edge -> edge.e_point <> v) el in
        VMap.add vtx el' map
      end
    ) g VMap.empty

  let neighbours g v = 
    if VMap.mem v g then List.map (fun e -> e.e_point) (VMap.find v g)
    else []

  let iter_neighbours g v f = 
    if VMap.mem v g then List.iter (fun e -> f e.e_point) (VMap.find v g)
    else ()

  let merge g1 g2 = 
    VMap.merge (fun k o1 o2 -> 
      match o1,o2 with
      |None, o |o, None -> o
      |Some l1, Some l2 -> 
        let l2' = List.filter (fun e -> not (List.exists (fun e' -> e'.e_point = e.e_point) l1)) l2 in
        Some (l1 @ l2')
    ) g1 g2

  let dfs g v f = 
    let is_visited i visited = (VMap.mem i visited) && (VMap.find i visited) in
    let set_visited i visited = VMap.add i true visited in
    let rec dfs_aux visited = function
      |v::t when not (is_visited v visited) -> begin
        f v;
        dfs_aux (set_visited v visited) ((neighbours g v) @ t)
      end
      |_::t -> dfs_aux visited t
      |_ -> ()
    in dfs_aux VMap.empty [v]

  let bfs g v f = 
    let is_visited i visited = (VMap.mem i visited) && (VMap.find i visited) in
    let set_visited i visited = VMap.add i true visited in
    let rec bfs_aux visited queue = 
      if Dequeue.is_empty queue then ()
      else begin
        let (v,queue) = Dequeue.pop queue in
        if is_visited v visited then bfs_aux visited queue
        else begin 
          f v;
          bfs_aux (set_visited v visited) 
                  (List.fold_left (fun q v -> Dequeue.push q v) queue (neighbours g v))
        end
      end
    in bfs_aux VMap.empty (Dequeue.singleton v)

  let astar g v1 v2 eval =
    let distance i dists = if VMap.mem i dists then VMap.find i dists else infinity in
    let rec extract_path v path acc = 
      if V.compare v v1 = 0 then v::acc
      else (extract_path (VMap.find v path) path (v::acc))
    in
    let rec d_aux (path,dists,queue) =
      if FQueue.is_empty queue then None
      else begin
        let (v,queue) = FQueue.extract queue in
        if V.compare v v2 = 0 then Some (distance v dists, extract_path v2 path [])
        else begin
          let edges = if VMap.mem v g then VMap.find v g else [] in
          let distv = distance v dists in
          List.fold_left (fun (p,d,q) e ->
            if distv +. e.cost < distance e.e_point dists then
              (VMap.add e.e_point v p, 
               VMap.add e.e_point (distv +. e.cost) d, 
               FQueue.insert q (distv +. e.cost +. (eval e.e_point)) e.e_point)
            else (p,d,q)
          ) (path,dists,queue) edges
          |> d_aux  
        end
      end
    in d_aux (VMap.empty,VMap.singleton v1 0.,FQueue.singleton 0. v1)

  let dijkstra g v1 v2 = astar g v1 v2 (fun _ -> 0.)

end



