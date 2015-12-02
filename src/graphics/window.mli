
exception Missing_uniform of string

exception Invalid_uniform of string

type t

(** Creates a window of size width x height *)
val create :
  width:int ->
  height:int ->
  title:string ->
  settings:ContextSettings.t -> t

(** Changes the title of the window. *)
val set_title : t -> string -> unit

(** Closes a window, but does not free the memory.
  * This should prevent segfaults when calling functions on this window. *)
val close : t -> unit

(** Free the window and the memory *)
val destroy : t -> unit

(** Return the size of a window *)
val size : t -> OgamlMath.Vector2i.t

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

(** Clears the window *)
val clear : t -> unit

(** Returns the internal GL state of the window *)
val state : t -> State.t


module LL : sig

  (** Returns the internal window of this window, should only be used internally *)
  val internal : t -> OgamlCore.LL.Window.t

  (** Returns the 2D drawing program associated to this window's context *)
  val program : t -> Program.t

  (** Returns the 2D drawing program for sprites *)
  val sprite_program : t -> Program.t

end
