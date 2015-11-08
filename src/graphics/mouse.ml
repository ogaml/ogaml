open OgamlCore

let position () = 
  Core.Mouse.position ()

let relative_position win = 
  Core.Mouse.relative_position (Window.internal win)

let set_position a = 
  Core.Mouse.set_position a

let set_relative_position win a = 
  Core.Mouse.set_relative_position (Window.internal win) a

let is_pressed b = 
  Core.Mouse.is_pressed b

