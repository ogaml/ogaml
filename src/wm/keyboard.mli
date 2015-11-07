(** Getting direct keyboard information *)

val is_pressed : Keycode.t -> bool

val is_shift_down : unit -> bool

val is_ctrl_down : unit -> bool

val is_alt_down : unit -> bool
