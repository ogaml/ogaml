
module Window = struct

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

  let create ~width ~height ~title ~settings =
    init_app () ;

    (* Rect for setting the size -- offset is ignored we will center *)
    let f = float_of_int in
    let rect = Cocoa.NSRect.create 0. 0. (f width) (f height) in

    (* Now creating an NSWindow *)
    let window = Cocoa.NSWindow.(
      create ~frame:rect
              ~style_mask:(
                  [Titled;Closable;Miniaturizable]
                  |> fun m ->
                    if ContextSettings.resizable settings
                    then Resizable :: m
                    else m
                )
              ~backing:Buffered
              ~defer:false ()
    ) in

    (* Various settings *)
    Cocoa.(
      NSWindow.set_background_color window (NSColor.green ()) ;
      NSWindow.make_key_and_order_front window ;
      NSWindow.center window ;
      (* NSWindow.make_main window ; *)
      NSWindow.set_for_events window ;
      NSWindow.set_autodisplay window true
    );

    (* Creating the delegate which we will return *)
    let win_ctrl = Cocoa.OGWindowController.init_with_window window in

    (* Adding a title to the window *)
    Cocoa.OGWindowController.set_title win_ctrl (Cocoa.NSString.create title) ;

    (* Putting the window in fullscreen if asked *)
    if ContextSettings.fullscreen settings then
      Cocoa.OGWindowController.toggle_fullscreen win_ctrl ;

    (* But first we create and apply a new openGL context *)
    let attr = Cocoa.NSOpenGLPixelFormat.(
      [
        #ifdef __OSX__
        NSOpenGLPFAOpenGLProfile NSOpenGLProfileVersion3_2Core ;
        #endif
        NSOpenGLPFAColorSize 24 ;
        NSOpenGLPFAAlphaSize 8  ;
        NSOpenGLPFADepthSize (ContextSettings.depth_bits settings) ;
        NSOpenGLPFAStencilSize (ContextSettings.stencil_bits settings) ;
        NSOpenGLPFADoubleBuffer ;
        NSOpenGLPFAAccelerated
      ]
      |> fun l ->
        if ContextSettings.aa_level settings > 0 then
          NSOpenGLPFAMultisample ::
          NSOpenGLPFASampleBuffers 1 ::
          NSOpenGLPFASamples (ContextSettings.aa_level settings) :: l
        else l
    ) in

    let pixel_format = Cocoa.NSOpenGLPixelFormat.init_with_attributes attr in
    let context = Cocoa.NSOpenGLContext.init_with_format pixel_format in
    Cocoa.OGWindowController.set_context win_ctrl context ;

    (* Finally returning the window controller *)
    win_ctrl

  let set_title win title =
    Cocoa.OGWindowController.set_title win (Cocoa.NSString.create title)

  let close win =
    Cocoa.OGWindowController.close_window win

  let destroy win =
    Cocoa.OGWindowController.release_window win

  let size win =
    let i = int_of_float in
    Cocoa.(
      let (_,_,w,h) = NSRect.get (OGWindowController.content_frame win) in
      OgamlMath.Vector2i.({x = i w; y = i h})
    )

  let rect win =
    let i = int_of_float in
    Cocoa.(
      let (x,y,w,h) = NSRect.get (OGWindowController.content_frame win) in
      OgamlMath.IntRect.({x = i x; y = i y; width = i w; height = i h})
    )

  let resize win size =
    let open Cocoa in
    let (x,y,oldw,oldh) = NSRect.get (OGWindowController.frame win) in
    let (w,h) = OgamlMath.Vector2i.(
      size.x , size.y
    ) in
    let (w,h) = float_of_int w, float_of_int h in
    (* DEBUG *)
    OgamlUtils.Log.debug OgamlUtils.Log.stdout "Resizing window to %s" 
      (OgamlMath.Vector2i.print size);
    OgamlUtils.Log.debug OgamlUtils.Log.stdout "Actual size : %s" 
      (OgamlMath.FloatRect.(print {x = x+.(oldw-.w)/.2.;
                                   y = y+.(oldh-.h)/.2.; 
                                   width = w; height = h}));
    let frame = NSRect.create (x+.(oldw-.w)/.2.) (y+.(oldh-.h)/.2.) w h in
    OGWindowController.resize win frame

  let toggle_fullscreen win =
    Cocoa.OGWindowController.toggle_fullscreen win

  let is_open win =
    Cocoa.OGWindowController.is_window_open win

  let has_focus win =
    Cocoa.OGWindowController.has_focus win

  let mk_key_event key_info =
    let keycode = Keycode.(
      match Cocoa.NSString.get Cocoa.OGEvent.(key_info.characters) with
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
          match Cocoa.OGEvent.(key_info.keycode) with
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
    let modifiers = Cocoa.OGEvent.(key_info.modifier_flags) in
    let (shift,control,alt) = Cocoa.NSEvent.(
      List.mem NSShiftKeyMask     modifiers,
      List.mem NSCommandKeyMask   modifiers,
      List.mem NSAlternateKeyMask modifiers
    ) in
    Event.KeyEvent.({
      key = keycode ; shift = shift ; control = control ; alt = alt
    })

  let mk_wheel deltaY =
    (* let open Cocoa in
    let (x,y,w,h) = NSRect.get (OGWindowController.frame win) in
    let (w,h) = float_of_int w, float_of_int h in *)
    deltaY

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
      position = OgamlMath.Vector2i.({x = i x ; y = i y});
      shift = shift ;
      control = control ;
      alt = alt
    })

  let mouse_loc win =
    let (x,y) = Cocoa.OGWindowController.proper_relative_mouse_location win in
    let i = int_of_float in
    OgamlMath.Vector2i.({ x = i x ; y = i y })

  let poll_event win =
    Cocoa.OGWindowController.process_event win ;
    match Cocoa.OGWindowController.pop_event win with
    | Some ogevent ->
        Cocoa.(
          match OGEvent.get_content ogevent with
          | OGEvent.CocoaEvent event ->
              NSEvent.(
                match get_type event with
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
          | OGEvent.CloseWindow   -> Some Event.Closed
          | OGEvent.KeyUp   inf   -> Some (Event.KeyPressed  (mk_key_event inf))
          | OGEvent.KeyDown inf   -> Some (Event.KeyReleased (mk_key_event inf))
          | OGEvent.ResizedWindow -> Some (Event.Resized (size win))
          | OGEvent.ScrollWheel f -> Some (Event.MouseWheelMoved (mk_wheel f))
        )
    | None -> None

  let display win =
    Cocoa.OGWindowController.flush_context win

  let show_cursor win b = ()

end



module Keyboard = struct

  let is_pressed key =
    let keycode = Keycode.(
      match key with
      | A -> `Char 'a'
      | B -> `Char 'b'
      | C -> `Char 'c'
      | D -> `Char 'd'
      | E -> `Char 'e'
      | F -> `Char 'f'
      | G -> `Char 'g'
      | H -> `Char 'h'
      | I -> `Char 'i'
      | J -> `Char 'j'
      | K -> `Char 'k'
      | L -> `Char 'l'
      | M -> `Char 'm'
      | N -> `Char 'n'
      | O -> `Char 'o'
      | P -> `Char 'p'
      | Q -> `Char 'q'
      | R -> `Char 'r'
      | S -> `Char 's'
      | T -> `Char 't'
      | U -> `Char 'u'
      | V -> `Char 'v'
      | W -> `Char 'w'
      | X -> `Char 'x'
      | Y -> `Char 'y'
      | Z -> `Char 'z'
      | Num1 -> `Keycode 18
      | Num2 -> `Keycode 19
      | Num3 -> `Keycode 20
      | Num4 -> `Keycode 21
      | Num5 -> `Keycode 23
      | Num6 -> `Keycode 22
      | Num7 -> `Keycode 26
      | Num8 -> `Keycode 28
      | Num9 -> `Keycode 25
      | Num0 -> `Keycode 29
      | Numpad1 -> `Keycode 83
      | Numpad2 -> `Keycode 84
      | Numpad3 -> `Keycode 85
      | Numpad4 -> `Keycode 86
      | Numpad5 -> `Keycode 87
      | Numpad6 -> `Keycode 88
      | Numpad7 -> `Keycode 89
      | Numpad8 -> `Keycode 91
      | Numpad9 -> `Keycode 92
      | Numpad0 -> `Keycode 82
      | NumpadMinus  -> `Keycode 78
      | NumpadTimes  -> `Keycode 67
      | NumpadPlus   -> `Keycode 69
      | NumpadDiv    -> `Keycode 75
      | NumpadDot    -> `Keycode 65
      | NumpadReturn -> `Keycode 76
      | Escape   -> `Keycode 53
      | Tab      -> `Keycode 48
      | LControl -> `Keycode 55
      | LShift   -> `Keycode 56
      | LAlt     -> `Keycode 58
      | Space    -> `Keycode 49
      | RControl -> `Keycode 55
      | RShift   -> `Keycode 56
      | RAlt     -> `Keycode 58
      | Return   -> `Keycode 36
      | Delete   -> `Keycode 117
      | Up    -> `Keycode 126
      | Left  -> `Keycode 123
      | Down  -> `Keycode 125
      | Right -> `Keycode 124
      | F1  -> `Keycode 122
      | F2  -> `Keycode 120
      | F3  -> `Keycode 99
      | F4  -> `Keycode 118
      | F5  -> `Keycode 96
      | F6  -> `Keycode 97
      | F7  -> `Keycode 98
      | F8  -> `Keycode 100
      | F9  -> `Keycode 101
      | F10 -> `Keycode 109
      | F11 -> `Keycode 103
      | F12 -> `Keycode 111
      | _ -> `Unknown
    ) in
    match keycode with
    | `Char c    -> Cocoa.Keyboard.is_char_pressed c
    | `Keycode c -> Cocoa.Keyboard.is_keycode_pressed c
    | `Unknown   -> false

  let is_shift_down () =
    let modifiers = Cocoa.NSEvent.modifier_flags () in
    let (shift,_,_) = Cocoa.NSEvent.(
      List.mem NSShiftKeyMask     modifiers,
      List.mem NSCommandKeyMask   modifiers,
      List.mem NSAlternateKeyMask modifiers
    ) in
    shift

  let is_ctrl_down () =
    let modifiers = Cocoa.NSEvent.modifier_flags () in
    let (_,control,_) = Cocoa.NSEvent.(
      List.mem NSShiftKeyMask     modifiers,
      List.mem NSCommandKeyMask   modifiers,
      List.mem NSAlternateKeyMask modifiers
    ) in
    control

  let is_alt_down () =
    let modifiers = Cocoa.NSEvent.modifier_flags () in
    let (_,_,alt) = Cocoa.NSEvent.(
      List.mem NSShiftKeyMask     modifiers,
      List.mem NSCommandKeyMask   modifiers,
      List.mem NSAlternateKeyMask modifiers
    ) in
    alt

end



module Mouse = struct

  let position () =
    let (x,y) = Cocoa.NSEvent.proper_mouse_location () in
    let i = int_of_float in
    OgamlMath.Vector2i.({x = i x; y = i y})

  let relative_position win =
    let (x,y) = Cocoa.OGWindowController.proper_relative_mouse_location win in
    let i = int_of_float in
    OgamlMath.Vector2i.({x = i x; y = i y})

  let set_position v =
    let f = float_of_int in
    Cocoa.Mouse.warp (f v.OgamlMath.Vector2i.x) (f v.OgamlMath.Vector2i.y)

  let set_relative_position win v =
    let f = float_of_int in
    Cocoa.OGWindowController.set_proper_relative_mouse_location win (f v.OgamlMath.Vector2i.x) (f v.OgamlMath.Vector2i.y)

  let is_pressed button =
    let pressed_buttons = Cocoa.NSEvent.pressed_mouse_buttons () in
    let conv = Cocoa.NSEvent.(function
      | ButtonLeft  -> Button.Left
      | ButtonRight -> Button.Right
      | ButtonOther -> Button.Middle
    ) in
    List.mem button (List.map conv pressed_buttons)

end
