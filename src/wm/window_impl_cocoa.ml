type t = Cocoa.NSWindow.t

let create ~width ~height =
  (* Create an application and its delegate (should only be done once) *)
  Cocoa.(
    OGApplication.init (OGApplicationDelegate.create ())
  );

  (* Rect for setting the size -- offset is ignored we will center *)
  let rect = Cocoa.NSRect.create 0 0 width height in

  (* Now creating an NSWindow *)
  let window = Cocoa.NSWindow.(
    create ~frame:rect
            (* Might good to be modifiable later *)
            ~style_mask:[Titled;Closable;Miniaturizable;Resizable]
            ~backing:Buffered
            ~defer:false ()
  ) in

  (* Various settings *)
  Cocoa.(
    NSWindow.set_background_color window (NSColor.magenta ());
    NSWindow.make_key_and_order_front window;
    NSWindow.center window;
    NSWindow.make_main window
  );

  (* Now run the application *)
  Cocoa.OGApplication.run () ;

  window

let close win =
  Cocoa.NSWindow.perform_close win

let destroy win = ()

let size win =
  let i = int_of_float in
  Cocoa.(
    let (_,_,w,h) = NSRect.get (Cocoa.NSWindow.frame win)
    in i w, i h
  )

let is_open win = true

let poll_event win =
  let event = Cocoa.NSWindow.next_event win in
  Cocoa.NSEvent.(
    match get_type event with
    | KeyDown       -> Some Event.KeyPressed
    | KeyUp         -> Some Event.KeyReleased
    | LeftMouseDown -> Some Event.ButtonPressed
    | LeftMouseUp   -> Some Event.ButtonReleased
    | MouseMoved    -> Some Event.MouseMoved
    | _             -> None
  )
