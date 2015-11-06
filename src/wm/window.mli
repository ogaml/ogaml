exception Missing_uniform of string

exception Invalid_uniform of string

type t

(** Creates a window of size width x height *)
val create : width:int -> height:int -> t

(** Closes a window, but does not free the memory.
  * This should prevent segfaults when calling functions on this window. *)
val close : t -> unit

(** Free the window and the memory *)
val destroy : t -> unit

(** Return the size of a window *)
val size : t -> (int * int)

(** Return true iff the window is open *)
val is_open : t -> bool

(** Return the event at the top of the stack, if it exists *)
val poll_event : t -> Event.t option

(** Display the window after the GL calls *)
val display : t -> unit

(** Draws a vertex array *)
val draw : 
  window     : t -> 
  vertices   : 'a OgamlGL.VertexArray.t -> 
  program    : OgamlGL.Program.t -> 
  uniform    : OgamlGL.Uniform.t ->
  parameters : OgamlGL.DrawParameter.t -> unit

(** Clears the window *)
val clear : t -> color:bool -> depth:bool -> stencil:bool -> unit
