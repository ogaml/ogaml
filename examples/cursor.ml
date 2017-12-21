open OgamlGraphics
open OgamlUtils
open OgamlMath
open Utils

let settings = OgamlCore.ContextSettings.create ()

let window =
  match Window.create ~width:800 ~height:600 ~settings ~title:"Cursor tests" () with
  | Ok win -> win
  | Error (`Context_initialization_error msg) -> 
    fail ~msg "Failed to create context"
  | Error (`Window_creation_error msg) -> 
    fail ~msg "Failed to create window"

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
      | A -> Mouse.set_relative_position window Vector2i.zero
      | B -> Mouse.set_relative_position window (Vector2i.make 800 0)
      | C -> Mouse.set_relative_position window (Vector2i.make 800 600)
      | D -> Mouse.set_relative_position window (Vector2i.make 0 600)
      | E -> Mouse.set_position (Vector2i.make 1280 0)
      | F -> Mouse.set_position (Vector2i.make 1280 1080)
      | G -> Mouse.set_position (Vector2i.make 3200 1080)
      | H -> Mouse.set_position (Vector2i.make 3200 0)
      | _ -> ()
      )
    | _     -> event_loop ()
  ))
  | None -> ()

let rec main_loop () =
  if Window.is_open window then begin
    Window.clear window |> assert_ok;
    (* Display here *)
    Window.display window;
    event_loop ();
    main_loop ();
  end

let () = main_loop ()
