open OgamlGraphics
open OgamlMath

let settings = ContextSettings.create ~color:(`RGB Color.RGB.white) ()
let window = Window.create ~width:900 ~height:600 ~settings

let texture =
  Texture.Texture2D.create
    (Window.state window)
    (`File "examples/mario-block.bmp")

let sprite = Sprite.create ~texture ()

let draw () =
  Sprite.draw ~window ~sprite

let rec handle_events () =
  let open OgamlCore in
  match Window.poll_event window with
  | Some e -> Event.(
      match e with
      | Closed -> Window.close window
      | Event.KeyPressed k -> Keycode.(
        match k.Event.KeyEvent.key with
        | Q when k.Event.KeyEvent.control -> Window.close window
        | _ -> ()
      )
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
