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

let is_shift_down () = false

let is_ctrl_down () = false

let is_alt_down () = false
