open OgamlGraphics
open OgamlMath
open OgamlUtils
open Result.Operators

let fail ?msg err = 
  Log.fatal Log.stdout "%s" err;
  begin match msg with
  | None -> ()
  | Some e -> Log.fatal Log.stderr "%s" e
  end;
  exit 2

let settings =
  OgamlCore.ContextSettings.create
    ~msaa:8
    ~resizable:true
    ~fullscreen:true
    ()

let window =
  match Window.create ~width:900 ~height:600 ~settings ~title:"Flat Example" () with
  | Ok win -> win
  | Error (`Context_initialization_error msg) -> 
    fail ~msg "Failed to create context"
  | Error (`Window_creation_error msg) -> 
    fail ~msg "Failed to create window"

let base_transform = ref (Transform2D.create ())

let global_thickness = ref 0.

let draw () =
  let rectangle1 =
    let transform = 
      Transform2D.compose ~translation:Vector2f.{x = 50.; y = 50.} !base_transform
    in
    Shape.create_rectangle
      ~transform
      ~thickness:!global_thickness
      ~size:Vector2f.({ x = 200. ; y = 150. })
      ~color:(`RGB Color.RGB.blue)
      ~border_color:(`RGB Color.RGB.red)
      ()
  in
  let rectangle2 =
    let transform = 
      Transform2D.compose ~translation:Vector2f.{x = 150.; y = 450.} !base_transform
      |> Transform2D.set ~origin:Vector2f.{x = 100.; y = 75.}
    in
    Shape.create_rectangle
      ~transform
      ~thickness:!global_thickness
      ~size:Vector2f.({ x = 200. ; y = 150. })
      ~color:(`RGB Color.RGB.red)
      ~border_color:(`RGB Color.RGB.blue)
      ()
  in
  let polygon1 =
    let transform = 
      Transform2D.compose ~translation:Vector2f.{x = 370.; y = 70.} !base_transform
    in
    Shape.create_polygon
      ~points:Vector2f.([
        { x =   0. ; y =  80. } ;
        { x =  40. ; y =   0. } ;
        { x = 120. ; y =   0. } ;
        { x = 160. ; y =  80. } ;
        { x =  80. ; y = 160. }
      ])
      ~color:(`RGB Color.RGB.green)
      ~border_color:(`RGB Color.RGB.magenta)
      ~transform
      ~thickness:!global_thickness
      ()
  in 
  let polygon2 =
    let transform = 
      Transform2D.compose ~translation:Vector2f.{x = 450.; y = 450.} !base_transform
      |> Transform2D.set ~origin:Vector2f.{x = 80.; y = 80.}
    in
    Shape.create_polygon
      ~points:Vector2f.([
        { x =   0. ; y =  80. } ;
        { x =  40. ; y =   0. } ;
        { x = 120. ; y =   0. } ;
        { x = 160. ; y =  80. } ;
        { x =  80. ; y = 160. }
      ])
      ~color:(`RGB Color.RGB.magenta)
      ~border_color:(`RGB Color.RGB.green)
      ~transform
      ~thickness:!global_thickness
      ()
  in 
  let regular1 =
    let transform = 
      Transform2D.compose ~translation:Vector2f.{x = 650.; y = 50.} !base_transform
    in
    Shape.create_regular
      ~transform
      ~radius:100.
      ~amount:10
      ~color:(`RGB Color.RGB.cyan)
      ~border_color:(`RGB Color.RGB.yellow)
      ~thickness:!global_thickness
      ()
  in 
  let regular2 =
    let transform = 
      Transform2D.compose ~translation:Vector2f.{x = 750.; y = 450.} !base_transform
      |> Transform2D.set ~origin:Vector2f.{x = 100.; y = 100.}
    in
    Shape.create_regular
      ~radius:100.
      ~amount:10
      ~transform
      ~color:(`RGB Color.RGB.yellow)
      ~border_color:(`RGB Color.RGB.cyan)
      ~thickness:!global_thickness
      ()
  in 
  let line1 =
    let transform = 
      Transform2D.compose ~translation:Vector2f.{x = 50.; y = 300.} !base_transform
    in
    Shape.create_segment
      ~thickness:(3. +. !global_thickness)
      ~segment:Vector2f.({ x = 300. ; y = 0. })
      ~transform
      ~color:(`RGB Color.RGB.({ r = 0.21 ; g = 0.2 ; b = 0.23 ; a = 1. }))
      ()
  in 
  let line2 =
    let transform = 
      Transform2D.compose ~translation:Vector2f.{x = 700.; y = 300.} !base_transform
      |> Transform2D.set ~origin:Vector2f.{x = 150.; y = 0.}
    in
    Shape.create_segment
      ~thickness:(3. +. !global_thickness)
      ~segment:Vector2f.({ x = 300. ; y = 0. })
      ~transform
      ~color:(`RGB Color.RGB.({ r = 0.21 ; g = 0.2 ; b = 0.23 ; a = 1. }))
      ()
  in 
  let circle =
    let transform = 
      Transform2D.compose ~translation:Vector2f.{x = 450.; y = 300.} !base_transform
      |> Transform2D.set ~origin:Vector2f.{x = 10.; y = 10.}
    in
    Shape.create_regular
      ~radius:10.
      ~amount:20
      ~transform
      ~color:(`RGB Color.RGB.transparent)
      ~thickness:(3. +. !global_thickness)
      ~border_color:(`RGB Color.RGB.({ r = 0.21 ; g = 0.2 ; b = 0.23 ; a = 1. }))
      ()
  in
  Shape.draw (module Window) ~target:window ~shape:rectangle1 ();
  Shape.draw (module Window) ~target:window ~shape:rectangle2 ();
  Shape.draw (module Window) ~target:window ~shape:polygon1 ();
  Shape.draw (module Window) ~target:window ~shape:polygon2 ();
  Shape.draw (module Window) ~target:window ~shape:regular1 ();
  Shape.draw (module Window) ~target:window ~shape:regular2 ();
  Shape.draw (module Window) ~target:window ~shape:line1 ();
  Shape.draw (module Window) ~target:window ~shape:line2 ();
  Shape.draw (module Window) ~target:window ~shape:circle ()

