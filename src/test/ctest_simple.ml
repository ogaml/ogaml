open Cocoa

let () =
  init_arp ();
  let ns = NSString.create "Hello binding !" in
  NSString.print ns ;
  let app = OGApplication.create () in (* useless for now *)
  (* open_window () *) (* we cannot create two applications *)
  let appdgt = OGApplicationDelegate.create () in
  ()
