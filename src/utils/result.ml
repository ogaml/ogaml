let make ?result err = 
  match result with
  | None -> Error err
  | Some v -> Ok v

let (||>) a f = 
  fun b -> f b a

let bind res f = 
  match res with
  | Ok v -> f v
  | Error e -> Error e

let (>>=) res f = 
  bind res f

let apply res f = 
  match res with
  | Ok v -> Ok (f v)
  | Error e -> Error e

let (>>>=) res f = 
  apply res f

let assert_ok = function
  | Ok r -> r
  | Error _ -> assert false

let throw = function
  | Ok r -> r
  | Error e -> raise e

let catch f arg = 
  try Ok (f arg)
  with exc -> Error exc

let handle res f = 
  match res with
  | Ok r -> r 
  | Error e -> f e

let rec iter f = function
  | [] -> Ok ()
  | h::t -> 
    f h >>= (fun () -> iter f t)

let rec map f = function
  | [] -> Ok []
  | h::t ->
    f h >>= fun v -> 
    map f t >>= fun l -> 
    Ok (v :: l)

let rec fold f acc = function
  | [] -> Ok acc
  | h::t ->
    f acc h >>= fun v ->
    fold f v t

let rec fold_r f l acc = 
  match l with
  | [] -> Ok acc
  | h::t ->
    fold_r f t acc >>= fun v ->
    f h v

let opt = function
  | Ok v -> Some v
  | Error _ -> None

let from_opt = function
  | Some v -> Ok v
  | None -> Error ()
