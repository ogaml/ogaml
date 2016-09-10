open OgamlGraphics
open OgamlMath

(* FPS counting *)
let initial_time = ref 0.
let frame_count  = ref 0

let settings = OgamlCore.ContextSettings.create ~msaa:8 ()

let window =
  Window.create ~width:800 ~height:600 ~settings ~title:"Font sets tests" ()

let font = Font.load "examples/font1.ttf"

let size = 25

let txt = Text.create
  ~text:"Hello, World ! Coucou ! gAV@#"
  ~position:Vector2f.({x = 50.; y = 50. +. (Font.ascent font 50)})
  ~font
  ~size:50
  ~bold:false
  ()

let txt2 = Text.create
  ~text:"Unicode is working, YEAAH !!! "
  ~position:Vector2f.({x = 50.; y = 150. +. (Font.ascent font 50)})
  ~font
  ~size:50
  ~bold:false
  ()

let txt2' = Text.create
  ~text:"(•_•)  ( •_•)>⌐■-■  (⌐■_■)"
  ~position:Vector2f.({x = 50.; y = 250. +. (Font.ascent font 50)})
  ~font
  ~size:50
  ~bold:false
  ()

let txt3pos = Vector2f.({ x = 50. ; y = 500. })

let txt3 = Text.create
  ~text:"Trying to see if\nadvance......"
  ~position:txt3pos
  ~font
  ~size
  ~bold:false
  ()

let txt4 = Text.create
  ~text:"and boundaries\nare working."
  ~position:(Vector2f.add (Text.advance txt3) txt3pos)
  ~font
  ~size
  ~bold:false
  ()

let boundaries4 = Text.boundaries txt4

let border4 = Shape.create_rectangle
  ~position:(FloatRect.position boundaries4)
  ~size:(FloatRect.size boundaries4)
  ~color:(`RGB Color.RGB.transparent)
  ~border_color:(`RGB Color.RGB.blue)
  ~thickness:2.
  ()

let border = Shape.create_rectangle
  ~position:Vector2f.({x = 50.; y = 50.})
  ~size:Vector2f.({x = 600.; y = 50.})
  ~color:(`RGB Color.RGB.transparent)
  ~border_color:(`RGB Color.RGB.red)
  ~thickness:2.
  ()

let random_color =
  Random.self_init () ;
  fun () ->
    `RGB Color.RGB.({
      r = Random.float 1. ;
      g = Random.float 1. ;
      b = Random.float 1. ;
      a = 1.
    })

let fxpos = Vector2f.({ x = 10. ; y = 350. })

let fxtxt1 = Text.Fx.create
  (module Window)
  ~target:window
  ~text:"Awesome text!"
  ~position:fxpos
  ~font
  ~size
  ~colors:(Text.Fx.forall (random_color ()))
  ()

let fxpos2 = Vector2f.add (Text.Fx.advance fxtxt1) fxpos

let fxtxt2 = Text.Fx.create
  (module Window)
  ~target:window
  ~text:"Success!!!"
  ~position:fxpos2
  ~font
  ~size
  ~colors:(let sc = random_color () and dc = random_color () in
    Text.Fx.foreach
      (function `Code i when i = Char.code 's' -> sc | _ -> dc)
    )
  ()

let fxpos3 = Vector2f.add (Text.Fx.advance fxtxt2) fxpos2

(* let fxtxt3 = Text.Fx.create
  ~text:"This time we separate words a bit to check everything works."
  ~position:fxpos3
  ~font
  ~size
  ~colors:(Text.Fx.foreachword (fun w -> random_color ()) (random_color ()))
  () *)

let aa = ref false

let draw () =
  (* Trying computing each frame *)
  let fxtxt3 = Text.Fx.create
    (module Window)
    ~target:window
    ~text:"This time we separate words a bit to check everything works."
    ~position:fxpos3
    ~font
    ~size
    ~colors:(Text.Fx.foreachword (fun w -> random_color ()) (random_color ()))
    ()
  in
  let parameters = DrawParameter.make
                      ~antialiasing:!aa
                      ~blend_mode:(DrawParameter.BlendMode.alpha)
                      ()
  in
  Text.draw (module Window) ~parameters ~target:window ~text:txt ();
  Text.draw (module Window) ~parameters ~target:window ~text:txt2 ();
  Text.draw (module Window) ~parameters ~target:window ~text:txt2' ();
  Text.draw (module Window) ~parameters ~target:window ~text:txt3 ();
  Text.draw (module Window) ~parameters ~target:window ~text:txt4 ();
  Text.Fx.draw (module Window) ~parameters ~target:window ~text:fxtxt1 ();
  Text.Fx.draw (module Window) ~parameters ~target:window ~text:fxtxt2 ();
  Text.Fx.draw (module Window) ~parameters ~target:window ~text:fxtxt3 ();
  Shape.draw (module Window) ~parameters ~target:window ~shape:border ();
  Shape.draw (module Window) ~parameters ~target:window ~shape:border4 ()

let rec event_loop () =
  match Window.poll_event window with
  | Some e -> OgamlCore.(Event.(
    match e with
    | Closed -> Window.close window
    | KeyPressed ev -> begin
      match ev.KeyEvent.key with
      | Keycode.A -> aa := not !aa
      | _ -> ()
    end ; event_loop ()
    | _     -> event_loop ()
  ))
  | None -> ()

let rec main_loop () =
  if Window.is_open window then begin
    Window.clear ~color:(Some (`RGB Color.RGB.magenta)) window ;
    draw () ;
    Window.display window ;
    event_loop () ;
    incr frame_count ;
    main_loop ()
  end

let () =
  initial_time := Unix.gettimeofday () ;
  main_loop () ;
  Printf.printf
    "Avg FPS: %f\n%!"
    (float_of_int (!frame_count) /. (Unix.gettimeofday () -. !initial_time)) ;
  Window.destroy window
