open OgamlGraphics
open OgamlCore
open OgamlUtils
open OgamlMath

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
          ~position:(Vector2f.from_int p)
          ~amount:20
          ~radius:2.
          ~origin:(Vector2f.{x = 2.; y = 2.})
          ~color:(`RGB Color.RGB.({r = 1.; g = 0.; b = 0.; a = alpha}))
          ()
      in
      Shape.draw (module Window) ~target:win ~shape:circle ();
      true
    end

  let display win s font = 
    let rule_text1 = 
      Text.create 
        ~font 
        ~text:" : right click" 
        ~size:15 
        ~bold:false 
        ~position:Vector2f.({x = 35.; y = 25.}) ()
    in
    let rule_text2 = 
      Text.create 
        ~font 
        ~text:" : left click" 
        ~size:15 
        ~bold:false 
        ~position:Vector2f.({x = 35.; y = 55.}) ()
    in
    let rule_square1 = 
      Shape.create_rectangle 
        ~position:Vector2f.({x = 10.; y = 10.})
        ~size:Vector2f.({x = 20.; y = 20.}) 
        ~color:(`RGB Color.RGB.blue) ()
    in
    let rule_square2 = 
      Shape.create_rectangle 
        ~position:Vector2f.({x = 10.; y = 40.})
        ~size:Vector2f.({x = 20.; y = 20.}) 
        ~color:(`RGB Color.RGB.green) ()
    in
    let score_text1 = 
      Text.create
        ~font
        ~text:(Printf.sprintf "Clicked rectangles : %i" s.count)
        ~size:15
        ~bold:false
        ~position:Vector2f.({x = 500.; y = 25.}) ()
    in
    let score_text2 = 
      Text.create
        ~font
        ~text:(Printf.sprintf "Missed clicks : %i" s.missed)
        ~size:15
        ~bold:false
        ~position:Vector2f.({x = 500.; y = 55.}) ()
    in
    let score_text3 = 
      Text.create
        ~font
        ~text:(Printf.sprintf "Avg time per rectangle : %f" ((Unix.gettimeofday () -. s.starting_time) /. (float_of_int s.count)))
        ~size:15
        ~bold:false
        ~position:Vector2f.({x = 500.; y = 85.}) ()
    in
    let score_text4 = 
      Text.create
        ~font
        ~text:(Printf.sprintf "Hit ratio : %f" ((float_of_int s.count)/.(float_of_int (s.count + s.missed))))
        ~size:15
        ~bold:false
        ~position:Vector2f.({x = 500.; y = 115.}) ()
    in
    let click_square = 
      Shape.create_rectangle
        ~position:(IntRect.position s.curr_rect |> Vector2f.from_int)
        ~size:(IntRect.size s.curr_rect |> Vector2f.from_int)
        ~color:(`RGB (if s.right_click then Color.RGB.blue else Color.RGB.green))
        ()
    in
    Shape.draw (module Window) ~target:win ~shape:rule_square1 ();
    Text.draw  (module Window) ~target:win ~text:rule_text1 ();
    Shape.draw (module Window) ~target:win ~shape:rule_square2 ();
    Text.draw  (module Window) ~target:win ~text:rule_text2 ();
    Shape.draw (module Window) ~target:win ~shape:click_square ();
    Text.draw (module Window) ~target:win ~text:score_text1 ();
    Text.draw (module Window) ~target:win ~text:score_text2 ();
    Text.draw (module Window) ~target:win ~text:score_text3 ();
    Text.draw (module Window) ~target:win ~text:score_text4 ();
    s.last_hits <- List.filter (display_hit win) s.last_hits
    
end

let window = Window.create ~width:800 ~height:600 ~title:"Shoot !" ()

let state = GameState.create ()

let font = Font.load "examples/font1.ttf"

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
    Window.clear ~color:(Some (`RGB Color.RGB.white)) window ;
    GameState.display window state font;
    Window.display window;
    event_loop ();
    main_loop ()
  end

let () = main_loop ()
