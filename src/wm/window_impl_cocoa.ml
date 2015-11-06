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
    let (_,_,w,h) = NSRect.get (Cocoa.OGWindowController.content_frame win)
    in i w, i h
  )

let is_open win =
  Cocoa.OGWindowController.is_window_open win

let has_focus win =
  true

let get_key_event event =
  let keycode = Keycode.(
    match Cocoa.NSString.get (Cocoa.NSEvent.character event) with
    | "a" | "A" -> A
    | "b" | "B" -> B
    | "c" | "C" -> C
    | "d" | "D" -> D
    | "e" | "E" -> E
    | "f" | "F" -> F
    | "g" | "G" -> G
    | "h" | "H" -> H
    | "i" | "I" -> I
    | "j" | "J" -> J
    | "k" | "K" -> K
    | "l" | "L" -> L
    | "m" | "M" -> M
    | "n" | "N" -> N
    | "o" | "O" -> O
    | "p" | "P" -> P
    | "q" | "Q" -> Q
    | "r" | "R" -> R
    | "s" | "S" -> S
    | "t" | "T" -> T
    | "u" | "U" -> U
    | "v" | "V" -> V
    | "w" | "W" -> W
    | "x" | "X" -> X
    | "y" | "Y" -> Y
    | "z" | "Z" -> Z
    | _ -> begin
        match Cocoa.NSEvent.key_code event with
        | 18  -> Num1
        | 19  -> Num2
        | 20  -> Num3
        | 21  -> Num4
        | 23  -> Num5
        | 22  -> Num6
        | 26  -> Num7
        | 28  -> Num8
        | 25  -> Num9
        | 29  -> Num0
        | 83  -> Numpad1
        | 84  -> Numpad2
        | 85  -> Numpad3
        | 86  -> Numpad4
        | 87  -> Numpad5
        | 88  -> Numpad6
        | 89  -> Numpad7
        | 91  -> Numpad8
        | 92  -> Numpad9
        | 82  -> Numpad0
        | 78  -> NumpadMinus
        | 67  -> NumpadTimes
        | 69  -> NumpadPlus
        | 75  -> NumpadDiv
        | 65  -> NumpadDot
        | 76  -> NumpadReturn
        | 53  -> Escape
        | 48  -> Tab
        | 55  -> LControl
        (* | 59  -> LControl -- here actual ctrl *)
        | 56  -> LShift
        | 58  -> LAlt
        | 49  -> Space
        (* | 55  -> RControl -- oh... *)
        | 36  -> Return
        | 117 -> Delete
        | 126 -> Up
        | 123 -> Left
        | 125 -> Down
        | 124 -> Right
        | 122 -> F1
        | 120 -> F2
        | 99  -> F3
        | 118 -> F4
        | 96  -> F5
        | 97  -> F6
        | 98  -> F7
        | 100 -> F8
        | 101 -> F9
        | 109 -> F10
        | 103 -> F11
        | 111 -> F12
        | _   -> Unknown
    end
  ) in
  let modifiers = Cocoa.NSEvent.modifier_flags () in
  let (shift,control,alt) = Cocoa.NSEvent.(
    List.mem NSShiftKeyMask     modifiers,
    List.mem NSCommandKeyMask   modifiers,
    List.mem NSAlternateKeyMask modifiers
  ) in
  Event.KeyEvent.({
    key = keycode ; shift = shift ; control = control ; alt = alt
  })

let make_mouse_event button event win =
  let (x,y) = Cocoa.OGWindowController.proper_relative_mouse_location win in
  let modifiers = Cocoa.NSEvent.modifier_flags () in
  let (shift,control,alt) = Cocoa.NSEvent.(
    List.mem NSShiftKeyMask     modifiers,
    List.mem NSCommandKeyMask   modifiers,
    List.mem NSAlternateKeyMask modifiers
  ) in
  let i = int_of_float in
  Event.ButtonEvent.({
    button = button ;
    x = i x ;
    y = i y ;
    shift = shift ;
    control = control ;
    alt = alt
  })

let mouse_loc win =
  let (x,y) = Cocoa.OGWindowController.proper_relative_mouse_location win in
  let i = int_of_float in
  Event.MouseEvent.({ x = i x ; y = i y })

let poll_event win =
  Cocoa.OGWindowController.process_event win ;
  match Cocoa.OGWindowController.pop_event win with
  | Some ogevent ->
      Cocoa.(
        match OGEvent.get_content ogevent with
        | OGEvent.CocoaEvent event ->
            NSEvent.(
              match get_type event with
              | KeyDown        -> Some (Event.KeyPressed (get_key_event event))
              | KeyUp          -> Some (Event.KeyReleased (get_key_event event))
              | LeftMouseDown  -> Some (Event.ButtonPressed (
                  make_mouse_event Button.Left event win
                ))
              | RightMouseDown -> Some (Event.ButtonPressed (
                  make_mouse_event Button.Right event win
                ))
              | OtherMouseDown -> Some (Event.ButtonPressed (
                  make_mouse_event Button.Middle event win
                ))
              | LeftMouseUp    -> Some (Event.ButtonReleased (
                  make_mouse_event Button.Left event win
                ))
              | RightMouseUp   -> Some (Event.ButtonReleased (
                  make_mouse_event Button.Right event win
                ))
              | OtherMouseUp   -> Some (Event.ButtonReleased (
                  make_mouse_event Button.Middle event win
                ))
              | MouseMoved     -> Some (Event.MouseMoved (mouse_loc win))
              | _              -> None
            )
        | OGEvent.CloseWindow -> Some Event.Closed
      )
  | None -> None

let display win =
  Cocoa.OGWindowController.flush_context win
