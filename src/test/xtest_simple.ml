open Xlib

let () = 
  let d = Display.create () in
  let (w,h) = Display.screen_size d in
  let (wmm,hmm) = Display.screen_size_mm d in
  Printf.printf "Screen resolution (px) : %ix%i\n%!" w h;
  Printf.printf "Screen size (mm) : %ix%i\n%!" wmm hmm;
  Printf.printf "Screen definition (ppi) : %f\n%!" ((float_of_int w) *. 25.4 /. (float_of_int wmm));
  let rwin = Window.root_of d in
  let win = Window.create_simple
    ~display:d ~parent:rwin ~size:(800,600) ~origin:(50,50) ~background:(255 * 256)
  in
  let atom = Atom.intern d "WM_DELETE_WINDOW" false in
  begin 
    match atom with
    |None -> assert false
    |Some(a) -> Atom.set_wm_protocols d win [a]
  end;
  Window.map d win;
  Event.set_mask d win [Event.ExposureMask; Event.KeyPressMask; Event.ButtonPressMask];
  Display.flush d;
  let (w,h) = Window.size d win in
  Printf.printf "Window size : %i %i\n%!" w h;
  let rec loop () = 
    match Event.next d with
    |Some e when Event.type_of e = Event.ClientMessage -> print_endline "Window closed"; ()
    |Some e when Event.type_of e = Event.KeyPress      -> print_endline "Key pressed"; loop ()
    | _ -> loop()
  in
  loop ();
  Window.destroy d win
