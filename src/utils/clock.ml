
type t = 
  {
    mutable ticks : int;
    mutable start : float
  }

let create () = 
  {
    ticks = 0;
    start = Unix.gettimeofday ()
  }

let restart t = 
  t.ticks <- 0;
  t.start <- Unix.gettimeofday ()

let tick t = 
  t.ticks <- t.ticks + 1

let time t = 
  Unix.gettimeofday () -. t.start

let ticks t = 
  t.ticks

let tps t = 
  float_of_int t.ticks /. (time t)

let spt t = 
  (time t) /. (float_of_int t.ticks)

