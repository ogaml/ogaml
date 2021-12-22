module OutputBuffer : sig

  type t = 
    | FrontLeft
    | FrontRight
    | BackLeft
    | BackRight
    | None

end

type t

(** Creates a window of size width x height *)
val create :
  ?width:int ->
  ?height:int ->
  ?title:string ->
  ?settings:OgamlCore.ContextSettings.t -> unit -> 
  (t, [> `Window_creation_error of string
       | `Context_initialization_error of string]) result

(** Changes the title of the window. *)
val set_title : t -> string -> unit

(** Sets a framerate limit *)
val set_framerate_limit : t -> int option -> unit

(** Returns the settings used at the creation of the window *)
val settings : t -> OgamlCore.ContextSettings.t

(** Closes a window, but does not free the memory.
  * This should prevent segfaults when calling functions on this window. *)
val close : t -> unit

(** Free the window and the memory *)
val destroy : t -> unit

(** Resize the window *)
val resize : t -> OgamlMath.Vector2i.t -> unit

(** Toggles the full screen mode of a window. *)
val toggle_fullscreen : t -> bool

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
val clear : ?buffers:OutputBuffer.t list -> ?color:Color.t option -> 
            ?depth:bool -> ?stencil:bool -> t -> 
            (unit, [> `Too_many_draw_buffers | `Duplicate_draw_buffer]) result

(** Returns the internal GL context of the window *)
val context : t -> Context.t

(** Show/hide the cursor *)
val show_cursor : t -> bool -> unit

(** System-only, binds the window for drawing *)
val bind : t -> ?buffers:OutputBuffer.t list -> DrawParameter.t -> 
           (unit, [> `Too_many_draw_buffers | `Duplicate_draw_buffer]) result

(** Returns the internal window of this window.
  * Used internally, hidden from the global interface. *)
val internal : t -> OgamlCore.LL.Window.t

(** Takes a screenshot of the window *)
val screenshot : t -> Image.t 
