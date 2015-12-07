
module Window = struct

  type t = {
    display : X11.Display.t;
    window  : X11.Window.t;
    context : X11.GLContext.t;
    mutable closed : bool;
    mutable size : OgamlMath.Vector2i.t
  }

  let create ~width ~height ~title ~settings =
    (* The display is a singleton in C (created only once) *)
    let display = X11.Display.create () in
    let vi = X11.VisualInfo.choose display (
      [X11.VisualInfo.DoubleBuffer;
       X11.VisualInfo.DepthSize (ContextSettings.depth_bits settings);
       X11.VisualInfo.StencilSize (ContextSettings.stencil_bits settings)]
      |> fun l ->
          if ContextSettings.aa_level settings > 0 then
            X11.VisualInfo.SampleBuffers 1 ::
            X11.VisualInfo.Samples (ContextSettings.aa_level settings) :: l
          else l)
    in
    let window  =
        X11.Window.create_simple
            ~display:display
            ~parent:(X11.Window.root_of display)
            ~size:(width,height)
            ~origin:(50,50)
            ~visual:vi
    in
    let atom = X11.Atom.intern display "WM_DELETE_WINDOW" false in
    begin
      match atom with
      |None -> assert false
      |Some(a) -> X11.Atom.set_wm_protocols display window [a]
    end;
    if ContextSettings.resizable settings = false then
      X11.Window.set_size_hints display window (width,height) (width,height);
    X11.Event.set_mask display window
      [X11.Event.ExposureMask;
       X11.Event.StructureNotifyMask;
       X11.Event.SubstructureNotifyMask;
       X11.Event.KeyPressMask;
       X11.Event.KeyReleaseMask;
       X11.Event.ButtonPressMask;
       X11.Event.ButtonReleaseMask;
       X11.Event.PointerMotionMask];
    X11.Window.map display window;
    if ContextSettings.fullscreen settings then begin
      let prop = X11.Atom.intern display "_NET_WM_STATE" true in
      let atom_fs = X11.Atom.intern display "_NET_WM_STATE_FULLSCREEN" true in
      match prop, atom_fs with
      |None, _ |_, None -> failwith "fullscreen not supported"
      |Some prop, Some atom -> X11.Atom.send_event display window prop [X11.Atom.wm_toggle;atom]
    end;
    X11.Display.flush display;
    let context = X11.GLContext.create display vi in
    X11.Window.attach display window context;
    X11.Window.set_title display window title;
    {display; window; context; closed = false; size = OgamlMath.Vector2i.({x = width; y = height})}

  let set_title win title =
    X11.Window.set_title win.display win.window title

  let close win =
    X11.Window.unmap win.display win.window;
    win.closed <- true

  let destroy win =
    X11.Window.destroy win.display win.window;
    win.closed <- true

  let resize win size =
    X11.Window.resize win.display win.window size.OgamlMath.Vector2i.x size.OgamlMath.Vector2i.y

  let toggle_fullscreen win = 
    let prop = X11.Atom.intern win.display "_NET_WM_STATE" true in
    let atom_fs = X11.Atom.intern win.display "_NET_WM_STATE_FULLSCREEN" true in
    match prop, atom_fs with
    |None, _ |_, None -> failwith "fullscreen not supported"
    |Some prop, Some atom -> X11.Atom.send_event win.display win.window prop [X11.Atom.wm_toggle;atom]

  let size win =
    let (x,y) = X11.Window.size win.display win.window in
    OgamlMath.Vector2i.({x;y})

  let rect win =
    let (width,height) = X11.Window.size win.display win.window in
    let (x,y) = X11.Window.position win.display win.window in
    OgamlMath.IntRect.({x; y; width; height})

  let is_open win =
    not win.closed

  let has_focus win =
    X11.Window.has_focus win.display win.window

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

  let key_to_keysym = Keycode.(function
    |A -> X11.Event.Char 'a'   |B -> X11.Event.Char 'b'
    |C -> X11.Event.Char 'c'   |D -> X11.Event.Char 'd'
    |E -> X11.Event.Char 'e'   |F -> X11.Event.Char 'f'
    |G -> X11.Event.Char 'g'   |H -> X11.Event.Char 'h'
    |I -> X11.Event.Char 'i'   |J -> X11.Event.Char 'j'
    |K -> X11.Event.Char 'k'   |L -> X11.Event.Char 'l'
    |M -> X11.Event.Char 'm'   |N -> X11.Event.Char 'n'
    |O -> X11.Event.Char 'o'   |P -> X11.Event.Char 'p'
    |Q -> X11.Event.Char 'q'   |R -> X11.Event.Char 'r'
    |S -> X11.Event.Char 's'   |T -> X11.Event.Char 't'
    |U -> X11.Event.Char 'u'   |V -> X11.Event.Char 'v'
    |W -> X11.Event.Char 'w'   |X -> X11.Event.Char 'x'
    |Y -> X11.Event.Char 'y'   |Z -> X11.Event.Char 'z'
    |Num1 -> X11.Event.Code 10 |Num2 -> X11.Event.Code 11
    |Num3 -> X11.Event.Code 12 |Num4 -> X11.Event.Code 13
    |Num5 -> X11.Event.Code 14 |Num6 -> X11.Event.Code 15
    |Num7 -> X11.Event.Code 16 |Num8 -> X11.Event.Code 17
    |Num9 -> X11.Event.Code 18 |Num0 -> X11.Event.Code 19
    |Numpad1 -> X11.Event.Code 87 |Numpad2 -> X11.Event.Code 88
    |Numpad3 -> X11.Event.Code 89 |Numpad4 -> X11.Event.Code 83
    |Numpad5 -> X11.Event.Code 84 |Numpad6 -> X11.Event.Code 85
    |Numpad7 -> X11.Event.Code 79 |Numpad8 -> X11.Event.Code 80
    |Numpad9 -> X11.Event.Code 81 |Numpad0 -> X11.Event.Code 90
    |NumpadMinus -> X11.Event.Code 82 |NumpadTimes -> X11.Event.Code 63
    |NumpadPlus  -> X11.Event.Code 86 |NumpadDiv   -> X11.Event.Code 106
    |NumpadDot   -> X11.Event.Code 91 |NumpadReturn-> X11.Event.Code 104
    |Escape   -> X11.Event.Code 9   |Tab    -> X11.Event.Code 23
    |LControl -> X11.Event.Code 37  |LShift -> X11.Event.Code 50
    |LAlt     -> X11.Event.Code 64  |Space  -> X11.Event.Code 65
    |RControl -> X11.Event.Code 105 |RShift -> X11.Event.Code 62
    |RAlt     -> X11.Event.Code 108 |Return -> X11.Event.Code 36
    |Up       -> X11.Event.Code 111 |Left   -> X11.Event.Code 113
    |Down     -> X11.Event.Code 116 |Right  -> X11.Event.Code 114
    |F1       -> X11.Event.Code 67  |F2     -> X11.Event.Code 68
    |F3       -> X11.Event.Code 69  |F4     -> X11.Event.Code 70
    |F5       -> X11.Event.Code 71  |F6     -> X11.Event.Code 72
    |F7       -> X11.Event.Code 73  |F8     -> X11.Event.Code 74
    |F9       -> X11.Event.Code 75  |F10    -> X11.Event.Code 76
    |F11      -> X11.Event.Code 95  |F12    -> X11.Event.Code 96
    |Delete   -> X11.Event.Code 22  |Unknown-> assert false
  )

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
      | X11.Event.ConfigureNotify when size win <> win.size ->
          win.size <- size win;
          Some Event.Resized
      | _ -> None
    end
    | None -> None
  end

  let display win =
    X11.Window.swap win.display win.window

