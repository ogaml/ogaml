open OgamlGraphics
open OgamlMath

let settings = ContextSettings.create ~color:(`RGB Color.RGB.white) ()
let window = Window.create ~width:800 ~height:600 ~settings

let rect  = Shape.create_rectangle ~position:Vector2i.({ x = 200 ; y = 150 })
                                   ~size:Vector2i.({ x = 400 ; y = 300 })
                                   ~color:(`RGB Color.RGB.blue) ()

let rect2 = Shape.create_rectangle ~position:Vector2i.({ x = 400 ; y = 300 })
                                   ~size:Vector2i.({ x = 400 ; y = 300 })
                                   ~origin:Vector2f.({ x = 200. ; y = 150. })
                                   ~rotation:20.
                                   ~color:(`RGB Color.RGB.red) ()

let rect3 = Shape.create_rectangle ~position:Vector2i.zero
                                   ~size:Vector2i.({ x = 400 ; y = 300 })
                                   ~origin:Vector2f.({ x = 200. ; y = 150. })
                                   ~rotation:45.
                                   ~color:(`RGB Color.RGB.green) ()

let rect4 = Shape.create_rectangle ~position:Vector2i.({ x = 400 ; y = 300 })
                                   ~size:Vector2i.({ x = 400 ; y = 300 })
                                   ~color:(`RGB Color.RGB.yellow) ()

let polygon = Shape.create_polygon
                ~points:Vector2i.([
                  { x =  0 ; y = 40 } ;
                  { x = 20 ; y =  0 } ;
                  { x = 60 ; y =  0 } ;
                  { x = 80 ; y = 40 } ;
                  { x = 40 ; y = 80 }
                ])
                ~color:(`RGB Color.RGB.black)
                ~origin:Vector2f.({ x = 40. ; y = 0. })
                ~position:Vector2i.({ x = 100 ; y = 400 })
                ()

let regular = Shape.create_regular
                ~position:Vector2i.({ x = 400 ; y = 500 })
                ~radius:50.
                ~amount:50
                ~color:(`RGB Color.RGB.cyan)
                ()

let draw () =
  Window.draw_shape window rect ;
  Window.draw_shape window rect2 ;
  Window.draw_shape window rect3 ;
  Window.draw_shape window rect4 ;
  Window.draw_shape window polygon ;
  Window.draw_shape window regular

let animate = let d = ref 0. and growing = ref true in fun () ->
  Shape.rotate polygon 1. ;
  Shape.rotate rect3 (-1.) ;
  Shape.rotate rect4 0.1 ;
  Shape.set_rotation regular (100. *. !d) ;
  Shape.set_scale rect Vector2f.({ x = 1. +. 2. *. !d ; y = 1. +. 2. *. !d }) ;
  Shape.set_scale rect2 Vector2f.({ x = 1. -. !d ; y = 1. +. !d }) ;
  Shape.set_scale rect4 Vector2f.({ x = 1. -. 2. *. !d ; y = 1. -. 2. *. !d }) ;
  Shape.translate polygon Vector2f.(floor { x = 30. *. !d ; y = 0. }) ;
  d := if !growing then !d +. 0.01 else !d -. 0.01 ;
  if abs_float !d >= 0.2 then growing := not (!growing)

let rec handle_events () =
  match Window.poll_event window with
  | Some e -> OgamlCore.Event.(
      match e with
      | Closed -> Window.close window
      | _      -> ()
    ) ; handle_events ()
  | None -> ()

let rec each_frame () =
  if Window.is_open window then begin
    Window.clear window ;
    draw () ;
    Window.display window ;
    animate () ;
    handle_events () ;
    each_frame ()
  end

let () = each_frame ()
