open Cocoa

let () =
  init_arp ();
  let ns = NSString.create "Hello binding !" in
  NSString.print ns ;
  let app = OGApplication.create () in (* useless for now *)
  (* open_window () *) (* we cannot create two applications *)
  let appdgt = OGApplicationDelegate.create () in
  let rect = NSRect.create 200 300 400 500 in
  let window = NSWindow.(
    create ~frame:rect
           ~style_mask:[Titled;Closable;Miniaturizable;Resizable] ()
  ) in
  (* Maybe this is bad because we actually never need the OGApplication.t *)
  OGApplication.run ()
