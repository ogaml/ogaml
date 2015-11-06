let is_pressed key =
  let keycode = Keycode.(
    match key with
    | A -> `Char 'a'
    | B -> `Char 'b'
    (* ... *)
    | Num1 -> `Keycode 18
    (* ... *)
    | _ -> `Unknown
  ) in
  match keycode with
  | `Char c    -> Cocoa.Keyboard.is_char_pressed c
  | `Keycode c -> Cocoa.Keyboard.is_keycode_pressed c
  | `Unknown   -> false

let is_shift_down () = false

let is_ctrl_down () = false

let is_alt_down () = false
