type t = {
  display : Xlib.Display.t;
  window  : Xlib.Window.t;
  context : Xlib.GLContext.t;
  mutable closed : bool
}

let create ~width ~height = 
  (* The display is a singleton in C (created only once) *)
  let display = Xlib.Display.create () in
  let window  = 
      Xlib.Window.create_simple
          ~display:display
          ~parent:(Xlib.Window.root_of display)
          ~size:(width,height) 
          ~origin:(50,50) 
          ~background:0;
  in
  let atom = Xlib.Atom.intern display "WM_DELETE_WINDOW" false in
  begin 
    match atom with
    |None -> assert false
    |Some(a) -> Xlib.Atom.set_wm_protocols display window [a]
  end;
  Xlib.Event.set_mask display window 
    [Xlib.Event.ExposureMask; 
      Xlib.Event.KeyPressMask; 
      Xlib.Event.KeyReleaseMask; 
      Xlib.Event.ButtonPressMask;
      Xlib.Event.ButtonReleaseMask;
      Xlib.Event.PointerMotionMask];
  Xlib.Window.map display window;
  Xlib.Display.flush display;
  let vi = Xlib.VisualInfo.choose display
    [Xlib.VisualInfo.RGBA; 
     Xlib.VisualInfo.DepthSize 24; 
     Xlib.VisualInfo.DoubleBuffer] 
  in
  let context = Xlib.GLContext.create display vi in
  Xlib.Window.attach display window context;
  {display; window; context; closed = false}

let close win =
  Xlib.Window.unmap win.display win.window;
  win.closed <- true

let destroy win = 
  Xlib.Window.detach win.display win.window;
  Xlib.GLContext.destroy win.display win.context;
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
      | Xlib.Event.KeyPress      (key,modif) -> Some Event.KeyPressed
(*          Some Event.(KeyPressed {
              KeyEvent.key = keysym_to_key key; 
              KeyEvent.shift = modif.Xlib.Event.shift || modif.Xlib.Event.lock;
              KeyEvent.control = modif.Xlib.Event.ctrl;
              KeyEvent.alt = modif.Xlib.Event.alt
          })*)
      | Xlib.Event.KeyRelease    (key,modif) -> Some Event.KeyReleased
(*          Some Event.(KeyReleased {
              KeyEvent.key = keysym_to_key key; 
              KeyEvent.shift = modif.Xlib.Event.shift || modif.Xlib.Event.lock;
              KeyEvent.control = modif.Xlib.Event.ctrl;
              KeyEvent.alt = modif.Xlib.Event.alt
          })*)
      | Xlib.Event.ButtonPress   (but,pos,modif) -> Some Event.ButtonPressed
(*          Some Event.(ButtonPressed {
              ButtonEvent.button = value_to_button but;
              ButtonEvent.x = pos.Xlib.Event.x;
              ButtonEvent.y = pos.Xlib.Event.y;
              ButtonEvent.shift = modif.Xlib.Event.shift || modif.Xlib.Event.lock;
              ButtonEvent.control = modif.Xlib.Event.ctrl;
              ButtonEvent.alt = modif.Xlib.Event.alt
          })*)
      | Xlib.Event.ButtonRelease (but,pos,modif) -> Some Event.ButtonReleased
(*          Some Event.(ButtonReleased {
              ButtonEvent.button = value_to_button but;
              ButtonEvent.x = pos.Xlib.Event.x;
              ButtonEvent.y = pos.Xlib.Event.y;
              ButtonEvent.shift = modif.Xlib.Event.shift || modif.Xlib.Event.lock;
              ButtonEvent.control = modif.Xlib.Event.ctrl;
              ButtonEvent.alt = modif.Xlib.Event.alt
          })*)
      | Xlib.Event.MotionNotify  pos -> Some Event.MouseMoved
(*          Some Event.(MouseMoved {
              MouseEvent.x = pos.Xlib.Event.x;
              MouseEvent.y = pos.Xlib.Event.y
          })*)
      | _ -> None
    end
    | None -> None
  end

let display win = 
  Xlib.Window.swap win.display win.window
