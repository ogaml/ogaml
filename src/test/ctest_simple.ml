open Cocoa

let () =
  init_arp ();
  let ns = NSString.create "Hello binding !" in
  NSString.print ns ;
  let appdgt = OGApplicationDelegate.create () in
  OGApplication.init appdgt ;
  let rect = NSRect.create 200 300 400 500 in
  let window = NSWindow.(
    create ~frame:rect
           ~style_mask:[Titled;Closable;Miniaturizable;Resizable]
           ~backing:Buffered
           ~defer:false ()
  ) in
  NSWindow.set_background_color window (NSColor.magenta ());
  NSWindow.make_key_and_order_front window;
  NSWindow.center window;
  NSWindow.make_main window;
  (* Maybe this is bad because we actually never need the OGApplication.t *)
  OGApplication.run ()
