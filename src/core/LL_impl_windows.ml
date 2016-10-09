open OgamlMath

module Window = struct

  exception Error of string

  type t = {
    handle : Windows.WindowHandle.t;
    glcontext : Windows.GlContext.t;
    mutable position : Vector2i.t;
    mutable size : Vector2i.t;
    event_queue : Event.t Queue.t;
    mutable is_open : bool;
    mutable resizing : bool;
    uid : int;
  }

  (** Because we can't safely store an OCaml value in the GWLP_USERDATA field of a window,
    * we store an (unboxed) UID that maps to the corresponding OCaml window in this table *)
  let window_table = 
    Hashtbl.create 13

  (** We simply generate UIDs by incrementing this integer *)
  let next_window_id = 
    ref 0

  (** We also need a callback to retrieve the window from an ID *)
  let get_window id = 
    try Some (Hashtbl.find window_table id)
    with Not_found -> None

  (** Now we can implement Window ! *)
  let create ~width ~height ~title ~settings =
    let open Windows in
    let style = Windows.WindowStyle.(create 
      [WS_Visible; WS_Popup; WS_Thickframe;
       WS_MaximizeBox; WS_MinimizeBox; WS_Caption; WS_Sysmenu])
    in
    WindowHandle.register_class "OGAMLWIN"; 
    let uid = 
      incr next_window_id;
      !next_window_id
    in
    let handle = 
      WindowHandle.create 
        ~classname:"OGAMLWIN"
        ~name:title
        ~rect:(50,50,width,height)
        ~style
        ~uid
    in
    let depthbits = ContextSettings.depth_bits settings in
    let stencilbits = ContextSettings.stencil_bits settings in
    let pfmtdesc = 
      PixelFormat.simple_descriptor handle depthbits stencilbits 
    in
    let pfmt = 
      PixelFormat.choose handle pfmtdesc
    in
    PixelFormat.set handle pfmtdesc pfmt;
    PixelFormat.destroy_descriptor pfmtdesc;
    let glcontext = 
      GlContext.create handle 
    in
    if GlContext.is_null glcontext then
      raise (Error "Cannot initialize GL context");
    GlContext.make_current handle glcontext;
    let glewinit = Glew.init () in
    if glewinit <> "" then 
      raise (Error ("Cannot initialize Glew : " ^ glewinit));
    let (x,y,width,height) = WindowHandle.get_rect handle in
    let event_queue = Queue.create () in
    let window = 
      {
        handle; glcontext;
        position = Vector2i.({x; y});
        size = Vector2i.({x = width; y = height});
        event_queue;
        is_open = true;
        resizing = false;
        uid
      }
    in
    Hashtbl.replace window_table uid window;
    window
	
  let set_title win s = 
    Windows.WindowHandle.set_text win.handle s

  let close win = 
	  win.is_open <- false;
    Windows.WindowHandle.close win.handle

  let destroy win = 
    Hashtbl.remove window_table win.uid;
    win.is_open <- false;
	  Windows.WindowHandle.destroy win.handle

  let update_rect win = 
    let (x,y,w,h) = Windows.WindowHandle.get_rect win.handle in
    win.position <- Vector2i.({x; y});
    win.size <- Vector2i.({x = w; y = h})

  let position win = 
    update_rect win;
	  win.position

  let size win = 
    update_rect win;
	  win.size

  let rect win = 
    update_rect win;
	  IntRect.create win.position win.size

  let resize win v = 
    Windows.WindowHandle.move win.handle 
      (win.position.Vector2i.x, 
       win.position.Vector2i.y,
       v.Vector2i.x, 
       v.Vector2i.y);
    update_rect win

  let toggle_fullscreen win = 
	assert false (* TODO *)

  let is_open win = 
	  win.is_open

  let has_focus win = 
	  Windows.WindowHandle.has_focus win.handle

  let keysym_to_key = Keycode.(function
    | Windows.Event.Code i -> begin
      match i with
      |0x31 -> Num1        |0x32 -> Num2
      |0x33 -> Num3        |0x34 -> Num4
      |0x35 -> Num5        |0x36 -> Num6
      |0x37 -> Num7        |0x38 -> Num8
      |0x39 -> Num9        |0x30 -> Num0
      |0x61 -> Numpad1     |0x62 -> Numpad2
      |0x63 -> Numpad3     |0x64 -> Numpad4
      |0x65 -> Numpad5     |0x66 -> Numpad6
      |0x67 -> Numpad7     |0x68 -> Numpad8
      |0x69 -> Numpad9     |0x60 -> Numpad0
      |0x6D -> NumpadMinus |0x6A -> NumpadTimes
      |0x6B -> NumpadPlus  |0x6F -> NumpadDiv
      |0x6E -> NumpadDot   |0x6C -> NumpadReturn
      |0x1B -> Escape      |0x09 -> Tab
      |0xA2 -> LControl    |0xA0 -> LShift
      |0xA4 -> LAlt        |0x20 -> Space
      |0xA3 -> RControl    |0xA1 -> RShift
      |0xA5 -> RAlt        |0x0D -> Return
      |0x26 -> Up          |0x25 -> Left
      |0x28 -> Down        |0x27 -> Right
      |0x70 -> F1          |0x71 -> F2
      |0x72 -> F3          |0x73 -> F4
      |0x74 -> F5          |0x75 -> F6
      |0x76 -> F7          |0x77 -> F8
      |0x78 -> F9          |0x79 -> F10
      |0x7A -> F11         |0x7B -> F12
      |0x2E -> Delete      | _ -> Unknown
    end
    | Windows.Event.Char c -> begin
      match c with
      |'A' -> A |'B' -> B |'C' -> C
      |'D' -> D |'E' -> E |'F' -> F
      |'G' -> G |'H' -> H |'I' -> I
      |'J' -> J |'K' -> K |'L' -> L
      |'M' -> M |'N' -> N |'O' -> O
      |'P' -> P |'Q' -> Q |'R' -> R
      |'S' -> S |'T' -> T |'U' -> U
      |'V' -> V |'W' -> W |'X' -> X
      |'Y' -> Y |'Z' -> Z
      | _  -> Unknown
    end)

  let vk_to_button = function
    | Windows.Event.LButton when Windows.Event.swap_button () -> Button.Right
    | Windows.Event.RButton when Windows.Event.swap_button () -> Button.Left
    | Windows.Event.LButton -> Button.Left
    | Windows.Event.RButton -> Button.Right
    | Windows.Event.MButton -> Button.Middle
    | _ -> Button.Unknown

  let key_to_keysym = Keycode.(function
    |A -> Windows.Event.Char 'A'   |B -> Windows.Event.Char 'B'
    |C -> Windows.Event.Char 'C'   |D -> Windows.Event.Char 'D'
    |E -> Windows.Event.Char 'E'   |F -> Windows.Event.Char 'F'
    |G -> Windows.Event.Char 'G'   |H -> Windows.Event.Char 'H'
    |I -> Windows.Event.Char 'I'   |J -> Windows.Event.Char 'J'
    |K -> Windows.Event.Char 'K'   |L -> Windows.Event.Char 'L'
    |M -> Windows.Event.Char 'M'   |N -> Windows.Event.Char 'N'
    |O -> Windows.Event.Char 'O'   |P -> Windows.Event.Char 'P'
    |Q -> Windows.Event.Char 'Q'   |R -> Windows.Event.Char 'R'
    |S -> Windows.Event.Char 'S'   |T -> Windows.Event.Char 'T'
    |U -> Windows.Event.Char 'U'   |V -> Windows.Event.Char 'V'
    |W -> Windows.Event.Char 'W'   |X -> Windows.Event.Char 'X'
    |Y -> Windows.Event.Char 'Y'   |Z -> Windows.Event.Char 'Z'
    |Num1 -> Windows.Event.Code 0x31        |Num2 -> Windows.Event.Code 0x32
    |Num3 -> Windows.Event.Code 0x33        |Num4 -> Windows.Event.Code 0x34
    |Num5 -> Windows.Event.Code 0x35        |Num6 -> Windows.Event.Code 0x36
    |Num7 -> Windows.Event.Code 0x37        |Num8 -> Windows.Event.Code 0x38
    |Num9 -> Windows.Event.Code 0x39        |Num0 -> Windows.Event.Code 0x30
    |Numpad1 -> Windows.Event.Code 0x61     |Numpad2 -> Windows.Event.Code 0x62
    |Numpad3 -> Windows.Event.Code 0x63     |Numpad4 -> Windows.Event.Code 0x64
    |Numpad5 -> Windows.Event.Code 0x65     |Numpad6 -> Windows.Event.Code 0x66
    |Numpad7 -> Windows.Event.Code 0x67     |Numpad8 -> Windows.Event.Code 0x68
    |Numpad9 -> Windows.Event.Code 0x69     |Numpad0 -> Windows.Event.Code 0x60
    |NumpadMinus -> Windows.Event.Code 0x6D |NumpadTimes -> Windows.Event.Code 0x6A
    |NumpadPlus -> Windows.Event.Code 0x6B  |NumpadDiv -> Windows.Event.Code 0x6F
    |NumpadDot -> Windows.Event.Code 0x6E   |NumpadReturn -> Windows.Event.Code 0x6C
    |Escape -> Windows.Event.Code 0x1B      |Tab -> Windows.Event.Code 0x09
    |LControl -> Windows.Event.Code 0xA2    |LShift -> Windows.Event.Code 0xA0
    |LAlt -> Windows.Event.Code 0xA4        |Space -> Windows.Event.Code 0x20
    |RControl -> Windows.Event.Code 0xA3    |RShift -> Windows.Event.Code 0xA1
    |RAlt -> Windows.Event.Code 0xA5        |Return -> Windows.Event.Code 0x0D
    |Up -> Windows.Event.Code 0x26          |Left -> Windows.Event.Code 0x25
    |Down -> Windows.Event.Code 0x28        |Right -> Windows.Event.Code 0x27
    |F1 -> Windows.Event.Code 0x70          |F2 -> Windows.Event.Code 0x71
    |F3 -> Windows.Event.Code 0x72          |F4 -> Windows.Event.Code 0x73
    |F5 -> Windows.Event.Code 0x74          |F6 -> Windows.Event.Code 0x75
    |F7 -> Windows.Event.Code 0x76          |F8 -> Windows.Event.Code 0x77
    |F9 -> Windows.Event.Code 0x78          |F10 -> Windows.Event.Code 0x79
    |F11 -> Windows.Event.Code 0x7A         |F12 -> Windows.Event.Code 0x7B
    |Delete -> Windows.Event.Code 0x2E      |Unknown -> assert false 
  )

  let button_to_vk = function
    | Button.Left  when Windows.Event.swap_button () -> Windows.Event.RButton
    | Button.Right when Windows.Event.swap_button () -> Windows.Event.LButton
    | Button.Left  -> Windows.Event.LButton
    | Button.Right -> Windows.Event.RButton
    | Button.Middle -> Windows.Event.MButton
    | Button.Unknown -> assert false

  (** This is a C callback that processes and pushes an event in windows's event queue *)
  let push_event_in_queue win event =
    match event with 
    | Windows.Event.Unknown -> ()
    | Windows.Event.StartResize -> 
      win.resizing <- true
    | Windows.Event.StopResize ->
      let size = win.size in
      update_rect win;
      if size <> win.size then
        Queue.push (Event.Resized) win.event_queue
    | Windows.Event.Resize b ->
      if (not win.resizing) && b then begin
        let size = win.size in
        update_rect win;
        if size <> win.size then 
          Queue.push (Event.Resized) win.event_queue
      end
    | Windows.Event.Closed -> 
      Queue.push (Event.Closed) win.event_queue
    | Windows.Event.KeyDown (keydata, {Windows.Event.shift; ctrl; lock; alt}) ->
      let key = keysym_to_key keydata in
      let keyevent = 
        Event.KeyEvent.({key; shift; control = ctrl; alt})
      in
      Queue.push (Event.KeyPressed keyevent) win.event_queue
    | Windows.Event.KeyUp (keydata, {Windows.Event.shift; ctrl; lock; alt}) ->
      let key = keysym_to_key keydata in
      let keyevent = 
        Event.KeyEvent.({key; shift; control = ctrl; alt})
      in
      Queue.push (Event.KeyReleased keyevent) win.event_queue
    | Windows.Event.MouseVWheel (x, y, delta, mods) -> ()
    | Windows.Event.MouseHWheel (x, y, delta, mods) -> ()
    | Windows.Event.ButtonUp (mb, x, y, {Windows.Event.shift; ctrl; lock; alt}) ->
      let buttonevent = 
        Event.ButtonEvent.({button = vk_to_button mb; x; y; shift; control = ctrl; alt})
      in
      Queue.push (Event.ButtonReleased buttonevent) win.event_queue
    | Windows.Event.ButtonDown (mb, x, y, {Windows.Event.shift; ctrl; lock; alt}) ->
      let buttonevent = 
        Event.ButtonEvent.({button = vk_to_button mb; x; y; shift; control = ctrl; alt})
      in
      Queue.push (Event.ButtonPressed buttonevent) win.event_queue


  let rec poll_event win =
    Windows.WindowHandle.process_events win.handle;
	  if Queue.is_empty win.event_queue then None
    else Some (Queue.pop win.event_queue)

  let display win = 
	  Windows.WindowHandle.swap_buffers win.handle

  (** Register the callbacks *)
  let () =
    Callback.register "OGAMLCallbackGetWindow" get_window;
    Callback.register "OGAMLCallbackPushEvent" push_event_in_queue

end


module Keyboard = struct

  let is_pressed kcode = 
    match kcode with
    | Keycode.Unknown -> false
	  | kcode -> Windows.Event.async_key_state (Window.key_to_keysym kcode)

  let is_shift_down () = 
	  (is_pressed Keycode.LShift) || (is_pressed Keycode.RShift)

  let is_ctrl_down () = 
	  (is_pressed Keycode.LControl) || (is_pressed Keycode.RControl)

  let is_alt_down () = 
	  (is_pressed Keycode.LAlt) || (is_pressed Keycode.RAlt)

end


module Mouse = struct

  let position () = 
	  let (x,y) = Windows.Event.cursor_position () in
    Vector2i.({x; y})

  let relative_position win = 
    let pos = position () in
    Vector2i.sub pos (Window.position win)

  let set_position s = 
	  Windows.Event.set_cursor_position (s.Vector2i.x, s.Vector2i.y)

  let set_relative_position win srel =
    let s = Vector2i.add srel (Window.position win) in 
  	set_position s

  let is_pressed but = 
    match but with
    | Button.Unknown -> false
    | but -> Windows.Event.async_mouse_state (Window.button_to_vk but)

end
