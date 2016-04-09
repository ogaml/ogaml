module KeyEvent : sig

  type t = {key : Keycode.t; shift : bool; control : bool; alt : bool}

end

module ButtonEvent : sig

  type t = {button : Button.t; position : OgamlMath.Vector2i.t; shift : bool; control : bool; alt : bool}

end

type t =
  | Closed
  | Resized        of OgamlMath.Vector2i.t
  | KeyPressed     of KeyEvent.t
  | KeyReleased    of KeyEvent.t
  | ButtonPressed  of ButtonEvent.t
  | ButtonReleased of ButtonEvent.t
  | MouseMoved     of OgamlMath.Vector2i.t
