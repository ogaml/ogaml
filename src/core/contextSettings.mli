type t

val create : ?depth:int ->
             ?stencil:int ->
             ?msaa:int ->
             ?resizable:bool ->
             ?fullscreen:bool ->
             ?framerate_limit:int ->
             ?major_version:int ->
             ?minor_version:int ->
             ?forward_compatible:bool ->
             ?debug:bool ->
             ?core_profile:bool ->
             ?compatibility_profile:bool ->
             unit -> t

val aa_level : t -> int

val depth_bits : t -> int

val stencil_bits : t -> int

val resizable : t -> bool

val framerate_limit : t -> int option

val fullscreen : t -> bool

val major_version : t -> int option

val minor_version : t -> int option

val forward_compatible : t -> bool

val debug : t -> bool

val core_profile : t -> bool

val compatibility_profile : t -> bool
