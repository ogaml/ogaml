open OgamlMath
open OgamlUtils
open OgamlCore
open OgamlGraphics

let settings = ContextSettings.create ~msaa:8 ()

let window = Window.create ~width:800 ~height:600 ~title:"Interpolators" ~settings ()

let rec draw_curve color = function
  |(x1,y1)::(x2,y2)::t -> 
    let x1', y1', x2', y2' = 
      (x1 *. 400. +. 200.  ),
      (500. -. (y1 *. 400.)),
      (x2 *. 400. +. 200.  ),
      (500. -. (y2 *. 400.))
    in
    let l = Shape.create_line 
                ~thickness:1.5 
                ~color 
                ~top:Vector2f.({x = x1'; y = y1'}) 
                ~tip:Vector2f.({x = x2'; y = y2'}) ()
    in
    Shape.draw (module Window) ~target:window ~shape:l ();
    draw_curve color ((x2,y2)::t)
  | _ -> ()

let curve_ip ip mini maxi step = 
  let rec aux t = 
    if t >= maxi then [maxi, Interpolator.get ip maxi]
    else (t, Interpolator.get ip t) :: (aux (t +. step))
  in aux mini

let draw_ip ip color = 
  draw_curve color (curve_ip ip (-0.2) 1.2 0.01)

let draw_grid () = 
  let abs = Shape.create_line
                ~thickness:1.5
                ~color:(`RGB Color.RGB.black)
                ~top:Vector2f.({x = 40.; y = 500.})
                ~tip:Vector2f.({x = 760.; y = 500.})
                ()
  in
  let ord = Shape.create_line
                ~thickness:1.5
                ~color:(`RGB Color.RGB.black)
                ~top:Vector2f.({x = 200.; y = 40.})
                ~tip:Vector2f.({x = 200.; y = 560.})
                ()
  in
  let onex = Shape.create_line
                ~thickness:1.5
                ~color:(`RGB Color.RGB.black)
                ~top:Vector2f.({x = 600.; y = 505.})
                ~tip:Vector2f.({x = 600.; y = 495.})
                ()
  in
  let oney = Shape.create_line
                ~thickness:1.5
                ~color:(`RGB Color.RGB.black)
                ~top:Vector2f.({x = 195.; y = 100.})
                ~tip:Vector2f.({x = 205.; y = 100.})
                ()
  in
  Shape.draw (module Window) ~target:window ~shape:abs ();
  Shape.draw (module Window) ~target:window ~shape:ord ();
  Shape.draw (module Window) ~target:window ~shape:onex ();
  Shape.draw (module Window) ~target:window ~shape:oney ()

let ip1 = Interpolator.linear 0.5 [] 0.7 

let ip2 = Interpolator.cst_linear 0.2 [0.9; 0.5] 0.6 |> Interpolator.repeat

let ip3 = Interpolator.linear 0.2 [(0.3,0.9); (0.9,0.8)] 0.6 |> Interpolator.loop

let ip4 = Interpolator.cubic (0.5,0.0) [] (0.7,0.0)

let ip5 = Interpolator.cst_cubic (0.2, 0.0) [0.9; 0.5] (0.6, 0.0) |> Interpolator.repeat

let ip6 = Interpolator.cubic (0.2, 0.0) [(0.3,0.9); (0.9,0.8)] (0.6, 0.0) |> Interpolator.loop

let draw () = 
  draw_grid ();
  draw_ip ip1 (`RGB Color.RGB.red);
  draw_ip ip2 (`RGB Color.RGB.blue);
  draw_ip ip3 (`RGB Color.RGB.green);
  draw_ip ip4 (`RGB Color.RGB.magenta);
  draw_ip ip5 (`RGB Color.RGB.cyan);
  draw_ip ip6 (`RGB Color.RGB.yellow)

let rec event_loop () =
  let open OgamlCore in
  match Window.poll_event window with
  | Some e -> Event.(
      match e with
      | Closed -> Window.close window
      | _      -> ()
    ) ; event_loop ()
  | None -> ()

let rec main_loop () =
  if Window.is_open window then begin
    Window.clear ~color:(`RGB Color.RGB.white) window ;
    draw ();
    Window.display window ;
    event_loop () ;
    main_loop ()
  end

let () = 
  main_loop ();
  print_endline "OK";
  Window.destroy window

