open OgamlCore

let position () = 
  LL.Mouse.position ()

let relative_position win = 
  LL.Mouse.relative_position (Window.LL.internal win)

let set_position a = 
  LL.Mouse.set_position a

let set_relative_position win a = 
  LL.Mouse.set_relative_position (Window.LL.internal win) a

let is_pressed b = 
  LL.Mouse.is_pressed b

