open OgamlGraphics
open OgamlUtils
open OgamlMath

let settings = OgamlCore.ContextSettings.create ()

let window =
  Window.create ~width:800 ~height:600 ~settings ~title:"Tutorial n°01" ()

let rec event_loop () =
  match Window.poll_event window with
  | Some e -> OgamlCore.(Event.(
    match e with
    | Closed -> Window.close window
    | Event.KeyReleased k -> Keycode.(
      match k.Event.KeyEvent.key with
      | Space ->
        Log.debug
          Log.stdout
          "Mouse was at absolute position %s and relative %s"
          (Vector2i.to_string (Mouse.position ()))
          (Vector2i.to_string (Mouse.relative_position window))
      | _ -> ()
      )
    | _     -> event_loop ()
  ))
  | None -> ()

let rec main_loop () =
  if Window.is_open window then begin
    Window.clear window;
    (* Display here *)
    Window.display window;
    event_loop ();
    main_loop ();
  end

let () = main_loop ()
