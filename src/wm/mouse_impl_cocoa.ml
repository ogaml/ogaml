let position () =
  let (x,y) = Cocoa.NSEvent.mouse_location () in
  let i = int_of_float in
  i x , i y

let relative_position win =
  let (x,y) = Cocoa.OGWindowController.mouse_location win in
  let i = int_of_float in
  i x , i y

let set_position (x,y) = ()

let set_relative_position win (x,y) = ()

let is_pressed button = true
