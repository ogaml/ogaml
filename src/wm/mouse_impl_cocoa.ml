let position () =
  let (x,y) = Cocoa.NSEvent.mouse_location () in
  let i = int_of_float in
  i x , i y

let relative_position win =
  let (x,y) = Cocoa.OGWindowController.mouse_location win in
  let i = int_of_float in
  i x , i y

let set_position (x,y) =
  let f = float_of_int in
  Cocoa.Mouse.warp (f x) (f y)

let set_relative_position win (x,y) =
  let frame = Cocoa.OGWindowController.frame win in
  let (dx, dy, _, _) = Cocoa.NSRect.get frame in
  let f = float_of_int in
  Cocoa.Mouse.warp ((f x) +. dx) ((f y) +. dy)

let is_pressed button =
  let pressed_buttons = Cocoa.NSEvent.pressed_mouse_buttons () in
  let conv = Cocoa.NSEvent.(function
    | ButtonLeft  -> Button.Left
    | ButtonRight -> Button.Right
    | ButtonOther -> Button.Middle
  ) in
  List.mem button (List.map conv pressed_buttons)
