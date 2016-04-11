open OgamlGraphics
open OgamlMath

let settings = OgamlCore.ContextSettings.create ()

let () = 
  Random.self_init ()

let window =
  Window.create ~width:900 ~height:600 ~settings ~title:"Sprite Example" ()

let texture = Texture.Texture2D.create (`File "examples/mario-block.bmp")

let texture_png = Texture.Texture2D.create (`File "examples/test.png")

let frames = ref 0

let sum_render = ref 0. 

let draw () =
  let t = Unix.gettimeofday () in
  for i = 0 to 1000 do
    let sprite = Sprite.create ~texture ~position:(Vector2f.({x = Random.float 800.; y = Random.float 500.})) ~origin:(Vector2f.({x=25.;y=25.})) () in
    Sprite.draw ~window ~sprite ()
  done;
  let dt = Unix.gettimeofday () -. t in
  incr frames;
  sum_render := dt +. !sum_render

let do_all action param = ()

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
    Window.clear ~color:(`RGB Color.RGB.white) window ;
    draw () ;
    Window.display window ;
    handle_events () ;
    each_frame ()
  end

let () = each_frame ();
  Printf.printf "Avg. time per frame : %.5fs\n%!" (!sum_render /. (float_of_int !frames))

