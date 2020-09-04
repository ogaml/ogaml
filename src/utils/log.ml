type level = Trace | Debug | Info | Warn | Error | Fatal

type t = {chan : out_channel; mutable min_level : level; color : bool; short : bool}

let int_of_lvl = function
  | Trace -> 0
  | Debug -> 1
  | Info -> 2
  | Warn -> 3
  | Error -> 4
  | Fatal -> 5

let compare_lvls l1 l2 = 
  compare (int_of_lvl l1) (int_of_lvl l2)

let string_of_lvl = function
  | Trace -> "[TRACE]"
  | Debug -> "[DEBUG]"
  | Info  -> "[INFO] "
  | Warn  -> "[WARN] "
  | Error -> "[ERROR]"
  | Fatal -> "[FATAL]"

let color_of_lvl = function
  | Trace -> "\027[96m"
  | Debug -> "\027[32m"
  | Info  -> "\027[34m"
  | Warn  -> "\027[33m"
  | Error -> "\027[31m"
  | Fatal -> "\027[31;1m"

let timestamp () =
  let ts = Unix.gettimeofday() in
  let tm = Unix.localtime ts in
  let us, _s = modf ts in
  Printf.sprintf "%04d-%02d-%02d %02d:%02d:%02d.%03d : "
    (1900 + tm.Unix.tm_year)
    (1    + tm.Unix.tm_mon)
    tm.Unix.tm_mday
    tm.Unix.tm_hour
    tm.Unix.tm_min
    tm.Unix.tm_sec
    (int_of_float (1_000. *. us))

let short_timestamp () =
  let ts = Unix.gettimeofday() in
  let tm = Unix.localtime ts in
  let us, _s = modf ts in
  Printf.sprintf "%02d:%02d:%02d.%03d : "
    tm.Unix.tm_hour
    tm.Unix.tm_min
    tm.Unix.tm_sec
    (int_of_float (1_000. *. us))

let default_color = "\027[0m"

let timestamp_color = "\027[37m"

let create ?output:(output = stderr) 
           ?level:(min_level = Trace) 
           ?color:(color = true) 
           ?short:(short = false) () = 
  {chan = output; min_level; color; short}

let stdout = create ~output:stdout ()

let stderr = create ()

let set_level t lvl = 
  t.min_level <- lvl

let log t lvl fmt = 
  let ts = 
    if t.short then short_timestamp () 
    else timestamp ()
  in
  let prefix = 
    if t.color then 
      Printf.sprintf "%s%s %s%s%s%s" 
        (color_of_lvl lvl) (string_of_lvl lvl) default_color 
        timestamp_color ts default_color
    else
      Printf.sprintf "%s %s" (string_of_lvl lvl) ts
  in
  if compare_lvls lvl t.min_level < 0 then
    Printf.ifprintf t.chan ("%s" ^^ fmt ^^ "\n%!") prefix
  else
    Printf.fprintf t.chan ("%s" ^^ fmt ^^ "\n%!") prefix

let trace t fmt = log t Trace fmt

let debug t fmt = log t Debug fmt

let info  t fmt = log t Info  fmt

let warn  t fmt = log t Warn  fmt

let error t fmt = log t Error fmt

let fatal t fmt = log t Fatal fmt

