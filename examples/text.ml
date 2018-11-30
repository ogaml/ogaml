open OgamlGraphics
open OgamlMath
open OgamlUtils
open Result.Operators

let fail ?msg err = 
  Log.fatal Log.stdout "%s" err;
  begin match msg with
  | None -> ()
  | Some e -> Log.fatal Log.stderr "%s" e
  end;
  exit 2

let settings = OgamlCore.ContextSettings.create ~msaa:8 ()

let window =
  match Window.create ~width:800 ~height:600 ~settings ~title:"Font sets tests" () with
  | Ok win -> win
  | Error (`Context_initialization_error msg) -> 
    fail ~msg "Failed to create context"
  | Error (`Window_creation_error msg) -> 
    fail ~msg "Failed to create window"

let fps_clock = 
  Clock.create ()

let font = 
  match Font.load "examples/font1.ttf" with
  | Ok font -> font
  | Error (`File_not_found f) -> fail ("Cannot open font file " ^ f)
  | Error `Invalid_font_file -> fail "Invalid font file"

let size = 25

let text_handler txt = 
  Result.handle (function
    | `Invalid_UTF8_bytes -> fail "Invalid UTF8 sequence"
    | `Invalid_UTF8_leader -> fail "Invalid UTF8") txt

let txt = Text.create
  ~text:"Hello, World ! Coucou ! gAV@#"
  ~position:Vector2f.({x = 50.; y = 50. +. (Font.ascent font 50)})
  ~font
  ~size:50
  ~bold:false ()
  |> text_handler

let txt2 = Text.create
  ~text:"Unicode is working, YEAAH !!! "
  ~position:Vector2f.({x = 50.; y = 150. +. (Font.ascent font 50)})
  ~font
  ~size:50
  ~bold:false ()
  |> text_handler

let txt2' = Text.create
  ~text:"(•_•)  ( •_•)>⌐■-■  (⌐■_■)"
  ~position:Vector2f.({x = 50.; y = 250. +. (Font.ascent font 50)})
  ~font
  ~size:50
  ~bold:false ()
  |> text_handler

let txt3pos = Vector2f.({ x = 50. ; y = 500. })

let txt3 = Text.create
  ~text:"Trying to see if\nadvance......"
  ~position:txt3pos
  ~font
  ~size
  ~bold:false ()
  |> text_handler

let txt4 = Text.create
  ~text:"and boundaries\nare working."
  ~position:(Vector2f.add (Text.advance txt3) txt3pos)
  ~font
  ~size
  ~bold:false ()
  |> text_handler

let smltxtpos = Vector2f.({x = 30.; y = 400. })

let small_text = Text.create
  ~text:"Trying to render small text to check if it renders without too many artifacts.\nYou should be able to read this without difficulty."
  ~position:smltxtpos
  ~font
  ~size:12
  ~bold:false ()
  |> text_handler

let boundaries4 = Text.boundaries txt4

let border4 = Shape.create_rectangle
  ~position:(FloatRect.position boundaries4)
  ~size:(FloatRect.size boundaries4)
  ~color:(`RGB Color.RGB.transparent)
  ~border_color:(`RGB Color.RGB.blue)
  ~thickness:2. ()

let border = Shape.create_rectangle
  ~position:Vector2f.({x = 50.; y = 50.})
  ~size:Vector2f.({x = 600.; y = 50.})
  ~color:(`RGB Color.RGB.transparent)
  ~border_color:(`RGB Color.RGB.red)
  ~thickness:2. ()

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
  ~colors:(Text.Fx.forall (random_color ())) ()
  |> text_handler

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
    ) ()
  |> text_handler

let fxpos3 = Vector2f.add (Text.Fx.advance fxtxt2) fxpos2


(* let fxtxt3 = Text.Fx.create
  ~text:"This time we separate words a bit to check everything works."
  ~position:fxpos3
  ~font
  ~size
  ~colors:(Text.Fx.foreachword (fun w -> random_color ()) (random_color ()))
  () *)

let aa = ref false

let draw_handler arg = Result.handle (function
  | `Font_texture_depth_overflow -> fail "Font texture overflow (depth)"
  | `Font_texture_size_overflow -> fail "Font texture overflow (height)") arg

let draw () =
  (* Trying computing each frame *)
  let fxtxt3 = Text.Fx.create
    (module Window)
    ~target:window
    ~text:"This time we separate words a bit to check everything works."
    ~position:fxpos3
    ~font
    ~size
    ~colors:(Text.Fx.foreachword (fun w -> random_color ()) (random_color ())) ()
    |> text_handler
  in
  let parameters = DrawParameter.make
                      ~antialiasing:!aa
                      ~blend_mode:(DrawParameter.BlendMode.alpha)
                      ()
  in
  Text.draw (module Window) ~parameters ~target:window ~text:txt () >>= 
  Text.draw (module Window) ~parameters ~target:window ~text:txt2 >>= 
  Text.draw (module Window) ~parameters ~target:window ~text:txt2' >>=
  Text.draw (module Window) ~parameters ~target:window ~text:txt3 >>= 
  Text.draw (module Window) ~parameters ~target:window ~text:txt4 >>=
  Text.draw (module Window) ~parameters ~target:window ~text:small_text >>=
  Text.Fx.draw (module Window) ~parameters ~target:window ~text:fxtxt1 >>=
  Text.Fx.draw (module Window) ~parameters ~target:window ~text:fxtxt2 >>=
  Text.Fx.draw (module Window) ~parameters ~target:window ~text:fxtxt3
  |> draw_handler;
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
    Window.clear ~color:(Some (`RGB Color.RGB.magenta)) window |> Result.assert_ok;
    draw () ;
    Window.display window ;
    event_loop () ;
    Clock.tick fps_clock;
    main_loop ()
  end

let () =
  Clock.restart fps_clock;
  main_loop ();
  Printf.printf "Avg FPS: %f\n%!" (Clock.tps fps_clock);
  Window.destroy window
