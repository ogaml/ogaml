type t

external abstract_open  : string option -> t = "caml_xopen_display"
external screen_size    : t -> int -> (int * int) = "caml_xscreen_size"
external screen_size_mm : t -> int -> (int * int) = "caml_xscreen_sizemm"

let create ?hostname ?display:(display = 0) ?screen:(screen = 0) () =
  match hostname with
  |None -> abstract_open None
  |Some(s) -> abstract_open (Some (Printf.sprintf "%s:%i.%i" s display screen))
