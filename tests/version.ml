open OgamlGraphics

let () =
  Printf.printf "Beginning version test...\n%!"

let settings = OgamlCore.ContextSettings.create ()

let window = Window.create ~width:100 ~height:100 ~settings ~title:""

let state = Window.state window

let () = 
  Printf.printf "GLSL Version : %i\n%!" (State.glsl_version state);
  let (maj, min) = (State.version state) in
  Printf.printf "OpenGL Version : %i.%i\n%!" maj min
