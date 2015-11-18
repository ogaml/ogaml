open OgamlGraphics
open OgamlMath

let settings = ContextSettings.create ~color:(`RGB Color.RGB.white) ()
let window = Window.create ~width:800 ~height:600 ~settings

(* Setting the clear color to white *)
let () = GL.Pervasives.color 1.0 1.0 1.0 1.0

let rect = Shape.create_rectangle ~width:400
                                  ~height:300
                                  ~x:200
                                  ~y:150
                                  ~color:(`RGB Color.RGB.blue) ()

let draw () =
  Window.draw_shape window rect

let rec handle_events () =
  match Window.poll_event window with
  | Some e -> OgamlCore.Event.(
      match e with
      | Closed -> Window.close window
      | _      -> ()
    ) ; handle_events ()
  | None -> ()

let rec each_frame () =
  if Window.is_open window then begin
    Window.clear window ;
    draw () ;
    Window.display window ;
    handle_events () ;
    each_frame ()
  end

let () = each_frame ()