open OgamlGraphics
open OgamlCore
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

module GameState = struct

  type t = {
    mutable curr_rect : IntRect.t;
    mutable right_click : bool;
    mutable count : int;
    mutable missed : int;
    starting_time : float;
    mutable last_hits : (float * Vector2i.t) list;
  }
  
  let gen_rect () = 
    let x = Random.int 760 in
    let y = Random.int 460 + 100 in
    let width = Random.int 30 + 10 in
    let height = Random.int 30 + 10 in
    IntRect.({x;y;width;height})

  let create () = 
    Random.self_init ();
    {
      curr_rect = gen_rect ();
      right_click = Random.bool ();
      count = 0;
      missed = 0;
      starting_time = Unix.gettimeofday ();
      last_hits = []
    }

  let increment s = 
    s.count <- s.count + 1;
    s.right_click <- Random.bool ();
    s.curr_rect <- gen_rect ()

  let add_hit s p = 
    s.last_hits <- (Unix.gettimeofday (), p)::s.last_hits

  let on_event s e = 
    let open Event in
    match e with
    | ButtonPressed {ButtonEvent.button = Button.Left; position; _} ->
      add_hit s position;
      if IntRect.contains ~strict:true s.curr_rect position 
      && s.right_click = false then 
        increment s
      else
        s.missed <- s.missed + 1
    | ButtonPressed {ButtonEvent.button = Button.Right; position; _} ->
      add_hit s position;
      if IntRect.contains ~strict:true s.curr_rect position 
      && s.right_click = true then 
        increment s
      else
        s.missed <- s.missed + 1
    | _ -> ()

  let fade_interpolator = Interpolator.linear 1. [(3./.5.,1.)] 0. 

  let display_hit win (t,p) = 
    if Unix.gettimeofday () -. t >= 5. then false
    else begin
      let alpha = 
        Interpolator.get fade_interpolator ((Unix.gettimeofday () -. t)/.5.)
      in
      let circle = 
        Shape.create_regular
          ~transform:(Transform2D.create 
            ~position:(Vector2f.from_int p)
            ~origin:(Vector2f.{x = 2.; y = 2.}) ())
          ~amount:20
          ~radius:2.
          ~color:(`RGB Color.RGB.({r = 1.; g = 0.; b = 0.; a = alpha}))
          ()
      in
      Shape.draw (module Window) ~target:win ~shape:circle ();
      true
    end

  let text_handler txt = 
    Result.handle (function
      | `Invalid_UTF8_bytes -> fail "Invalid UTF8 sequence"
      | `Invalid_UTF8_leader -> fail "Invalid UTF8") txt

  let display win s font = 
    let rule_text1 = 
      OgamlGraphics.Text.create 
        ~font 
        ~text:" : right click" 
        ~size:15 
        ~bold:false 
        ~position:Vector2f.({x = 35.; y = 25.}) ()
        |> text_handler
    in
    let rule_text2 = 
      OgamlGraphics.Text.create 
        ~font 
        ~text:" : left click" 
        ~size:15 
        ~bold:false 
        ~position:Vector2f.({x = 35.; y = 55.}) ()
        |> text_handler
    in
    let rule_square1 = 
      Shape.create_rectangle 
        ~transform:(Transform2D.create ~position:Vector2f.({x = 10.; y = 10.}) ())
        ~size:Vector2f.({x = 20.; y = 20.}) 
        ~color:(`RGB Color.RGB.blue) ()
    in
    let rule_square2 = 
      Shape.create_rectangle 
        ~transform:(Transform2D.create ~position:Vector2f.({x = 10.; y = 40.}) ())
        ~size:Vector2f.({x = 20.; y = 20.}) 
        ~color:(`RGB Color.RGB.green) ()
    in
    let score_text1 = 
      OgamlGraphics.Text.create
        ~font
        ~text:(Printf.sprintf "Clicked rectangles : %i" s.count)
        ~size:15
        ~bold:false
        ~position:Vector2f.({x = 500.; y = 25.}) ()
        |> text_handler
    in
    let score_text2 = 
      OgamlGraphics.Text.create
        ~font
        ~text:(Printf.sprintf "Missed clicks : %i" s.missed)
        ~size:15
        ~bold:false
        ~position:Vector2f.({x = 500.; y = 55.}) ()
        |> text_handler
    in
    let score_text3 = 
      OgamlGraphics.Text.create
        ~font
        ~text:(Printf.sprintf "Avg time per rectangle : %f" ((Unix.gettimeofday () -. s.starting_time) /. (float_of_int s.count)))
        ~size:15
        ~bold:false
        ~position:Vector2f.({x = 500.; y = 85.}) ()
        |> text_handler
    in
    let score_text4 = 
      OgamlGraphics.Text.create
        ~font
        ~text:(Printf.sprintf "Hit ratio : %f" ((float_of_int s.count)/.(float_of_int (s.count + s.missed))))
        ~size:15
        ~bold:false
        ~position:Vector2f.({x = 500.; y = 115.}) ()
        |> text_handler
    in
    let click_square = 
      Shape.create_rectangle
        ~transform:(Transform2D.create 
          ~position:(IntRect.position s.curr_rect |> Vector2f.from_int) ())
        ~size:(IntRect.size s.curr_rect |> Vector2f.from_int)
        ~color:(`RGB (if s.right_click then Color.RGB.blue else Color.RGB.green))
        ()
    in
    Shape.draw (module Window) ~target:win ~shape:rule_square1 ();
    OgamlGraphics.Text.draw  (module Window) ~target:win ~text:rule_text1 () |> Result.assert_ok;
    Shape.draw (module Window) ~target:win ~shape:rule_square2 ();
    OgamlGraphics.Text.draw  (module Window) ~target:win ~text:rule_text2 () |> Result.assert_ok;
    Shape.draw (module Window) ~target:win ~shape:click_square ();
    OgamlGraphics.Text.draw (module Window) ~target:win ~text:score_text1 () |> Result.assert_ok;
    OgamlGraphics.Text.draw (module Window) ~target:win ~text:score_text2 () |> Result.assert_ok;
    OgamlGraphics.Text.draw (module Window) ~target:win ~text:score_text3 () |> Result.assert_ok;
    OgamlGraphics.Text.draw (module Window) ~target:win ~text:score_text4 () |> Result.assert_ok;
    s.last_hits <- List.filter (display_hit win) s.last_hits
    
end

let window = 
  match Window.create ~width:800 ~height:600 ~title:"Shoot !" () with
  | Ok win -> win
  | Error (`Context_initialization_error msg) -> 
    fail ~msg "Failed to create context"
  | Error (`Window_creation_error msg) -> 
    fail ~msg "Failed to create window"


let state = GameState.create ()

let font = 
  match Font.load "examples/font1.ttf" with
  | Ok font -> font
  | Error (`File_not_found f) -> fail ("Cannot open font file " ^ f)
  | Error `Invalid_font_file -> fail "Invalid font file"

let rec event_loop () =
  match Window.poll_event window with
  | Some e -> Event.(
      match e with
      | Closed -> 
        Window.close window
      | KeyPressed {KeyEvent.key = Keycode.Q; control = true; _} -> 
        Window.close window
      | _ -> GameState.on_event state e
    ) ; event_loop ()
  | None -> ()

let rec main_loop () =
  if Window.is_open window then begin
    Window.clear ~color:(Some (`RGB Color.RGB.white)) window |> Result.assert_ok;
    GameState.display window state font;
    Window.display window;
    event_loop ();
    main_loop ()
  end

let () = main_loop ()
