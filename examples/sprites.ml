open OgamlGraphics
open OgamlMath

let settings = ContextSettings.create ~color:(`RGB Color.RGB.white) ()
let window =
  Window.create ~width:900 ~height:600 ~settings ~title:"Sprite Example"

let texture = Texture.Texture2D.create (`File "examples/mario-block.bmp")

let texture_png = Texture.Texture2D.create (`File "examples/test.png")

let sprite = Sprite.create ~texture ()

let sprite2 = Sprite.create ~texture:texture_png ~position:(Vector2i.({x = 50; y = 50})) ()

let draw () =
  Sprite.draw ~window ~sprite;
  Sprite.draw ~window ~sprite:sprite2

let do_all action param =
  action sprite param

let rec handle_events () =
  let open OgamlCore in
  match Window.poll_event window with
  | Some e -> Event.(
      match e with
      | Closed -> Window.close window
      | Event.KeyPressed k -> Keycode.(
        match k.Event.KeyEvent.key with
        | Q when k.Event.KeyEvent.control -> Window.close window
        (* Moving around *)
        | Z -> do_all Sprite.translate Vector2i.({ x =  0 ; y = -5 })
        | Q -> do_all Sprite.translate Vector2i.({ x = -5 ; y =  0 })
        | S -> do_all Sprite.translate Vector2i.({ x =  0 ; y =  5 })
        | D -> do_all Sprite.translate Vector2i.({ x =  5 ; y =  0 })
        (* Do a slow barrel roll *)
        | O -> do_all Sprite.rotate (-5.)
        | P -> do_all Sprite.rotate 5.
        (* Resizing *)
        | F -> do_all Sprite.scale Vector2f.({ x = 0.8  ; y = 1.   })
        | H -> do_all Sprite.scale Vector2f.({ x = 1.25 ; y = 1.   })
        | T -> do_all Sprite.scale Vector2f.({ x = 1.   ; y = 1.25 })
        | G -> do_all Sprite.scale Vector2f.({ x = 1.   ; y = 0.8  })
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
