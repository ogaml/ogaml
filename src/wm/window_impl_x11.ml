type t = {
  display : Xlib.Display.t;
  window  : Xlib.Window.t;
  mutable closed : bool
}

let create ~width ~height = 
  (* The display is a singleton in C (created only once) *)
  let disp = Xlib.Display.create () in
  let win = 
    {
      display = disp;
      window  = Xlib.Window.create_simple
          ~display:disp
          ~parent:(Xlib.Window.root_of disp)
          ~size:(width,height) 
          ~origin:(50,50) 
          ~background:0;
      closed  = false
    }
  in
  let atom = Xlib.Atom.intern win.display "WM_DELETE_WINDOW" false in
  begin 
    match atom with
    |None -> assert false
    |Some(a) -> Xlib.Atom.set_wm_protocols win.display win.window [a]
  end;
  Xlib.Event.set_mask win.display win.window 
    [Xlib.Event.ExposureMask; 
      Xlib.Event.KeyPressMask; 
      Xlib.Event.KeyReleaseMask; 
      Xlib.Event.ButtonPressMask;
      Xlib.Event.ButtonReleaseMask;
      Xlib.Event.PointerMotionMask];
  Xlib.Window.map win.display win.window;
  Xlib.Display.flush win.display;
  win

let close win =
  Xlib.Window.unmap win.display win.window;
  win.closed <- true

let destroy win = 
  Xlib.Window.destroy win.display win.window;
  win.closed <- true

let size win = 
  Xlib.Window.size win.display win.window

let is_open win = 
  not win.closed

let keysym_to_key = Keycode.(function
  | 97  -> A    | 98  -> B
  | 99  -> C    | 100 -> D
  | 101 -> E    | 102 -> F
  | 103 -> G    | 104 -> H
  | 105 -> I    | 106 -> J
  | 107 -> K    | 108 -> L
  | 109 -> M    | 110 -> N
  | 111 -> O    | 112 -> P
  | 113 -> Q    | 114 -> R
  | 115 -> S    | 116 -> T
  | 117 -> U    | 118 -> V
  | 119 -> W    | 120 -> X
  | 121 -> Y    | 122 -> Z
  | 38  -> Num1 | 233 -> Num2
  | 34  -> Num3 | 39  -> Num4
  | 40  -> Num5 | 45  -> Num6
  | 232 -> Num7 | 95  -> Num8
  | 231 -> Num9 | 224 -> Num0
  | 65438 -> Numpad0
  | 65436 -> Numpad1
  | 65433 -> Numpad2
  | 65435 -> Numpad3
  | 65430 -> Numpad4
  | 65437 -> Numpad5
  | 65432 -> Numpad6
  | 65429 -> Numpad7
  | 65431 -> Numpad8
  | 65434 -> Numpad9
  | 65453 -> NumpadMinus
  | 65450 -> NumpadTimes
  | 65451 -> NumpadPlus
  | 65455 -> NumpadDiv
  | 65454 -> NumpadDot
  | 65421 -> NumpadReturn
  | 65307 -> Escape
  | 65289 -> Tab
  | 65507 -> LControl
  | 65505 -> LShift
  | 65513 -> LAlt
  | _ -> Unknown
  )

let poll_event win = 
  if win.closed then None
  else begin 
    match Xlib.Event.next win.display win.window with
    |Some e -> begin
      match Xlib.Event.data e with
      | Xlib.Event.ClientMessage a -> begin
        match Xlib.Atom.intern win.display "WM_DELETE_WINDOW" true with
        | Some(a') when a = a' -> 
            win.closed <- true;
            Some Event.Closed
        | _ -> None
      end
      | Xlib.Event.KeyPress      _ -> Some Event.KeyPressed
      | Xlib.Event.KeyRelease    _ -> Some Event.KeyReleased
      | Xlib.Event.ButtonPress   _ -> Some Event.ButtonPressed
      | Xlib.Event.ButtonRelease _ -> Some Event.ButtonReleased
      | Xlib.Event.MotionNotify  _ -> Some Event.MouseMoved
      | _ -> None
    end
    | None -> None
  end


