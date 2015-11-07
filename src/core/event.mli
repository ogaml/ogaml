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
