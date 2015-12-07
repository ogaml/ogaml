open OgamlGraphics
open OgamlMath

let cube_shader = "

uniform mat4 MVPMatrix;

in vec3 position;

in int color;

in ivec3 normal;

out vec3 out_normal;

out vec4 out_color;


void main() {

  gl_Position = MVPMatrix * vec4(position, 1.0);

  out_normal.x = float(normal.x);
  out_normal.y = float(normal.y);
  out_normal.z = float(normal.z);

  out_color.r = float((color >> 16) & 255) / 255.0;
  out_color.g = float((color >> 8) & 255) / 255.0;
  out_color.b = float(color & 255) / 255.0;
  out_color.a = 1.0;

}
"


let settings = OgamlCore.ContextSettings.create ()

let window =
  Window.create ~width:800 ~height:600 ~settings ~title:"VertexMap Example"

let initial_time = ref 0.

let frame_count  = ref 0

let axis_source =
  let src = VertexArray.Source.empty
    ~position:"in_position"
    ~color:"in_color"
    ~size:6 ()
  in
  Poly.axis src Vector3f.({x = -1.; y = -1.; z = -1.}) Vector3f.({x = 5.; y = 5.; z = 5.})

let color_bitmask (r,g,b) =
  (r lsl 16) lor (g lsl 8) lor b

let make_vertex normal position (r,g,b) =
  VertexMap.Vertex.empty
  |> VertexMap.Vertex.vector3i "normal" normal
  |> VertexMap.Vertex.int "color" (color_bitmask (r,g,b))
  |> VertexMap.Vertex.vector3f "position" position

let cube_source =
  VertexMap.Source.(
    empty ()
    << make_vertex Vector3i.unit_x Vector3f.({x =  0.5; y =  0.5; z =  0.5}) (255, 0, 0)
    << make_vertex Vector3i.unit_x Vector3f.({x =  0.5; y = -0.5; z =  0.5}) (255, 0, 0)
    << make_vertex Vector3i.unit_x Vector3f.({x =  0.5; y = -0.5; z = -0.5}) (255, 0, 0)
    << make_vertex Vector3i.unit_x Vector3f.({x =  0.5; y =  0.5; z = -0.5}) (255, 0, 0)
    << make_vertex Vector3i.unit_y Vector3f.({x =  0.5; y =  0.5; z =  0.5}) (0, 255, 0)
    << make_vertex Vector3i.unit_y Vector3f.({x = -0.5; y =  0.5; z =  0.5}) (0, 255, 0)
    << make_vertex Vector3i.unit_y Vector3f.({x = -0.5; y =  0.5; z = -0.5}) (0, 255, 0)
    << make_vertex Vector3i.unit_y Vector3f.({x =  0.5; y =  0.5; z = -0.5}) (0, 255, 0)
    << make_vertex Vector3i.unit_z Vector3f.({x =  0.5; y =  0.5; z =  0.5}) (0, 0, 255)
    << make_vertex Vector3i.unit_z Vector3f.({x =  0.5; y = -0.5; z =  0.5}) (0, 0, 255)
    << make_vertex Vector3i.unit_z Vector3f.({x = -0.5; y = -0.5; z =  0.5}) (0, 0, 255)
    << make_vertex Vector3i.unit_z Vector3f.({x = -0.5; y =  0.5; z =  0.5}) (0, 0, 255)
    << make_vertex Vector3i.(prop (-1) unit_x) Vector3f.({x = -0.5; y =  0.5; z =  0.5}) (255, 255, 0)
    << make_vertex Vector3i.(prop (-1) unit_x) Vector3f.({x = -0.5; y = -0.5; z =  0.5}) (255, 255, 0)
    << make_vertex Vector3i.(prop (-1) unit_x) Vector3f.({x = -0.5; y = -0.5; z = -0.5}) (255, 255, 0)
    << make_vertex Vector3i.(prop (-1) unit_x) Vector3f.({x = -0.5; y =  0.5; z = -0.5}) (255, 255, 0)
    << make_vertex Vector3i.(prop (-1) unit_y) Vector3f.({x =  0.5; y = -0.5; z =  0.5}) (255, 0, 255)
    << make_vertex Vector3i.(prop (-1) unit_y) Vector3f.({x = -0.5; y = -0.5; z =  0.5}) (255, 0, 255)
    << make_vertex Vector3i.(prop (-1) unit_y) Vector3f.({x = -0.5; y = -0.5; z = -0.5}) (255, 0, 255)
    << make_vertex Vector3i.(prop (-1) unit_y) Vector3f.({x =  0.5; y = -0.5; z = -0.5}) (255, 0, 255)
    << make_vertex Vector3i.(prop (-1) unit_z) Vector3f.({x =  0.5; y =  0.5; z = -0.5}) (0, 255, 255)
    << make_vertex Vector3i.(prop (-1) unit_z) Vector3f.({x =  0.5; y = -0.5; z = -0.5}) (0, 255, 255)
    << make_vertex Vector3i.(prop (-1) unit_z) Vector3f.({x = -0.5; y = -0.5; z = -0.5}) (0, 255, 255)
    << make_vertex Vector3i.(prop (-1) unit_z) Vector3f.({x = -0.5; y =  0.5; z = -0.5}) (0, 255, 255)
  )

