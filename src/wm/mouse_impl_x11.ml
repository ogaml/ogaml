
let position () = 
  let d = Xlib.Display.create () in
  Xlib.Mouse.position d (Xlib.Window.root_of d)

let relative_position win = 
  Xlib.Mouse.position win.Window.display win.Window.window

let set_position (x,y) = 
  let d = Xlib.Display.create () in
  Xlib.Mouse.warp d (Xlib.Window.root_of d) x y

let set_relative_position win (x,y) = 
  Xlib.Mouse.warp win.Window.display win.Window.window x y

let is_pressed button = 
  let d = Xlib.Display.create () in
  let w = Xlib.Window.root_of d in
  match button with
  |Button.Left    -> Xlib.Mouse.button_down d w 1
  |Button.Middle  -> Xlib.Mouse.button_down d w 2
  |Button.Right   -> Xlib.Mouse.button_down d w 3
  |Button.Unknown -> false

