let trybind res f = 
  match res with
  | Ok t -> f t
  | Error e -> Error e

let (>>=) = trybind

let bind res f = 
  match res with
  | Ok t -> Ok (f t)
  | Error e -> Error e

let (>>>=) = bind

let assert_result res = 
  match res with
  | Ok e -> e
  | Error _ -> assert false

let rec iter_result f = function
  | [] -> Ok ()
  | h::t -> f h >>= (fun () -> iter_result f t)
