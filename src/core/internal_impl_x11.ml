
module Window = struct

  type t = {
    display : X11.Display.t;
    window  : X11.Window.t;
    context : X11.GLContext.t;
    mutable closed : bool
  }

  let create ~width ~height =
    (* The display is a singleton in C (created only once) *)
    let display = X11.Display.create () in
    let window  =
        X11.Window.create_simple
            ~display:display
            ~parent:(X11.Window.root_of display)
            ~size:(width,height)
            ~origin:(50,50)
            ~background:0;
    in
    let atom = X11.Atom.intern display "WM_DELETE_WINDOW" false in
    begin
      match atom with
      |None -> assert false
      |Some(a) -> X11.Atom.set_wm_protocols display window [a]
    end;
    X11.Event.set_mask display window
      [X11.Event.ExposureMask;
        X11.Event.KeyPressMask;
        X11.Event.KeyReleaseMask;
        X11.Event.ButtonPressMask;
        X11.Event.ButtonReleaseMask;
        X11.Event.PointerMotionMask];
    X11.Window.map display window;
    X11.Display.flush display;
    let vi = X11.VisualInfo.choose display
      [X11.VisualInfo.RGBA;
      X11.VisualInfo.DepthSize 24;
      X11.VisualInfo.DoubleBuffer]
    in
    let context = X11.GLContext.create display vi in
    X11.Window.attach display window context;
    {display; window; context; closed = false}

  let close win =
    X11.Window.unmap win.display win.window;
    win.closed <- true

  let destroy win =
    X11.Window.destroy win.display win.window;
    win.closed <- true

  let size win =
    X11.Window.size win.display win.window

  let is_open win =
    not win.closed

  let has_focus win =
    true

  let keysym_to_key = Keycode.(function
    | X11.Event.Code i -> begin
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
    | X11.Event.Char c -> begin
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
      match X11.Event.next win.display win.window with
      |Some e -> begin
        match X11.Event.data e with
        | X11.Event.ClientMessage a -> begin
          match X11.Atom.intern win.display "WM_DELETE_WINDOW" true with
          | Some(a') when a = a' ->
              win.closed <- true;
              Some Event.Closed
          | _ -> None
        end
        | X11.Event.KeyPress      (key,modif) ->
          Some Event.(KeyPressed {
                KeyEvent.key = keysym_to_key key;
                KeyEvent.shift = modif.X11.Event.shift || modif.X11.Event.lock;
                KeyEvent.control = modif.X11.Event.ctrl;
                KeyEvent.alt = modif.X11.Event.alt
            })
        | X11.Event.KeyRelease    (key,modif) ->
          Some Event.(KeyReleased {
                KeyEvent.key = keysym_to_key key;
                KeyEvent.shift = modif.X11.Event.shift || modif.X11.Event.lock;
                KeyEvent.control = modif.X11.Event.ctrl;
                KeyEvent.alt = modif.X11.Event.alt
            })
        | X11.Event.ButtonPress   (but,pos,modif) ->
            Some Event.(ButtonPressed {
                ButtonEvent.button = value_to_button but;
                ButtonEvent.x = pos.X11.Event.x;
                ButtonEvent.y = pos.X11.Event.y;
                ButtonEvent.shift = modif.X11.Event.shift || modif.X11.Event.lock;
                ButtonEvent.control = modif.X11.Event.ctrl;
                ButtonEvent.alt = modif.X11.Event.alt
            })
        | X11.Event.ButtonRelease (but,pos,modif) ->
          Some Event.(ButtonReleased {
                ButtonEvent.button = value_to_button but;
                ButtonEvent.x = pos.X11.Event.x;
              ButtonEvent.y = pos.X11.Event.y;
              ButtonEvent.shift = modif.X11.Event.shift || modif.X11.Event.lock;
              ButtonEvent.control = modif.X11.Event.ctrl;
              ButtonEvent.alt = modif.X11.Event.alt
          })
      | X11.Event.MotionNotify  pos ->
         Some Event.(MouseMoved {
              MouseEvent.x = pos.X11.Event.x;
              MouseEvent.y = pos.X11.Event.y
          })
      | _ -> None
    end
    | None -> None
  end

  let display win =
    X11.Window.swap win.display win.window

end



module Keyboard = struct

  let is_pressed key = false

  let is_shift_down () = false

  let is_ctrl_down () = false

  let is_alt_down () = false

end



module Mouse = struct

  let position () = 
    let d = X11.Display.create () in
    X11.Mouse.position d (X11.Window.root_of d)

  let relative_position win = 
    X11.Mouse.position win.Window.display win.Window.window

  let set_position (x,y) = 
    let d = X11.Display.create () in
    X11.Mouse.warp d (X11.Window.root_of d) x y

  let set_relative_position win (x,y) = 
    X11.Mouse.warp win.Window.display win.Window.window x y

  let is_pressed button = 
    let d = X11.Display.create () in
    let w = X11.Window.root_of d in
    match button with
    |Button.Left    -> X11.Mouse.button_down d w 1
    |Button.Middle  -> X11.Mouse.button_down d w 2
    |Button.Right   -> X11.Mouse.button_down d w 3
    |Button.Unknown -> false

end
