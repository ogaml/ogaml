(******************************************************************)
(*                                                                *)
(*                     Ogaml Tutorial n°01                        *)
(*                                                                *)
(*                       Hello Window                             *)
(*                                                                *)
(******************************************************************)

open OgamlGraphics

let settings = OgamlCore.ContextSettings.create ()

let window =
  Window.create ~width:800 ~height:600 ~settings ~title:"Tutorial n°01"

let rec event_loop () =
  match Window.poll_event window with
  |Some e -> OgamlCore.Event.(
    match e with
    |Closed -> Window.close window
    | _     -> event_loop ()
  )
  |None -> ()

let rec main_loop () =
  if Window.is_open window then begin
    Window.clear window;
    (* Display here *)
    Window.display window;
    event_loop ();
    main_loop ();
  end

let () = main_loop ()
