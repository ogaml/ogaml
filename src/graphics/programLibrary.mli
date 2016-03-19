
type t

val create : State.t -> t

val shape_drawing : t -> Program.t

val sprite_drawing : t -> Program.t

val atlas_drawing : t -> Program.t
