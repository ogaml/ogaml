
type level = Debug | Warn | Error | Info | Fatal

type t = {chan : out_channel; debug : bool; color : bool; short : bool}

let string_of_lvl = function
  | Debug -> "[DEBUG]"
  | Warn  -> "[WARN] "
  | Error -> "[ERROR]"
  | Info  -> "[INFO] "
  | Fatal -> "[FATAL]"

let color_of_lvl = function
  | Debug -> "\027[32m"
  | Warn  -> "\027[33m"
  | Error -> "\027[31m"
  | Info  -> "\027[34m"
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
           ?debug:(debug = true) 
           ?color:(color = true) 
           ?short:(short = false) () = 
  {chan = output; debug; color; short}

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
  match lvl with
  | Debug -> 
    if t.debug then 
      Printf.fprintf t.chan ("%s" ^^ fmt ^^ "\n%!") prefix
    else 
      Printf.fprintf t.chan ("%s" ^^ fmt ^^ "\n%!") prefix
  | _     -> 
      Printf.fprintf t.chan ("%s" ^^ fmt ^^ "\n%!") prefix

let debug t fmt = log t Debug fmt

let warn  t fmt = log t Warn  fmt

let error t fmt = log t Error fmt

let info  t fmt = log t Info  fmt

let fatal t fmt = log t Fatal fmt

