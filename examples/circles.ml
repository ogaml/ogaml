open OgamlGraphics
open OgamlMath

let settings =
  OgamlCore.ContextSettings.create
    ~msaa:8
    ~resizable:true
    ~fullscreen:false
    ()

let window =
  Window.create ~width:900 ~height:600 ~settings ~title:"Circles Example"

let circles =
  let delta = Vector2i.({ x = 401 ; y = 0 }) in
  let rec compute l pos amount n =
    if n <= 0 then l
    else begin
      let circle =
        Shape.create_regular
          ~position:pos
          ~origin:Vector2f.({ x = 200. ; y = 200. })
          ~radius:200.
          ~amount
          ~color:(`RGB Color.RGB.cyan)
          ~border_color:(`RGB Color.RGB.yellow)
          ()
      in compute (circle :: l) (Vector2i.add pos delta) (amount + 10) (n-1)
    end
  in compute [] Vector2i.({ x = 300 ; y = 450 }) 56 2
  (* amount = 4 * sqrt(radius) ? *)

let draw () =
  List.iter (fun shape -> Shape.draw ~window ~shape ()) circles

let rec handle_events () =
  let open OgamlCore in
  match Window.poll_event window with
  | Some e -> Event.(
      match e with
      | Closed -> Window.close window
      | Event.KeyPressed k -> Keycode.(
        match k.Event.KeyEvent.key with
        | Q when k.Event.KeyEvent.control -> Window.close window
        | _ -> ()
      )
      | _      -> ()
    ) ; handle_events ()
  | None -> ()

let rec each_frame () =
  if Window.is_open window then begin
    Window.clear ~color:(`RGB Color.RGB.white) window ;
    draw () ;
    Window.display window ;
    handle_events () ;
    each_frame ()
  end

let () = each_frame ()
