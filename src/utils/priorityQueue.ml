
module type Priority = sig

  type t

  val compare : t -> t -> int

end


module type Q = sig

  exception Empty

  type priority

  type 'a t

  val empty : 'a t

  val is_empty : 'a t -> bool

  val singleton : priority -> 'a -> 'a t

  val merge : 'a t -> 'a t -> 'a t

  val insert : 'a t -> priority -> 'a -> 'a t

  val top : 'a t -> 'a

  val pop : 'a t -> 'a t

  val extract : 'a t -> ('a * 'a t)

end


module Make (P : Priority) : Q with type priority = P.t = struct

  exception Empty

  type priority = P.t

  type 'a t = Emp | Node of int * priority * 'a * 'a t * 'a t

  let empty = Emp

  let is_empty q = q = Emp

  let singleton prio elt = Node (1, prio, elt, Emp, Emp)

  let rank = function
    |Emp -> 0
    |Node (r,_,_,_,_) -> r

  let make p x l r = 
    let rkl, rkr = rank l, rank r in
    if rkl >= rkr then Node (rkr+1,p,x,l,r) else Node (rkl+1,p,x,r,l)

  let rec merge q1 q2 = 
    match q1,q2 with
    |Emp, q |q, Emp -> q
    |Node (rk,p,x,l1,r1), Node(rk',p',y,l2,r2) ->
      if P.compare p p' <= 0 then make p x l1 (merge r1 q2) else make p' y l2 (merge q1 r2)

  let rec insert queue prio elt = merge (singleton prio elt) queue

  let top = function
    |Emp -> raise Empty
    |Node(_,_,x,_,_) -> x

  let pop = function
    |Emp -> raise Empty
    |Node(_,_,_,l,r) -> merge l r

  let extract q = 
    top q, pop q

end



