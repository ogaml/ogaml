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
    ~display:d ~parent:rwin ~size:(800,600) ~origin:(50,50) ~background:(255 * 256 * 256)
  in
  let atom = Atom.intern d "WM_DELETE_WINDOW" false in
  begin 
    match atom with
    |None -> assert false
    |Some(a) -> Atom.set_wm_protocols d win [a]
  end;
  Window.map d win;
  Display.flush d;
  while true do
    ()
  done
