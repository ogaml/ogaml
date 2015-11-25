open OgamlUtils

let () = 
  Printf.printf "Beginning graph tests...\n%!"

module G = Graph.Make (struct

  type t = int

  let compare (i : int) (j : int) = compare i j

end)


let graph1 = 
  let open G in
  empty 
  |> add ~cost:1. 1 2
  |> add ~cost:2. 1 3
  |> add ~cost:3. 1 4
  |> add ~cost:2. 2 5
  |> add ~cost:1. 2 6
  |> add ~cost:2. 3 7
  |> add ~cost:3. 3 8
  |> add ~cost:1. 4 9
  |> add ~cost:2. 4 10
  |> add ~cost:3. 4 11

let graph2 = 
  let open G in
  empty
  |> add ~cost:1. 13 14
  |> add ~cost:2. 13 15
  |> add ~cost:3. 13 16
  |> add ~cost:6. 14 17
  |> add ~cost:2. 15 17
  |> add ~cost:3. 16 17

let graph3 = 
  let open G in
  empty
  |> add ~cost:10. 11 12
  |> add ~cost:10. 12 13
  |> add ~cost:15. 11 13

let graph4 = 
  let open G in 
  empty
  |> add ~cost:5. 12 2
  |> add ~cost:4. 17 1
  |> add ~cost:3. 4  1
  |> add ~cost:1. 16 3

let cycle = 
  let open G in
  empty
  |> add 1 2
  |> add 2 3
  |> add 3 4
  |> add 4 1
  |> add 4 5
  |> add 5 6

let disjgraph = 
  G.merge graph1 graph2

let biggraph = 
  G.merge (G.merge (G.merge graph1 graph2) graph3) graph4

let testgraph1 () = 
  assert (G.neighbours graph1 11 = []);
  assert (G.neighbours graph1 1  = [4;3;2]);
  assert (G.neighbours graph4 17 = [1]);
  assert (G.neighbours graph2 13 = [16;15;14])

let assert_dijkstra graph s t dist = 
  match G.dijkstra graph s t, dist with
  |None, None -> true
  |Some _, None -> false
  |None, Some _ -> false
  |Some (d,_), Some d' -> d = d'

let assert_dijkstra_path graph s t path = 
  match G.dijkstra graph s t with
  |None -> false
  |Some (_,p) -> p = path

let testgraph2 () = 
  assert (assert_dijkstra graph1 11 1  None);
  assert (assert_dijkstra graph1 1  11 (Some 6.));
  assert (assert_dijkstra graph1 2  5  (Some 2.));
  assert (assert_dijkstra graph1 5  2  None);
  assert (assert_dijkstra graph3 11 13 (Some 15.));
  assert (assert_dijkstra graph2 13 17 (Some 4.));
  assert (assert_dijkstra (G.remove_edge graph2 13 15) 13 17 (Some 6.))

let testgraph3 () =
  assert (assert_dijkstra disjgraph 1  13 None);
  assert (assert_dijkstra disjgraph 13 1  None);
  assert (assert_dijkstra disjgraph 1  17 None);
  assert (assert_dijkstra disjgraph 1  11 (Some 6.));
  assert (assert_dijkstra disjgraph 2  5  (Some 2.));
  assert (assert_dijkstra disjgraph 13 17 (Some 4.))

let testgraph4 () = 
  assert (assert_dijkstra biggraph 4  1 (Some 3.));
  assert (assert_dijkstra biggraph 11 3 (Some 19.));
  assert (assert_dijkstra biggraph 12 5 (Some 7.));
  assert (assert_dijkstra biggraph 4  5 (Some 6.))

let testgraph5 () = 
  assert (assert_dijkstra_path biggraph 4  1  [4;1]);
  assert (assert_dijkstra_path biggraph 11 3  [11;13;16;3]);
  assert (assert_dijkstra_path biggraph 1  17 [1;4;11;13;15;17]);
  assert (assert_dijkstra_path biggraph 4  5  [4;1;2;5])

let assert_dfs graph s l = 
  let l = ref l in
  let b = ref true in
  G.dfs graph s (fun v -> 
    assert (!l <> []); 
    b := !b && (List.hd !l = v);
    l := List.tl !l
  ); 
  (!l = []) && !b

let assert_bfs graph s l = 
  let l = ref l in
  let b = ref true in
  G.bfs graph s (fun v -> 
    assert (!l <> []); 
    b := !b && (List.hd !l = v);
    l := List.tl !l
  ); 
  (!l = []) && !b

let testgraph6 () = 
  assert (assert_dfs graph1 1  [1;4;11;10;9;3;8;7;2;6;5]);
  assert (assert_bfs graph1 1  [1;4;3;2;11;10;9;8;7;6;5]);
  assert (assert_dfs graph1 11 [11]);
  assert (assert_bfs graph1 11 [11]);
  assert (assert_dfs graph2 13 [13;16;17;15;14]);
  assert (assert_bfs graph2 13 [13;16;15;14;17]);
  assert (assert_dfs graph4 12 [12;2]);
  assert (assert_bfs graph4 12 [12;2]);
  assert (assert_dfs cycle 1 [1;2;3;4;5;6]);
  assert (assert_bfs cycle 1 [1;2;3;4;5;6]);
  assert (assert_dfs cycle 4 [4;5;6;1;2;3]);
  assert (assert_bfs cycle 4 [4;5;1;6;2;3])

let () = 
  testgraph1 ();
  Printf.printf "\tTest 1 passed\n%!";
  testgraph2 ();
  Printf.printf "\tTest 2 passed\n%!";
  testgraph3 ();
  Printf.printf "\tTest 3 passed\n%!";
  testgraph4 ();
  Printf.printf "\tTest 4 passed\n%!";
  testgraph5 ();
  Printf.printf "\tTest 5 passed\n%!";
  testgraph6 ();
  Printf.printf "\tTest 6 passed\n%!";


