type t = Cocoa.OGWindowController.t

(* Create the application on first window *)
let init_app =
  let launched = ref false in
  fun () ->
    if not !launched then begin
      Cocoa.(
        (* Create an application and its delegate *)
        OGApplication.init (OGApplicationDelegate.create ()) ;
        (* Creating an AutoReleasePool *)
        init_arp ()
      ) ;
      launched := true
    end

let create ~width ~height =
  init_app () ;

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
    NSWindow.set_background_color window (NSColor.green ()) ;
    NSWindow.make_key_and_order_front window;
    NSWindow.center window ;
    (* NSWindow.make_main window ; *)
    (* Set some delegate for the window? *)
    NSWindow.set_for_events window ;
    NSWindow.set_autodisplay window true
  );

  (* Creating the delegate which we will return *)
  Cocoa.OGWindowController.init_with_window window

let close win =
  (* Cocoa.NSWindow.perform_close win *)
  ()

let destroy win = ()

let size win =
  let i = int_of_float in
  Cocoa.(
    let (_,_,w,h) = NSRect.get (Cocoa.OGWindowController.frame win)
    in i w, i h
  )

let is_open win = true

let poll_event win =
  (* TODO Make real use of it *)
  Cocoa.OGWindowController.process_event win ;
  (* match Cocoa.NSWindow.next_event win with
  | Some event ->
      Cocoa.NSEvent.(
        match get_type event with
        | KeyDown       -> Some Event.KeyPressed
        | KeyUp         -> Some Event.KeyReleased
        | LeftMouseDown -> Some Event.ButtonPressed
        | LeftMouseUp   -> Some Event.ButtonReleased
        | MouseMoved    -> Some Event.MouseMoved
        | _             -> None
      )
  | None -> None *)
  None
