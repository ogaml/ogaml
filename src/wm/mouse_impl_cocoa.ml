let position () =
  (* let (x,y) = Cocoa.NSEvent.mouse_location () in
  let (_,screen_height) = Cocoa.screen_size () in
  let i = int_of_float in
  i x , i (screen_height -. y) *)
  (* i x , i y *)
  let (x,y) = Cocoa.NSEvent.proper_mouse_location () in
  let i = int_of_float in
  i x , i y

let relative_position win =
  (* This doesn't seem to work *)
  (* let (x,y) = Cocoa.OGWindowController.mouse_location win in
  let i = int_of_float in
  i x , i (y +. 34.) *)
  (* let (x,y) = position () in
  Printf.printf "pos : %d,%d\n%!" x y ;
  let frame = Cocoa.OGWindowController.frame win in
  let (dx, dy, _, _) = Cocoa.NSRect.get frame in
  Printf.printf "frame pos : %f,%f\n%!" dx dy ;
  let content_frame = Cocoa.OGWindowController.content_frame win in
  let (cdx, cdy, _, _) = Cocoa.NSRect.get frame in
  Printf.printf "content frame pos : %f,%f\n%!" cdx cdy ;
  let f = float_of_int in
  let i = int_of_float in
  i ((f x) -. dx), i ((f y) -. dy) *)
  (* let (x,y) = Cocoa.NSEvent.mouse_location () in
  let content_frame = Cocoa.OGWindowController.content_frame win in
  let (dx, dy, _, h) = Cocoa.NSRect.get content_frame in
  let i = int_of_float in
  i (x -. dx) , i (h -. (y -. dy)) *)
  (* i (x -. dx) , i (y -. dy) *)
  let (x,y) = Cocoa.OGWindowController.proper_relative_mouse_location win in
  let i = int_of_float in
  i x , i y

let set_position (x,y) =
  (* let (_,screen_height) = Cocoa.screen_size () in
  let f = float_of_int in
  (* Cocoa.Mouse.warp (f x) (screen_height -. (f y)) *)
  Cocoa.Mouse.warp (f x) (f y) *)
  let f = float_of_int in
  Cocoa.Mouse.warp (f x) (f y)

let set_relative_position win (x,y) =
  (* let frame = Cocoa.OGWindowController.content_frame win in
  let (dx, dy, _, h) = Cocoa.NSRect.get frame in
  let f = float_of_int in
  (* Cocoa.Mouse.warp ((f x) +. dx) (h -. ((f y) +. dy)) *)
  Cocoa.Mouse.warp ((f x) +. dx) ((f y) +. dy) *)
  let f = float_of_int in
  Cocoa.OGWindowController.set_proper_relative_mouse_location win (f x) (f y)

let is_pressed button =
  let pressed_buttons = Cocoa.NSEvent.pressed_mouse_buttons () in
  let conv = Cocoa.NSEvent.(function
    | ButtonLeft  -> Button.Left
    | ButtonRight -> Button.Right
    | ButtonOther -> Button.Middle
  ) in
  List.mem button (List.map conv pressed_buttons)
