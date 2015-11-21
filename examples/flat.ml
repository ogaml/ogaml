open OgamlGraphics
open OgamlMath

let settings = ContextSettings.create ~color:(`RGB Color.RGB.white) ()
let window = Window.create ~width:800 ~height:600 ~settings

let rect  = Shape.create_rectangle ~position:Vector2i.({ x = 200 ; y = 150 })
                                   ~size:Vector2i.({ x = 400 ; y = 300 })
                                   ~color:(`RGB Color.RGB.blue) ()

let rect2 = Shape.create_rectangle ~position:Vector2i.({ x = 400 ; y = 300 })
                                   ~size:Vector2i.({ x = 400 ; y = 300 })
                                   ~origin:Vector2f.({ x = 200. ; y = 150. })
                                   ~rotation:20.
                                   ~color:(`RGB Color.RGB.red) ()

let rect3 = Shape.create_rectangle ~position:Vector2i.zero
                                   ~size:Vector2i.({ x = 400 ; y = 300 })
                                   ~origin:Vector2f.({ x = 200. ; y = 150. })
                                   ~rotation:45.
                                   ~color:(`RGB Color.RGB.green) ()

let rect4 = Shape.create_rectangle ~position:Vector2i.({ x = 400 ; y = 300 })
                                   ~size:Vector2i.({ x = 400 ; y = 300 })
                                   ~color:(`RGB Color.RGB.yellow) ()

let draw () =
  Window.draw_shape window rect ;
  Window.draw_shape window rect2 ;
  Window.draw_shape window rect3 ;
  Window.draw_shape window rect4

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
