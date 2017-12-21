(******************************************************************)
(*                                                                *)
(*                     Ogaml Tutorial n°01                        *)
(*                                                                *)
(*                       Hello Window                             *)
(*                                                                *)
(******************************************************************)

open OgamlGraphics
open Utils

let settings = OgamlCore.ContextSettings.create ()

let window =
  match Window.create ~width:800 ~height:600 ~settings ~title:"Tutorial n°01" () with
  | Ok win -> win
  | Error (`Context_initialization_error msg) -> 
    fail ~msg "Failed to create context"
  | Error (`Window_creation_error msg) -> 
    fail ~msg "Failed to create window"

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
    Window.clear window |> assert_ok;
    (* Display here *)
    Window.display window;
    event_loop ();
    main_loop ();
  end

let () = main_loop ()
