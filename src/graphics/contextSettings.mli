
type t

val create : ?color:Color.t ->
             ?depth:int ->
             ?stencil:int ->
             ?msaa:int ->
             ?resizable:bool ->
             unit -> t

val clearing_color : t -> Color.t

val depth_bits : t -> int

val stencil_bits : t -> int

val msaa : t -> int

val resizable : t -> bool

val to_ll : t -> OgamlCore.LL.ContextSettings.t
