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
  let win_ctrl = Cocoa.OGWindowController.init_with_window window in

  (* But first we create and apply a new openGL context *)
  let attr = Cocoa.NSOpenGLPixelFormat.([
    #ifdef __OSX__
    NSOpenGLPFAOpenGLProfile NSOpenGLProfileVersion3_2Core;
    #endif
    NSOpenGLPFAColorSize 24 ;
    NSOpenGLPFAAlphaSize 8  ;
    NSOpenGLPFADepthSize 24 ;
    NSOpenGLPFADoubleBuffer ;
    NSOpenGLPFAAccelerated
  ]) in
  let pixel_format = Cocoa.NSOpenGLPixelFormat.init_with_attributes attr in
  let context = Cocoa.NSOpenGLContext.init_with_format pixel_format in
  Cocoa.OGWindowController.set_context win_ctrl context ;

  (* Finally returning the window controller *)
  win_ctrl

let close win =
  Cocoa.OGWindowController.close_window win

let destroy win =
  Cocoa.OGWindowController.release_window win

let size win =
  let i = int_of_float in
  Cocoa.(
    let (_,_,w,h) = NSRect.get (Cocoa.OGWindowController.frame win)
    in i w, i h
  )

let is_open win =
  Cocoa.OGWindowController.is_window_open win

let poll_event win =
  Cocoa.OGWindowController.process_event win ;
  match Cocoa.OGWindowController.pop_event win with
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
  | None -> None

let display win =
  Cocoa.OGWindowController.flush_context win
