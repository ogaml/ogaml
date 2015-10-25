open Cocoa

let rec main_loop () =
  main_loop ()

let () =
  init_arp () ;
  open_window () ;
  main_loop ()
