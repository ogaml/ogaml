
module Display : sig

  type t

  type window

  val create : ?hostname:string -> ?display:int -> ?screen:int -> unit -> t

  val screen_count : t -> int

  val default_screen : t -> int

  val flush : t -> unit

  val screen_size : ?screen:int -> t -> (int * int)

  val screen_size_mm : ?screen:int -> t -> (int * int)

  val root_window : ?screen:int -> t -> window

  val create_simple_window : display:t -> parent:window -> size:(int * int) -> 
                             origin:(int * int) -> window

  val map_window : t -> window -> unit

end
