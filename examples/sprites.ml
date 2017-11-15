open OgamlGraphics
open OgamlMath

let settings = OgamlCore.ContextSettings.create ()

let window =
  match Window.create ~width:900 ~height:600 ~settings ~title:"Sprite Example" () with
  | Ok win -> win
  | Error s -> failwith s

let texture = Texture.Texture2D.create (module Window) window (`File "examples/mario-block.bmp")

let texture_png = Texture.Texture2D.create (module Window) window (`File "examples/test.png")

let sprite = Sprite.create ~texture ~size:(Vector2f.({x = 50.; y = 50.})) ~origin:(Vector2f.({x=25.;y=25.})) ()

let sprite2 = Sprite.create ~texture:texture_png ~position:(Vector2f.({x = 50.; y = 50.})) ()

let draw () =
  Sprite.draw (module Window) ~target:window ~sprite ();
  Sprite.draw (module Window) ~target:window ~sprite:sprite2 ()

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
        | Z -> do_all Sprite.translate Vector2f.({ x =  0. ; y = -5. })
        | Q -> do_all Sprite.translate Vector2f.({ x = -5. ; y =  0. })
        | S -> do_all Sprite.translate Vector2f.({ x =  0. ; y =  5. })
        | D -> do_all Sprite.translate Vector2f.({ x =  5. ; y =  0. })
        (* Do a slow barrel roll *)
        | O -> do_all Sprite.rotate (-0.4)
        | P -> do_all Sprite.rotate 0.4
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
    Window.clear ~color:(Some (`RGB Color.RGB.white)) window ;
    draw () ;
    Window.display window ;
    handle_events () ;
    each_frame ()
  end

let () = each_frame ()
