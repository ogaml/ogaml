open OgamlGraphics
open OgamlMath
open OgamlUtils

let settings =
  OgamlCore.ContextSettings.create
    ~msaa:8
    ~resizable:true
    ()

let window =
  Window.create ~width:800 ~height:600 ~settings ~title:"Noise Example" ()

let img = 
  Image.create (`Empty (Vector2i.({x = 800; y = 600}), `RGB Color.RGB.white))

let perlin = 
  Random.self_init ();
  Noise.Perlin2D.create ()

let () = 
  let mini = ref 0. in
  let maxi = ref 0. in
  for i = 0 to 799 do
    for j = 0 to 599 do
      let v = Noise.Perlin2D.get perlin 
        Vector2f.{
          x = float_of_int i /. 100. -. 4.;
          y = float_of_int j /. 100. -. 3.;
        }
      in
      mini := min !mini v;
      maxi := max !maxi v;
      let v = (v +. 1.) /. 2. in
      Image.set img Vector2i.({x = i; y = j}) (`RGB Color.RGB.({r = v; g = v; b = v; a = 1.}))
    done;
  done;
  Printf.printf "Noise min : %f, noise max : %f\n%!" !mini !maxi

let tex = 
  Texture.Texture2D.create (module Window) window (`Image img)

let draw = 
  let sprite = Sprite.create ~texture:tex () in
  Sprite.draw (module Window) ~target:window ~sprite

let rec handle_events () =
  let open OgamlCore in
  match Window.poll_event window with
  | Some e -> Event.(
      match e with
      | Closed -> Window.close window
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
