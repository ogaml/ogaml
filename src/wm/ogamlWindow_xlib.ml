module Event = struct

  type t = 
    | Closed
    | KeyPressed
    | KeyReleased
    | ButtonPressed
    | ButtonReleased
    | MouseMoved

end


module Window = struct

  type t = {
    display : Xlib.Display.t;
    window  : Xlib.Window.t;
    mutable closed : bool
  }

  let create ~width ~height = 
    (* For now, every window is top-level and requests a new display *)
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

  let poll_event win = 
    if win.closed then None
    else begin 
      (* Event.next should also consider the window,
      * but for now we can only create one window 
      * with one display *)
      match Xlib.Event.next win.display with
      |Some e when Xlib.Event.type_of e = Xlib.Event.ClientMessage -> 
          (* Should match on the type of ClientMessage
          * but there is only one for now *)
          win.closed <- true;
          Some Event.Closed
      |Some e when Xlib.Event.type_of e = Xlib.Event.KeyPress -> 
          Some Event.KeyPressed
      |Some e when Xlib.Event.type_of e = Xlib.Event.KeyRelease ->
          Some Event.KeyReleased
      |Some e when Xlib.Event.type_of e = Xlib.Event.ButtonPress ->
          Some Event.ButtonPressed 
      |Some e when Xlib.Event.type_of e = Xlib.Event.ButtonRelease ->
          Some Event.ButtonReleased
      |Some e when Xlib.Event.type_of e = Xlib.Event.MotionNotify ->
          Some Event.MouseMoved
      | _ -> None
    end

end
