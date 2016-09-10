(** Window creation and manipulation *)
module Window : sig

  type t

  (** Creates a window of size width x height *)
  val create : width:int -> height:int -> title:string -> settings:ContextSettings.t -> t

  (** Sets the tite of the window. *)
  val set_title : t -> string -> unit

  (** Closes a window, but does not free the memory.
    * This should prevent segfaults when calling functions on this window. *)
  val close : t -> unit

  (** Free the window and the memory *)
  val destroy : t -> unit

  (** Return the size of a window *)
  val size : t -> OgamlMath.Vector2i.t

  (** Returns the rectangle of a window *)
  val rect : t -> OgamlMath.IntRect.t

  (** Resize a window *)
  val resize : t -> OgamlMath.Vector2i.t -> unit

  (** Toggle FullScreen mode *)
  val toggle_fullscreen : t -> unit

  (** Return true iff the window is open *)
  val is_open : t -> bool

  (** Return true iff the window has the focus.
    * This should prove useful when one wants to access the mouse or keyboard
    * directly. *)
  val has_focus : t -> bool

  (** Return the event at the top of the stack, if it exists *)
  val poll_event : t -> Event.t option

  (** Display the window after the GL calls *)
  val display : t -> unit

  (** Show/hide the cursor *)
  val show_cursor : t -> bool -> unit

end


(** Getting real-time keyboard information *)
module Keyboard : sig

  val is_pressed : Keycode.t -> bool

  val is_shift_down : unit -> bool

  val is_ctrl_down : unit -> bool

  val is_alt_down : unit -> bool

end


(** Getting real-time mouse information *)
module Mouse : sig

  val position : unit -> OgamlMath.Vector2i.t

  val relative_position : Window.t -> OgamlMath.Vector2i.t

  val set_position : OgamlMath.Vector2i.t -> unit

  val set_relative_position : Window.t -> OgamlMath.Vector2i.t -> unit

  val is_pressed : Button.t -> bool

end
