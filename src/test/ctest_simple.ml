open Cocoa

let () =
  init_arp ();
  let ns = NSString.create "Hello binding !" in
  NSString.print ns ;
  let app = OGApplication.create () in (* useless for now *)
  (* open_window () *) (* we cannot create two applications *)
  let appdgt = OGApplicationDelegate.create () in
  let rect = NSRect.create 200 200 200 200 in
  (* let window = NSWindow.create ~frame:rect () in *)
  (* For now it appears creating a window creates another app *)
  ()
