
type t

val create : ?color:Color.t -> ?clear_color:bool -> 
             ?depth:bool -> ?stencil:bool -> unit -> t

val color : t -> Color.t

val color_clearing : t -> bool

val depth_testing : t -> bool

val stenciling : t -> bool

val to_ll : t -> OgamlCore.LL.ContextSettings.t
