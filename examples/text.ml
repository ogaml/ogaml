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
  ()

let txt2 = Text.create
  ~text:"Unicode is working, YEAAH !!! "
  ~position:Vector2i.({x = 50; y = 150 + (int_of_float (Font.ascent font 50))})
  ~font
  ~size:50
  ~bold:false
  ()

let txt2' = Text.create
  ~text:"(•_•)  ( •_•)>⌐■-■  (⌐■_■)"
  ~position:Vector2i.({x = 50; y = 250 + (int_of_float (Font.ascent font 50))})
  ~font
  ~size:50
  ~bold:false
  ()

let txt3pos = Vector2i.({ x = 50 ; y = 500 })

let txt3 = Text.create
  ~text:"Trying to see if\nadvance......"
  ~position:txt3pos
  ~font
  ~size:50
  ~bold:false
  ()

let txt4 = Text.create
  ~text:"and boundaries\nare working."
  ~position:(Vector2i.add (Vector2f.floor (Text.advance txt3)) txt3pos)
  ~font
  ~size:50
  ~bold:false
  ()

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

let fxtxt = Text.Fx.create
  ~text:"Awesome text!"
  ~position:Vector2f.({ x = 700. ; y = 700. })
  ~font
  ~size:25
  ~colors:(Text.Fx.forall (`RGB Color.RGB.yellow))
  (* ~colors:(
    (fun code v k ->
      match code with
      | `Code i when i = Char.code 's' || i = Char.code 't' ->
        k ((`RGB Color.RGB.red) :: v)
      | _ -> k ((`RGB Color.RGB.black) :: v)
    ),
    [],
    (fun x -> List.rev x)
  ) *)
  ()

let aa = ref false

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
  Text.Fx.draw ~parameters ~window ~text:fxtxt ();
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
    Window.clear ~color:(`RGB Color.RGB.magenta) window;
    draw ();
    Window.display window;
    event_loop ();
    main_loop ();
  end

let () =
  main_loop ()
