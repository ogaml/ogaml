open OgamlGraphics
open OgamlMath

let settings = OgamlCore.ContextSettings.create ()

let window =
  Window.create ~width:800 ~height:600 ~settings ~title:"Font sets tests"

let font = Font.load "examples/font1.ttf"

let font_info size =
  Printf.printf "------- Font data for size %i -------\n%!" size;
  Printf.printf "\t Ascent   : %i\n%!" (Font.ascent  font size);
  Printf.printf "\t Descent  : %i\n%!" (Font.descent font size);
  Printf.printf "\t Line gap : %i\n%!" (Font.linegap font size);
  Printf.printf "\t Spacing  : %i\n%!" (Font.spacing font size);
  Printf.printf "-------------------------------------\n\n%!"

let print_glyph c size =
  let glyph = Font.glyph font (`Char c) size false in
  Printf.printf "Character '%c' \n%!" c;
  Printf.printf "\t Advance : %i\n%!" (Font.Glyph.advance glyph);
  Printf.printf "\t Bearing : X = %i, Y = %i\n%!"
      ((Font.Glyph.bearing glyph).OgamlMath.Vector2i.x)
      ((Font.Glyph.bearing glyph).OgamlMath.Vector2i.y);
  Printf.printf "\t Bounds  : X = %i, Y = %i, W = %i, H = %i\n%!"
      ((Font.Glyph.rect glyph).OgamlMath.IntRect.x)
      ((Font.Glyph.rect glyph).OgamlMath.IntRect.y)
      ((Font.Glyph.rect glyph).OgamlMath.IntRect.width)
      ((Font.Glyph.rect glyph).OgamlMath.IntRect.height);
  Printf.printf "\n%!"

let print_kerning c1 c2 size =
  let kern = Font.kerning font (`Char c1) (`Char c2) size in
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
    Font.glyph font (`Code i) 25 false |> ignore
  done

(* let vertex_shader_source_tex_130 = "
  uniform vec2 size;

  in vec3 position;
  in vec2 uv;

  out vec2 frag_uv;

  void main() {

    gl_Position.x = 2.0 * position.x / size.x - 1.0;
    gl_Position.y = 2.0 * (size.y - position.y) / size.y - 1.0;
    gl_Position.z = 0.0;
    gl_Position.w = 1.0;

    frag_uv = vec2(uv.x, 1.0 - uv.y);

  }
"

let fragment_shader_source_tex_130 = "
  uniform sampler2D my_texture;

  in vec2 frag_uv;

  out vec4 out_color;

  void main() {

    out_color = texture(my_texture, frag_uv);

  }
"

let program =
  Program.from_source_pp (Window.state window)
    ~vertex_source:(`String vertex_shader_source_tex_130)
    ~fragment_source:(`String fragment_shader_source_tex_130) *)

(* let hello =
  let source = ref
    VertexArray.Source.(empty ~position:"position" ~texcoord:"uv" ~size:12 ())
  in
  String.iteri (fun i c ->
    let glyph = Font.Font.glyph font (`Char c) 25 false in
    let v = VertexArray.Vertex.create
     ~position:Vector3f.({ x = 250. +. (float_of_int i) *. 25. ; y = 250. ; z = 0. })
     ~texcoord:(Vector2f.from_int (Font.Glyph.bearing glyph))
     ()
    in source := VertexArray.Source.((!source) << v)
  ) "Hello, world" ;
  VertexArray.static (!source) *)

let draw () =
  let texture = Font.texture font 25 in
  let sprite = Sprite.create ~texture () in
  Sprite.draw ~sprite ~window ()
  (* let size = Window.size window in
  let size = Vector2f.from_int size in
  let uniform =
    Uniform.empty
    |> Uniform.vector2f "size" size
    |> Uniform.texture2D "my_texture" texture
  in
  VertexArray.draw
    ~window
    ~vertices:hello
    ~program
    ~parameters:(DrawParameter.make
                  ~depth_test:false
                  ~blend_mode:DrawParameter.BlendMode.alpha ())
    ~uniform
    ~mode:DrawMode.TriangleStrip () *)

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
