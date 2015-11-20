
exception Missing_uniform of string

exception Invalid_uniform of string

type t

(** Creates a window of size width x height *)
val create : width:int -> height:int -> settings:ContextSettings.t -> t

(** Closes a window, but does not free the memory.
  * This should prevent segfaults when calling functions on this window. *)
val close : t -> unit

(** Free the window and the memory *)
val destroy : t -> unit

(** Return the size of a window *)
val size : t -> (int * int)

(** Return true iff the window is open *)
val is_open : t -> bool

(** Return true iff the window has the focus.
  * This should prove useful when one wants to access the mouse or keyboard
  * directly. *)
val has_focus : t -> bool

(** Return the event at the top of the stack, if it exists *)
val poll_event : t -> OgamlCore.Event.t option

(** Display the window after the GL calls *)
val display : t -> unit

(** Draws a vertex array *)
val draw :
  window     : t ->
  ?indices   : 'a IndexArray.t ->
  vertices   : 'b VertexArray.t ->
  program    : Program.t ->
  uniform    : Uniform.t ->
  parameters : DrawParameter.t ->
  mode       : DrawMode.t ->
  unit -> unit

(** Draws a 2D shape *)
val draw_shape : t -> Shape.t -> unit

(** Clears the window *)
val clear : t -> unit

(** Returns the internal GL state of the window *)
val state : t -> State.t


module LL : sig

  (** Returns the internal window of this window, should only be used internally *)
  val internal : t -> OgamlCore.LL.Window.t

end
