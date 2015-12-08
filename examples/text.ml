open OgamlGraphics
open OgamlMath

let settings = OgamlCore.ContextSettings.create ()

let window =
  Window.create ~width:800 ~height:600 ~settings ~title:"Font sets tests"

let font = Font.load "examples/font1.ttf"

let txt = Text.create 
  ~text:"Hello World !" 
  ~position:Vector2i.({x = 50; y = 50})
  ~font
  ~size:50
  ~bold:false 

let sprite = Sprite.create
  ~position:Vector2i.({x = 50; y = 300})
  ~texture:(Font.texture font 50)
  ()

let draw () =
  Text.draw ~window ~text:txt ();
  Sprite.draw ~window ~sprite ()

let rec event_loop () =
  match Window.poll_event window with
  |Some e -> OgamlCore.Event.(
    match e with
    |Closed -> Window.close window
    | _     -> event_loop ()
  )
  |None -> ()

let rec main_loop () =
  if Window.is_open window then begin
    Window.clear ~color:(`RGB Color.RGB.black) window;
    draw ();
    Window.display window;
    event_loop ();
    main_loop ();
  end

let () =
  main_loop ()
