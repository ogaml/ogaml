
val position : unit -> (int * int)

val relative_position : Window.t -> (int * int)

val set_position : (int * int) -> unit

val set_relative_position : Window.t -> (int * int) -> unit

val is_pressed : Button.t -> bool

