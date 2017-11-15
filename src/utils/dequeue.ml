open Utils

type 'a t = ('a list * 'a list)

let empty = ([], [])

let is_empty = function
  |([], []) -> true
  | _ -> false

let singleton a = ([], [a])

let rec refill (l1, l2) = 
  match l1 with
  |[] -> (l1,l2)
  |h::t -> refill (t, h::l2)

let try_refill (l1, l2) = 
  if is_empty (l1, l2) then 
    Error ()
  else begin
    match l2 with
    |[] -> Ok (refill (l1, l2))
    |_  -> Ok (l1, l2)
  end

let rec unfill (l1, l2) = 
  match l2 with
  |[] -> (l1, l2)
  |h::t -> unfill (h::l1, t)

let try_unfill (l1, l2) = 
  if is_empty (l1, l2) then 
    Error ()
  else begin
    match l1 with
    |[] -> Ok (unfill (l1, l2))
    |_  -> Ok (l1, l2)
  end

let push (l1, l2) elt = (elt::l1, l2)

let peek q = 
  try_refill q >>>= fun (l1, l2) ->
  match l2 with
  |[] -> assert false
  |h::t -> h

let pop q = 
  try_refill q >>>= fun (l1, l2) ->
  match l2 with
  |[] -> assert false
  |h::t -> (h, (l1,t))

let push_front (l1, l2) elt = (l1, elt::l2)

let peek_back q = 
  try_unfill q >>>= fun (l1, l2) ->
  match l1 with
  |[] -> assert false
  |h::t -> h

let pop_back q = 
  try_unfill q >>>= fun (l1, l2) ->
  match l1 with
  |[] -> assert false
  |h::t -> (h, (t,l2))



