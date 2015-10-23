type mouse_event = {x : int; y : int}

type key_event = {key : Keycode.t; shift : bool; control : bool; alt : bool}

type button_event = {button : Button.t; x : int; y : int}

type t = 
  | Closed
  | KeyPressed (* of key_event *)
  | KeyReleased (* of key_event *)
  | ButtonPressed (* of button_event *)
  | ButtonReleased (* of button_event *)
  | MouseMoved (* of mouse_event *)

