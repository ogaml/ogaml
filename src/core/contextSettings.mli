type t

val create : ?depth:int ->
             ?stencil:int ->
             ?msaa:int ->
             ?resizable:bool ->
             ?fullscreen:bool ->
             unit -> t

val aa_level : t -> int

val depth_bits : t -> int

val stencil_bits : t -> int

val resizable : t -> bool

val fullscreen : t -> bool
