
module Display : sig

  type t

  val create : ?hostname:string -> ?display:int -> ?screen:int -> unit -> t

  val screen_count : t -> int

  val default_screen : t -> int

  val flush : t -> unit

  val screen_size : ?screen:int -> t -> (int * int)

  val screen_size_mm : ?screen:int -> t -> (int * int)

end


module Window : sig

  type t

  val root_window : ?screen:int -> Display.t -> t

  val create_simple_window : display:Display.t -> parent:t -> size:(int * int) -> 
                             origin:(int * int) -> background:int -> t

  val map_window : Display.t -> t -> unit

end
