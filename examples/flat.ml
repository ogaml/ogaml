open OgamlGraphics
open OgamlMath

let settings = ContextSettings.create ~color:(`RGB Color.RGB.white) ()
let window = Window.create ~width:900 ~height:600 ~settings

let rectangle1 =
  Shape.create_rectangle
    ~position:Vector2i.({ x = 50 ; y = 75 })
    ~size:Vector2i.({ x = 200 ; y = 150 })
    ~color:(`RGB Color.RGB.blue)
    ()

let rectangle2 =
  Shape.create_rectangle
    ~position:Vector2i.({ x = 150 ; y = 450 })
    ~size:Vector2i.({ x = 200 ; y = 150 })
    ~origin:Vector2f.({ x = 100. ; y = 75. })
    ~color:(`RGB Color.RGB.red)
    ()

let polygon1 =
  Shape.create_polygon
    ~points:Vector2i.([
      { x =   0 ; y =  80 } ;
      { x =  40 ; y =   0 } ;
      { x = 120 ; y =   0 } ;
      { x = 160 ; y =  80 } ;
      { x =  80 ; y = 160 }
    ])
    ~color:(`RGB Color.RGB.green)
    ~position:Vector2i.({ x = 370 ; y = 70 })
    ()

let polygon2 =
  Shape.create_polygon
    ~points:Vector2i.([
      { x =   0 ; y =  80 } ;
      { x =  40 ; y =   0 } ;
      { x = 120 ; y =   0 } ;
      { x = 160 ; y =  80 } ;
      { x =  80 ; y = 160 }
    ])
    ~color:(`RGB Color.RGB.magenta)
    ~origin:Vector2f.({ x = 80. ; y = 80. })
    ~position:Vector2i.({ x = 450 ; y = 450 })
    ()

let regular1 =
  Shape.create_regular
    ~position:Vector2i.({ x = 650 ; y = 50 })
    ~radius:100.
    ~amount:10
    ~color:(`RGB Color.RGB.cyan)
    ()

let regular2 =
  Shape.create_regular
    ~position:Vector2i.({ x = 750 ; y = 450 })
    ~radius:100.
    ~origin:Vector2f.({ x = 100. ; y = 100. })
    ~amount:10
    ~color:(`RGB Color.RGB.yellow)
    ()

let draw () =
  Window.draw_shape window rectangle1 ;
  Window.draw_shape window rectangle2 ;
  Window.draw_shape window polygon1 ;
  Window.draw_shape window polygon2 ;
  Window.draw_shape window regular1 ;
  Window.draw_shape window regular2

let do_all action param =
  action rectangle1 param ;
  action rectangle2 param ;
  action polygon1 param ;
  action polygon2 param ;
  action regular1 param ;
  action regular2 param

let gothicker shape yes =
  Shape.set_thickness
    shape
    ((Shape.get_thickness shape) +. if yes then 1. else (-1.))

let rec handle_events () =
  let open OgamlCore in
  match Window.poll_event window with
  | Some e -> Event.(
      match e with
      | Closed -> Window.close window
      | Event.KeyPressed k -> Keycode.(
        match k.Event.KeyEvent.key with
        | Q when k.Event.KeyEvent.control -> Window.close window
        (* Moving around all shapes *)
        | Z -> do_all Shape.translate Vector2i.({ x =  0 ; y = -5 })
        | Q -> do_all Shape.translate Vector2i.({ x = -5 ; y =  0 })
        | S -> do_all Shape.translate Vector2i.({ x =  0 ; y =  5 })
        | D -> do_all Shape.translate Vector2i.({ x =  5 ; y =  0 })
        (* Do a slow barrel roll *)
        | O -> do_all Shape.rotate (-5.)
        | P -> do_all Shape.rotate 5.
        (* Resizing *)
        | F -> do_all Shape.scale Vector2f.({ x = 0.8  ; y = 1.   })
        | H -> do_all Shape.scale Vector2f.({ x = 1.25 ; y = 1.   })
        | T -> do_all Shape.scale Vector2f.({ x = 1.   ; y = 1.25 })
        | G -> do_all Shape.scale Vector2f.({ x = 1.   ; y = 0.8  })
        (* This is thick! *)
        | V -> do_all gothicker false
        | B -> do_all gothicker true
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
