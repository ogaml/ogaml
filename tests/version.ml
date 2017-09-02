open OgamlGraphics

let () =
  Printf.printf "Beginning version test...\n%!"

let settings = OgamlCore.ContextSettings.create ~core_profile:true ()

let window = Window.create ~width:100 ~height:100 ~settings ~title:"" ()

let context = Window.context window

let () = 
  Printf.printf "GLSL Version : %i\n%!" (Context.glsl_version context);
  let (maj, min) = (Context.version context) in
  Printf.printf "OpenGL Version : %i.%i\n%!" maj min
