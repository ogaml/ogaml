module Button : sig

  type t = 
    | Unknown
    | Left
    | Right
    | Middle

end


module Keycode : sig

  type t =
    | Unknown
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


module Event : sig

  module KeyEvent : sig

    type t = {key : Keycode.t; shift : bool; control : bool; alt : bool}

  end

  module ButtonEvent : sig

    type t = {button : Button.t; x : int; y : int; shift : bool; control : bool; alt : bool}

  end

  module MouseEvent : sig

    type t = {x : int; y : int}

  end

  type t =
    | Closed
    | KeyPressed     of KeyEvent.t
    | KeyReleased    of KeyEvent.t
    | ButtonPressed  of ButtonEvent.t
    | ButtonReleased of ButtonEvent.t
    | MouseMoved     of MouseEvent.t

end


module LL : sig

  module Window : sig

    type t

    val create : width:int -> height:int -> t

    val close : t -> unit

    val destroy : t -> unit

    val size : t -> (int * int)

    val is_open : t -> bool

    val has_focus : t -> bool

    val poll_event : t -> Event.t option

    val display : t -> unit

  end


  module Keyboard : sig

    val is_pressed : Keycode.t -> bool

    val is_shift_down : unit -> bool

    val is_ctrl_down : unit -> bool

    val is_alt_down : unit -> bool

  end


  module Mouse : sig

    val position : unit -> (int * int)

    val relative_position : Window.t -> (int * int)

    val set_position : (int * int) -> unit

    val set_relative_position : Window.t -> (int * int) -> unit

    val is_pressed : Button.t -> bool

  end

end
