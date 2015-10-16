let () = 
  let d = Xlib.create () in
  let (w,h) = Xlib.screen_size d 0 in
  let (wmm, hmm) = Xlib.screen_size_mm d 0 in
  Printf.printf "Screen resolution (px) : %ix%i\n%!" w h;
  Printf.printf "Screen size (mm) : %ix%i\n%!" wmm hmm;
  Printf.printf "Screen definition (ppi) : %f\n%!" ((float_of_int w) *. 25.4 /. (float_of_int wmm))