let cube_indices =
  IndexArray.Source.(
    empty 36
    << 0  << 1  << 3  << 3  << 1  << 2
    << 4  << 7  << 5  << 5  << 7  << 6
    << 8  << 11 << 9  << 9  << 11 << 10
    << 12 << 15 << 13 << 13 << 15 << 14
    << 16 << 17 << 19 << 17 << 18 << 19
    << 20 << 21 << 23 << 21 << 22 << 23
  )

let axis = VertexArray.static axis_source

let cube = VertexMap.static cube_source

let indices = IndexArray.static cube_indices

let default_program =
  Program.from_source_pp (Window.state window)
    ~vertex_source:(`File "examples/default_shader.vert")
    ~fragment_source:(`File "examples/default_shader.frag")

let cube_program =
  Program.from_source_pp (Window.state window)
    ~vertex_source:(`String cube_shader)
    ~fragment_source:(`File "examples/normals_shader.frag")

(* Display computations *)
let proj = Matrix3D.perspective ~near:0.01 ~far:1000. ~width:800. ~height:600. ~fov:(90. *. 3.141592 /. 180.)

let position = ref Vector3f.({x = 1.; y = 0.6; z = 1.4})

let rot_angle = ref 0.

let view_theta = ref 0.

let view_phi = ref 0.

let display () =
  (* Compute model matrix *)
  let t = Unix.gettimeofday () in
  let view = Matrix3D.look_at_eulerian ~from:!position ~theta:!view_theta ~phi:!view_phi in
  let rot_vector = Vector3f.({x = (cos t); y = (sin t); z = (cos t) *. (sin t)}) in
  let model = Matrix3D.rotation rot_vector !rot_angle in
  let vp = Matrix3D.product proj view in
  let mv = Matrix3D.product view model in
  let mvp = Matrix3D.product vp model in
  rot_angle := !rot_angle +. (abs_float (cos t /. 10.)) /. 3.;
  let parameters =
    DrawParameter.(make
      ~depth_test:true
      ~culling:CullingMode.CullClockwise ())
  in
  let uniform =
    Uniform.empty
    |> Uniform.matrix3D "MVPMatrix" mvp
    |> Uniform.matrix3D "MVMatrix" mv
    |> Uniform.matrix3D "VMatrix" view
  in
  VertexMap.draw ~window ~vertices:cube ~indices ~uniform ~program:cube_program ~parameters ~mode:DrawMode.Triangles ();
  let uniform =
    Uniform.empty
    |> Uniform.matrix3D "MVPMatrix" vp
  in
  VertexArray.draw ~window ~vertices:axis ~uniform ~program:default_program ~parameters ~mode:DrawMode.Lines ()


(* Camera *)
let center = Vector2i.div 2 (Window.size window)

let () = Mouse.set_relative_position window center

let rec update_camera () =
  let vmouse = Mouse.relative_position window in
  let vdelta = Vector2i.sub vmouse center in
  let lim = Constants.pi /. 2. -. 0.1 in
  view_theta := !view_theta -. 0.005 *. (float_of_int vdelta.OgamlMath.Vector2i.x);
  view_phi   := !view_phi   -. 0.005 *. (float_of_int vdelta.OgamlMath.Vector2i.y);
  view_phi   := min (max !view_phi (-.lim)) lim;
  Mouse.set_relative_position window center

(* Handle keys directly by polling the keyboard *)
let handle_keys () =
  OgamlCore.Keycode.(Keyboard.(
    if is_pressed Z || is_pressed Up then
      position := Vector3f.(add
        !position
        {x = -. 0.15 *. (sin !view_theta);
         y = 0.;
         z = -. 0.15 *. (cos !view_theta)}) ;
    if is_pressed S || is_pressed Down then
      position := Vector3f.(add
        !position
        {x = 0.15 *. (sin !view_theta);
         y = 0.;
         z = 0.15 *. (cos !view_theta)}) ;
    if is_pressed Q || is_pressed Left then
      position := Vector3f.(add
        !position
        {x = -. 0.15 *. (cos !view_theta);
         y = 0.;
         z = 0.15 *. (sin !view_theta)}) ;
    if is_pressed D || is_pressed Right then
      position := Vector3f.(add
        !position
        {x = 0.15 *. (cos !view_theta);
         y = 0.;
         z = -. 0.15 *. (sin !view_theta)});
    if is_pressed LShift then
      position := Vector3f.(add
        !position
        {x = 0.; y = -0.15; z = 0.});
    if is_pressed Space then
      position := Vector3f.(add
        !position
        {x = 0.; y = 0.15; z = 0.})
  ))


(* Event loop *)
let rec event_loop () =
  let open OgamlCore in
  match Window.poll_event window with
  |Some e -> begin
    match e with
    |Event.Closed ->
      Window.close window
    |Event.KeyPressed k -> Keycode.(
      match k.Event.KeyEvent.key with
      | Escape -> Window.close window
      | Q when k.Event.KeyEvent.control -> Window.close window
      | _ -> ()
    )
    | _ -> ()
  end; event_loop ()
  |None -> ()


(* Main loop *)
let rec main_loop () =
  if Window.is_open window then begin
    Window.clear ~color:(`RGB Color.RGB.white) window;
    display ();
    Window.display window;
    (* We only capture the mouse and listen to the keyboard when focused *)
    if Window.has_focus window then (
      update_camera () ;
      handle_keys ()
    ) ;
    event_loop ();
    incr frame_count;
    main_loop ()
  end


(* Start *)
let () =
  main_loop ();
  Window.destroy window