let action func param = 
  base_transform := func param !base_transform

let rec handle_events () =
  let open OgamlCore in
  match Window.poll_event window with
  | Some e -> Event.(
      match e with
      | Closed -> Window.close window
      | Event.KeyPressed k -> Keycode.(
        match k.Event.KeyEvent.key with
        | Q when k.Event.KeyEvent.control -> Window.close window
        (* Moving around all shapes *)
        | Z -> action Transform2D.translate Vector2f.({ x =  0. ; y = -5. })
        | Q -> action Transform2D.translate Vector2f.({ x = -5. ; y =  0. })
        | S -> action Transform2D.translate Vector2f.({ x =  0. ; y =  5. })
        | D -> action Transform2D.translate Vector2f.({ x =  5. ; y =  0. })
        (* Do a slow barrel roll *)
        | O -> action Transform2D.rotate (-0.4)
        | P -> action Transform2D.rotate 0.4
        (* Resizing *)
        | F -> action Transform2D.rescale Vector2f.({ x = 0.8  ; y = 1.   })
        | H -> action Transform2D.rescale Vector2f.({ x = 1.25 ; y = 1.   })
        | T -> action Transform2D.rescale Vector2f.({ x = 1.   ; y = 1.25 })
        | G -> action Transform2D.rescale Vector2f.({ x = 1.   ; y = 0.8  })
        (* This is thick! *)
        | V -> global_thickness := max (!global_thickness -. 1.) 0.
        | B -> global_thickness := !global_thickness +. 1.
        (* Resizing the window *)
        | M -> Window.resize window Vector2i.({ x = 500 ; y = 400 })
        | L -> Window.toggle_fullscreen window |> ignore
        | _ -> ()
      )
      | _      -> ()
    ) ; handle_events ()
  | None -> ()

let rec each_frame () =
  if Window.is_open window then begin
    Window.clear ~color:(Some (`RGB Color.RGB.white)) window |> Result.assert_ok;
    draw () ;
    Window.display window ;
    handle_events () ;
    each_frame ()
  end

let () = each_frame ()
