open OgamlGraphics
open OgamlUtils

let () =
  Log.info Log.stdout "Beginning version test..."

let settings = OgamlCore.ContextSettings.create ~core_profile:true ()

let window = 
  match Window.create ~width:100 ~height:100 ~settings ~title:"" () with
  | Ok win -> win
  | Error (`Context_initialization_error s) -> failwith ("Failed to create context: " ^ s)
  | Error (`Window_creation_error s) -> failwith ("Failed to create window: " ^ s)

let context = Window.context window

let () = 
  Log.info Log.stdout "GLSL Version : %i" (Context.glsl_version context);
  let (maj, min) = (Context.version context) in
  Log.info Log.stdout "OpenGL Version : %i.%i" maj min
