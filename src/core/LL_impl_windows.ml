open OgamlMath

module Window = struct

  exception Error of string

  type t = {
    handle : Windows.WindowHandle.t;
    glcontext : Windows.GlContext.t;
    position : Vector2i.t;
    size : Vector2i.t
  }

  let create ~width ~height ~title ~settings =
    let open Windows in
    let style = Windows.WindowStyle.(create 
      [WS_Visible; WS_Popup; WS_Thickframe;
       WS_MaximizeBox; WS_MinimizeBox; WS_Caption; WS_Sysmenu])
    in
    WindowHandle.register_class "OGAMLWIN"; 
    let handle = 
      WindowHandle.create 
        ~classname:"OGAMLWIN"
        ~name:title
        ~origin:(50,50)
        ~size:(width,height)
        ~style
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
    {handle; glcontext;
     position = Vector2i.({x; y});
     size = Vector2i.({x = width; y = height})}
	
  let set_title win s = 
	assert false

  let close win = 
	assert false

  let destroy win = 
	assert false

  let size win = 
	  win.size

  let rect win = 
	  IntRect.create win.position win.size

  let resize win v = 
	assert false

  let toggle_fullscreen win = 
	assert false

  let is_open win = 
	assert false

  let has_focus win = 
	assert false

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
    |A -> Windows.Event.Char 'a'   |B -> Windows.Event.Char 'b'
    |C -> Windows.Event.Char 'c'   |D -> Windows.Event.Char 'd'
    |E -> Windows.Event.Char 'e'   |F -> Windows.Event.Char 'f'
    |G -> Windows.Event.Char 'g'   |H -> Windows.Event.Char 'h'
    |I -> Windows.Event.Char 'i'   |J -> Windows.Event.Char 'j'
    |K -> Windows.Event.Char 'k'   |L -> Windows.Event.Char 'l'
    |M -> Windows.Event.Char 'm'   |N -> Windows.Event.Char 'n'
    |O -> Windows.Event.Char 'o'   |P -> Windows.Event.Char 'p'
    |Q -> Windows.Event.Char 'q'   |R -> Windows.Event.Char 'r'
    |S -> Windows.Event.Char 's'   |T -> Windows.Event.Char 't'
    |U -> Windows.Event.Char 'u'   |V -> Windows.Event.Char 'v'
    |W -> Windows.Event.Char 'w'   |X -> Windows.Event.Char 'x'
    |Y -> Windows.Event.Char 'y'   |Z -> Windows.Event.Char 'z'
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

  let poll_event win = 
	assert false

  let display win = 
	assert false

end


module Keyboard = struct

  let is_pressed kcode = 
	assert false

  let is_shift_down () = 
	assert false

  let is_ctrl_down () = 
	assert false

  let is_alt_down () = 
	assert false

end


module Mouse = struct

  let position () = 
	assert false

  let relative_position win = 
	assert false

  let set_position s = 
	assert false

  let set_relative_position win s = 
	assert false

  let is_pressed but = 
	assert false

end