end



module Keyboard = struct

  let is_pressed key =
    match key with
    |Keycode.Unknown -> false
    | _ ->
      let d = X11.Display.create () in
      X11.Keyboard.key_down d (Window.key_to_keysym key)

  let is_shift_down () =
    (is_pressed Keycode.LShift) ||
    (is_pressed Keycode.RShift)

  let is_ctrl_down () =
    (is_pressed Keycode.LControl) ||
    (is_pressed Keycode.RControl)

  let is_alt_down () =
    (is_pressed Keycode.LAlt) ||
    (is_pressed Keycode.RAlt)

end



module Mouse = struct

  let position () =
    let d = X11.Display.create () in
    let (x,y) = X11.Mouse.position d (X11.Window.root_of d) in
    OgamlMath.Vector2i.({x;y})

  let relative_position win =
    let (x,y) = X11.Mouse.position win.Window.display win.Window.window in
    OgamlMath.Vector2i.({x;y})

  let set_position v =
    let d = X11.Display.create () in
    X11.Mouse.warp d (X11.Window.root_of d) v.OgamlMath.Vector2i.x v.OgamlMath.Vector2i.y

  let set_relative_position win v =
    X11.Mouse.warp win.Window.display win.Window.window v.OgamlMath.Vector2i.x v.OgamlMath.Vector2i.y

  let is_pressed button =
    let d = X11.Display.create () in
    let w = X11.Window.root_of d in
    match button with
    |Button.Left    -> X11.Mouse.button_down d w 1
    |Button.Middle  -> X11.Mouse.button_down d w 2
    |Button.Right   -> X11.Mouse.button_down d w 3
    |Button.Unknown -> false

end
