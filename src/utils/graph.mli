
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


module Make : functor (V : Vertex) -> G with type vertex = V.t

