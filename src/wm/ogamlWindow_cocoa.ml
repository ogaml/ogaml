module Event = struct

  type t =
    | Closed
    | KeyPressed
    | KeyReleased
    | ButtonPressed
    | ButtonReleased
    | MouseMoved

end


module Window = struct

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

  let size win = 0,0

  let is_open win = true

  let poll_event win = None

end
