module Operators = struct

  let (>>) a b =
    match a with
    | Ok v -> b
    | Error e -> Error e

  let (||>) a f =
    fun b -> f b a

  let (>>=) res f =
    match res with
    | Ok v -> f v
    | Error e -> Error e

  let (>>>=) res f =
    match res with
    | Ok v -> Ok (f v)
    | Error e -> Error e

end

module List = struct

  open Operators

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

  let rec fold_left f acc = function
    | [] -> Ok acc
    | h::t ->
      f acc h >>= fun v ->
      fold_left f v t

  let rec fold_right f l acc =
    match l with
    | [] -> Ok acc
    | h::t ->
      fold_right f t acc >>= fun v ->
      f h v

end

let make ?result err =
  match result with
  | None -> Error err
  | Some v -> Ok v

let bind res f =
  match res with
  | Ok v -> f v
  | Error e -> Error e

let apply res f =
  match res with
  | Ok v -> Ok (f v)
  | Error e -> Error e

let is_ok = function
  | Ok _ -> true
  | Error _ -> false

let is_error = function
  | Ok _ -> false
  | Error _ -> true

let assert_ok = function
  | Ok r -> r
  | Error _ -> assert false

let throw = function
  | Ok r -> r
  | Error e -> raise e

let catch f arg =
  try Ok (f arg)
  with exc -> Error exc

let handle f res =
  match res with
  | Ok r -> r
  | Error e -> f e

let map f res =
  match res with
  | Ok r -> Ok (f r)
  | Error e -> Error e

let map_error f res =
  match res with
  | Ok r -> Ok r
  | Error e -> Error (f e)

let opt = function
  | Ok v -> Some v
  | Error _ -> None

let from_opt = function
  | Some v -> Ok v
  | None -> Error ()

let iteri first last f =
  let open Operators in
  let rec aux_incr i =
    if i > last then Ok ()
    else begin
      f i >>= fun () ->
      aux_incr (i+1)
    end
  in
  let rec aux_decr i =
    if i < last then Ok ()
    else begin
      f i >>= fun () ->
      aux_decr (i-1)
    end
  in
  if last >= first then aux_incr first
  else aux_decr first
