
type t

(** Creates a window of size width x height *)
val create :
  ?width:int ->
  ?height:int ->
  ?title:string ->
  ?settings:OgamlCore.ContextSettings.t -> unit -> t

(** Changes the title of the window. *)
val set_title : t -> string -> unit

(** Closes a window, but does not free the memory.
  * This should prevent segfaults when calling functions on this window. *)
val close : t -> unit

(** Free the window and the memory *)
val destroy : t -> unit

(** Resize the window *)
val resize : t -> OgamlMath.Vector2i.t -> unit

(** Toggles the full screen mode of a window. *)
val toggle_fullscreen : t -> unit

(** Returns the rectangle associated to a window, in screen coordinates *)
val rect : t -> OgamlMath.IntRect.t

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
val clear : ?color:Color.t -> t -> unit

(** Returns the internal GL state of the window *)
val state : t -> State.t


module LL : sig

  (** Returns the internal window of this window, should only be used internally *)
  val internal : t -> OgamlCore.LL.Window.t

  (** Returns the 2D drawing program associated to this window's context *)
  val program : t -> Program.t

  (** Returns the 2D drawing program for sprites *)
  val sprite_program : t -> Program.t

  val text_program : t -> Program.t

  val bind_draw_parameters : t -> DrawParameter.t -> unit

end
