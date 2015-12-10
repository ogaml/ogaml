open OgamlGraphics
open OgamlMath

let settings = OgamlCore.ContextSettings.create ~msaa:8 ()

let window =
  Window.create ~width:800 ~height:600 ~settings ~title:"Font sets tests"

let font = Font.load "examples/font1.ttf"

let txt = Text.create
  ~text:"Hello, World ! Coucou ! gAV@#"
  ~position:Vector2i.({x = 50; y = 50 + (int_of_float (Font.ascent font 50))})
  ~font
  ~size:50
  ~bold:false

let txt2 = Text.create
  ~text:"Unicode is working, YEAAH !!! "
  ~position:Vector2i.({x = 50; y = 150 + (int_of_float (Font.ascent font 50))})
  ~font
  ~size:50
  ~bold:false

let txt2' = Text.create
  ~text:"(•_•)  ( •_•)>⌐■-■  (⌐■_■)"
  ~position:Vector2i.({x = 50; y = 250 + (int_of_float (Font.ascent font 50))})
  ~font
  ~size:50
  ~bold:false

let txt3pos = Vector2i.({ x = 50 ; y = 500 })

let txt3 = Text.create
  ~text:"Trying to see if advance......"
  ~position:txt3pos
  ~font
  ~size:50
  ~bold:false

let txt4 = Text.create
  ~text:"and boundaries are working."
  ~position:(Vector2i.add (Vector2f.floor (Text.advance txt3)) txt3pos)
  ~font
  ~size:50
  ~bold:false

let boundaries4 = Text.boundaries txt4

let border4 = Shape.create_rectangle
  ~position:(Vector2f.floor (FloatRect.position boundaries4))
  ~size:(Vector2f.floor (FloatRect.size boundaries4))
  ~color:(`RGB Color.RGB.transparent)
  ~border_color:(`RGB Color.RGB.blue)
  ~thickness:2.
  ()

let border = Shape.create_rectangle
  ~position:Vector2i.({x = 50; y = 50})
  ~size:Vector2i.({x = 600; y = 50})
  ~color:(`RGB Color.RGB.transparent)
  ~border_color:(`RGB Color.RGB.red)
  ~thickness:2.
  ()

let aa = ref true

let draw () =
  let parameters = DrawParameter.make
                      ~depth_test:false
                      ~antialiasing:!aa
                      ~blend_mode:(DrawParameter.BlendMode.alpha)
                      ()
  in
  Text.draw ~parameters ~window ~text:txt ();
  Text.draw ~parameters ~window ~text:txt2 ();
  Text.draw ~parameters ~window ~text:txt2' ();
  Text.draw ~parameters ~window ~text:txt3 ();
  Text.draw ~parameters ~window ~text:txt4 ();
  Shape.draw ~parameters ~window ~shape:border ();
  Shape.draw ~parameters ~window ~shape:border4 ()

let rec event_loop () =
  match Window.poll_event window with
  |Some e -> OgamlCore.(Event.(
    match e with
    |Closed -> Window.close window
    |KeyPressed ev -> begin
      match ev.KeyEvent.key with
      |Keycode.A -> aa := not !aa
      | _ -> ()
    end; event_loop ()
    | _     -> event_loop ()
  ))
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
