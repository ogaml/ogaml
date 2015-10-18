open Cocoa

let () =
  init_arp ();
  let ns = NSString.create "Hello binding !" in
  NSString.print ns ;
  open_window ()
