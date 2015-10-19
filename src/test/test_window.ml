open OgamlWindow

let win = Window.create ~width:800 ~height:600

let rec event_loop () = 
  match Window.poll_event win with
  |Some e -> begin
    match e with
    |Event.Closed -> 
      Window.close win; 
      print_endline "window closed"
    |Event.KeyPressed ->
      print_endline "key pressed"
    |Event.ButtonPressed ->
      print_endline "button pressed"
    | _ -> ()
  end; event_loop ()
  |None -> ()

let rec main_loop () = 
  if Window.is_open win then begin
    event_loop ();
    main_loop ()
  end

let () = 
  main_loop ();
  Window.destroy win
