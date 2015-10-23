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
  | Xlib.Event.Code i -> begin
    match i with
    |10 -> Num1        |11 -> Num2 
    |12 -> Num3        |13 -> Num4 
    |14 -> Num5        |15 -> Num6
    |16 -> Num7        |17 -> Num8 
    |18 -> Num9        |19 -> Num0
    |87 -> Numpad1     |88 -> Numpad2 
    |89 -> Numpad3     |83 -> Numpad4 
    |84 -> Numpad5     |85 -> Numpad6
    |79 -> Numpad7     |80 -> Numpad8 
    |81 -> Numpad9     |90 -> Numpad0 
    |82 -> NumpadMinus |63  -> NumpadTimes
    |86 -> NumpadPlus  |106 -> NumpadDiv
    |91 -> NumpadDot   |104 -> NumpadReturn
    |9   -> Escape     |23 -> Tab
    |37  -> LControl   |50 -> LShift
    |64  -> LAlt       |65 -> Space
    |105 -> RControl   |62 -> RShift
    |108 -> RAlt       |36 -> Return
    |111 -> Up         |113 -> Left
    |116 -> Down       |114 -> Right
    |67 -> F1          |68 -> F2
    |69 -> F3          |70 -> F4
    |71 -> F5          |72 -> F6
    |73 -> F7          |74 -> F8
    |75 -> F9          |76 -> F10
    |95 -> F11         |96 -> F12
    |22  -> Delete     | _ -> Unknown
  end
  | Xlib.Event.Char c -> begin
    match c with
    |'a' -> A |'b' -> B |'c' -> C
    |'d' -> D |'e' -> E |'f' -> F
    |'g' -> G |'h' -> H |'i' -> I
    |'j' -> J |'k' -> K |'l' -> L
    |'m' -> M |'n' -> N |'o' -> O
    |'p' -> P |'q' -> Q |'r' -> R
    |'s' -> S |'t' -> T |'u' -> U
    |'v' -> V |'w' -> W |'x' -> X
    |'y' -> Y |'z' -> Z 
    | _  -> Unknown
  end)

let value_to_button = Button.(function
  |1 -> Left
  |2 -> Middle
  |3 -> Right
  |_ -> Unknown)

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


