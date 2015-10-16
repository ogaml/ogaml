open Xlib

let () = 
  let d = Display.create () in
  let (w,h) = Display.screen_size d in
  let (wmm,hmm) = Display.screen_size_mm d in
  Printf.printf "Screen resolution (px) : %ix%i\n%!" w h;
  Printf.printf "Screen size (mm) : %ix%i\n%!" wmm hmm;
  Printf.printf "Screen definition (ppi) : %f\n%!" ((float_of_int w) *. 25.4 /. (float_of_int wmm));
  let rwin = Display.root_window d in
  let win = Display.create_simple_window 
    ~display:d ~parent:rwin ~size:(800,600) ~origin:(50,50)
  in
  Display.map_window d win;
  Display.flush d;
  Unix.sleep 3
