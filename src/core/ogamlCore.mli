(** Base module of OGaml, defines events and low-level window management *)

(** Mouse buttons *)
module Button : sig

  (** This module consists of only one type enumerating the mouse buttons *)

  (** Mouse buttons enumeration *)
  type t =
    | Unknown (* Used when an unrecognized mouse button is triggered. You usually don't need to listen on it. *)
    | Left
    | Right
    | Middle

end


(** Key codes *)
module Keycode : sig

  (** This modules contains an enumeration of the keys *)

  (** Keys enumeration *)
  type t =
    | Unknown (* Used when an unrecognized key event is triggered. You usually don't need to listen on it. *)
    | A
    | B
    | C
    | D
    | E
    | F
    | G
    | H
    | I
    | J
    | K
    | L
    | M
    | N
    | O
    | P
    | Q
    | R
    | S
    | T
    | U
    | V
    | W
    | X
    | Y
    | Z
    | Num1
    | Num2
    | Num3
    | Num4
    | Num5
    | Num6
    | Num7
    | Num8
    | Num9
    | Num0
    | Numpad1
    | Numpad2
    | Numpad3
    | Numpad4
    | Numpad5
    | Numpad6
    | Numpad7
    | Numpad8
    | Numpad9
    | Numpad0
    | NumpadMinus
    | NumpadTimes
    | NumpadPlus
    | NumpadDiv
    | NumpadDot
    | NumpadReturn
    | Escape
    | Tab
    | LControl
    | LShift
    | LAlt
    | Space
    | RControl
    | RShift
    | RAlt
    | Return
    | Delete
    | Up
    | Left
    | Down
    | Right
    | F1
    | F2
    | F3
    | F4
    | F5
    | F6
    | F7
    | F8
    | F9
    | F10
    | F11
    | F12

end


(** Contains all events *)
module Event : sig

  (** Key event information *)
  module KeyEvent : sig

    (** This module defines a public structure encapsulating information
      * about a key event *)

    (** A record containing information about a key event @see:OgamlCore.KeyCode *)
    type t = {key : Keycode.t;  (* Key coresponding to the event *)
              shift : bool;     (* $true$ iff the shift modifier was active during the event *)
              control : bool;   (* $true$ iff the ctrl modifier (or cmd under OSX) was active during the event *)
              alt : bool        (* $true$ iff the alt modifier was active during the event *)
             }

  end

  (** Mouse button event information *)
  module ButtonEvent : sig

    (** This module defines a public structure encapsulating information
      * about a mouse button event *)

    (** A record containing information about a mouse event @see:OgamlCore.Button *)
    type t = {button : Button.t; (* Button corresponding to the event *)
              position : OgamlMath.Vector2i.t; (* Position of the mouse when the event was triggered *)
              shift : bool;   (* $true$ iff the shift modifier was active during the event *)
              control : bool; (* $true$ iff the ctrl modifier (or cmd under OSX) was active during the event *)
              alt : bool      (* $true$ iff the alt modifier was active during the event *)
             }

  end

  (** A variant type describing the possible events
    * @see:OgamlCore.Event.KeyEvent
    * @see:OgamlCore.Event.ButtonEvent *)
  type t =
    | Closed (* The window sending the event has been closed *)
    | Resized         of OgamlMath.Vector2i.t (* The window has been resized by the user *)
    | KeyPressed      of KeyEvent.t  (* A key has been pressed *)
    | KeyReleased     of KeyEvent.t  (* A key has been released *)
    | ButtonPressed   of ButtonEvent.t (* A mouse button has been pressed *)
    | ButtonReleased  of ButtonEvent.t (* A mouse button has been released *)
    | MouseMoved      of OgamlMath.Vector2i.t (* The mouse has been moved *)
    | MouseWheelMoved of float (* The mouse wheel has been moved of $delta$ *)

end


(** Provides some OS-relative data *)
module OS : sig

  (** This module provides some OS-relative data *)

  (** OS enumeration *)
  type os = 
    | Windows 
    | Linux
    | OSX

  (** OS on which this distribution of OGaml has been compiled *)
  val os : os

  (** Resources directory prefix.
    * Prepend this to all the resource paths used by your program before
    * producing an executable/application bundle.
    *)
  val resources_dir : string

  (** [canonical_path p] returns the resolved path equivalent to [p] *)
  val canonical_path : string -> string

end


(** Encapsulates data for context creation *)
module ContextSettings : sig

  (** This module encapsulates the settings used to create a GL context *)

  (** Type of the settings structure *)
  type t

  (** Creates new settings using the following parameters :
    *
    *   $depth$ - bits allocated to the depth buffer (defaults to 24)
    *
    *   $stencil$ - bits allocated to the stencil buffer (defaults to 0)
    *
    *   $msaa$ - MSAA level (defaults to 0)
    *
    *   $resizable$ - requests a resizable context (defaults to true)
    *
    *   $fullscreen$ - requests a fullscreen context (defaults to false)
    *
    *   $framerate_limit$ - sets a framerate limit 
    *
    *)
  val create : ?depth:int ->
               ?stencil:int ->
               ?msaa:int ->
               ?resizable:bool ->
               ?fullscreen:bool ->
               ?framerate_limit:int ->
               unit -> t

  (** Returns the requested AA level *)
  val aa_level : t -> int

  (** Returns the requested number of depth buffer bits *)
  val depth_bits : t -> int

  (** Returns the requested number of stencil buffer bits *)
  val stencil_bits : t -> int

  (** Returns true iff the settings require a resizable window *)
  val resizable : t -> bool

  (** Returns true iff the settings require fullscreen mode *)
  val fullscreen : t -> bool

  (** Returns the requested framerate limit, if any *)
  val framerate_limit : t -> int option

end


(** Low-level access to the window system *)
module LL : sig

  (** This module provides a low-level access to the window system.
    * You should probably use the wrappers defined in OgamlGraphics
    * rather than this module. *)

    (** Window management *)
  module Window : sig

    (** This module provides a low-level interface to create and
      * manage windows. You should probably use the OgamlGraphics.Window
      * wrapper. *)

    (** Type of a window *)
    type t

    (** Creates a window of a given size *)
    val create : width:int -> height:int -> title:string -> settings:ContextSettings.t -> t

    (** Sets the tite of the window. *)
    val set_title : t -> string -> unit

    (** Closes a window, but does not free the memory.
      * This prevents segfaults when calling functions on this window. *)
    val close : t -> unit

    (** Destroys and frees the window from the memory *)
    val destroy : t -> unit

    (** Returns the rectangle associated to a window, in screen coordinates
      * @see:OgamlMath.IntRect *)
    val rect : t -> OgamlMath.IntRect.t

    (** Returns the size of a window
      * @see:OgamlMath.Vector2i *)
    val size : t -> OgamlMath.Vector2i.t

    (** Resize a window
      * @see:OgamlMath.Vector2i *)
    val resize : t -> OgamlMath.Vector2i.t -> unit

    (** Toggle the full screen mode of a window *)
    val toggle_fullscreen : t -> unit

    (** Returns $true$ iff the window is open *)
    val is_open : t -> bool

    (** Returns $true$ iff the window has the focus *)
    val has_focus : t -> bool

    (** Returns the next event on the stack for this window
      * @see:OgamlCore.Event *)
    val poll_event : t -> Event.t option

    (** Displays the window after all the GL calls *)
    val display : t -> unit

    (** Show/hide the cursor *)
    val show_cursor : t -> bool -> unit

  end


  (** Getting real-time keyboard information *)
  module Keyboard : sig

    (** This module provides a low-level access to the keyboard
      * in real-time. You should probably use the OgamlGraphics.Keyboard
      * wrapper instead. *)

    (** Returns $true$ iff the given key is pressed @see:OgamlCore.Keycode *)
    val is_pressed : Keycode.t -> bool

    (** Returns $true$ iff the shift modifier is currently active *)
    val is_shift_down : unit -> bool

    (** Returns $true$ iff the ctrl modifier (or cmd under OSX) is currently active *)
    val is_ctrl_down : unit -> bool

    (** Returns $true$ iff the alt modifier is currently active *)
    val is_alt_down : unit -> bool

  end


  (** Getting real-time mouse information *)
  module Mouse : sig

    (** This modules provides a low-level access to the mouse
      * in real-time. You should probably use the OgamlGraphics.Mouse
      * wrapper instead. *)

    (** Returns the postion of the mouse in screen coordinates
      * @see:OgamlMath.Vector2i *)
    val position : unit -> OgamlMath.Vector2i.t

    (** Returns the position of the mouse relatively to a window
      * @see:OgamlCore.LL.Window
      * @see:OgamlMath.Vector2i *)
    val relative_position : Window.t -> OgamlMath.Vector2i.t

    (** Sets the position of the cursor relatively to the screen
      * @see:OgamlMath.Vector2i *)
    val set_position : OgamlMath.Vector2i.t -> unit

    (** Sets the position of the cursor relatively to a window
      * @see:OgamlCore.LL.Window
      * @see:OgamlMath.Vector2i *)
    val set_relative_position : Window.t -> OgamlMath.Vector2i.t -> unit

    (** Returns $true$ iff the given button is currently held down
      * by the user @see:OgamlCore.Button *)
    val is_pressed : Button.t -> bool

  end

end
