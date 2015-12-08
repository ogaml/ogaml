open OgamlGraphics
open OgamlMath

let settings = OgamlCore.ContextSettings.create ()

let window =
  Window.create ~width:800 ~height:600 ~settings ~title:"Text sets tests"

let font = Text.Font.load "examples/font1.ttf"

let font_info size = 
  Printf.printf "------- Font data for size %i -------\n%!" size;
  Printf.printf "\t Ascent   : %i\n%!" (Text.Font.ascent  font size);
  Printf.printf "\t Descent  : %i\n%!" (Text.Font.descent font size);
  Printf.printf "\t Line gap : %i\n%!" (Text.Font.linegap font size);
  Printf.printf "\t Spacing  : %i\n%!" (Text.Font.spacing font size);
  Printf.printf "-------------------------------------\n\n%!"

let print_glyph c size = 
  let glyph = Text.Font.glyph font (`Char c) size false in
  Printf.printf "Character '%c' \n%!" c;
  Printf.printf "\t Advance : %i\n%!" (Text.Glyph.advance glyph);
  Printf.printf "\t Bearing : X = %i, Y = %i\n%!"
      ((Text.Glyph.bearing glyph).OgamlMath.Vector2i.x)
      ((Text.Glyph.bearing glyph).OgamlMath.Vector2i.y);
  Printf.printf "\t Bounds  : X = %i, Y = %i, W = %i, H = %i\n%!"
      ((Text.Glyph.rect glyph).OgamlMath.IntRect.x)
      ((Text.Glyph.rect glyph).OgamlMath.IntRect.y)
      ((Text.Glyph.rect glyph).OgamlMath.IntRect.width)
      ((Text.Glyph.rect glyph).OgamlMath.IntRect.height);
  Printf.printf "\n%!"

let print_kerning c1 c2 size = 
  let kern = Text.Font.kerning font (`Char c1) (`Char c2) size in
  Printf.printf "Kerning %c%c : %i\n\n%!" c1 c2 kern

let () = 
  print_endline "";
  font_info 25;
  print_glyph 'a' 25;
  print_glyph 'g' 25;
  print_glyph 'V' 25;
  print_kerning 'A' 'V' 25;
  print_kerning 'A' 'B' 25;
  print_endline "";
  for i = 0 to 255 do
    Text.Font.glyph font (`Code i) 25 false |> ignore
  done;
  Text.Font.update font 25 

let draw () = 
  let texture = Text.Font.texture font 25 in
  let sprite = Sprite.create ~texture () in
  Sprite.draw ~sprite ~window ()

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
    Window.clear ~color:(`RGB Color.RGB.black) window;
    draw ();
    Window.display window;
    event_loop ();
    main_loop ();
  end

let () = 
  main_loop ()
