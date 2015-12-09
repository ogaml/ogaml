open OgamlGraphics
open OgamlMath

let settings = OgamlCore.ContextSettings.create ~msaa:8 ()

let window =
  Window.create ~width:800 ~height:600 ~settings ~title:"Font sets tests"

let font = Font.load "examples/font2.ttf"

let txt = Text.create 
  ~text:"Hello World ! Coucou ! gAV@#"
  ~position:Vector2i.({x = 50; y = 50})
  ~font
  ~size:20
  ~bold:false 

let border = Shape.create_rectangle
  ~position:Vector2i.({x = 50; y = 50})
  ~size:Vector2i.({x = 300; y = 20})
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
  Shape.draw ~parameters ~window ~shape:border ()

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
