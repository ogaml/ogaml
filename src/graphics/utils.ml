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

let rec fold_result f acc = function
  | [] -> Ok acc
  | h::t -> f acc h >>= (fun acc' -> fold_result f acc' t)

let rec fold_right_result f l acc =
  match l with
  | [] -> Ok acc
  | h::t -> 
    fold_right_result f t acc >>= (fun acc' -> f h acc')

let handle_error err f = 
  match err with
  | Ok r -> r
  | Error e -> f e

let (>==) = handle_error
