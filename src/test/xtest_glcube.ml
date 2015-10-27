open Xlib
open OgamlMath
open OgamlGL

let vertex = "
    #version 130

    uniform mat4 MVPMatrix;

    in vec3 position;

    in vec3 in_color;

    out vec3 out_color;

    void main() {

        gl_Position = MVPMatrix * vec4(position, 1.0);

        out_color = in_color;

    }
  "

let fragment = "
    #version 130

    in vec3 out_color;

    out vec4 color;

    void main() {

        color = vec4(vec3(out_color), 1.0);

    }
  "

let () = 
  (* Create display and window *)
  let d = Display.create () in
  let rwin = Window.root_of d in
  let win = Window.create_simple
    ~display:d ~parent:rwin ~size:(800,600) ~origin:(50,50) ~background:(0)
  in
  let atom = Atom.intern d "WM_DELETE_WINDOW" false in
  begin 
    match atom with
    |None -> assert false
    |Some(a) -> Atom.set_wm_protocols d win [a]
  end;
  Window.map d win;
  Event.set_mask d win [Event.ExposureMask; Event.KeyPressMask; Event.ButtonPressMask; Event.PointerMotionMask];
  Display.flush d;

  (* Create and attach gl context *)
  let vi = VisualInfo.choose d [VisualInfo.RGBA; VisualInfo.DepthSize 24; VisualInfo.DoubleBuffer] in
  let ctx = GLContext.create d vi in
  Window.attach d win ctx;

  Config.enable [Config.DepthTest];
  Config.set_culling Config.Back;
  Config.set_front Config.CW;
  Config.set_color 1.0 1.0 1.0;
(*   Gl.polygon_mode (Gl.front_and_back Gl.line); *)

  (* Polygons *)
  let cube = 
    let vertices = 
      Poly.cube 
        Vector3f.({x = -0.5; y = -0.5; z = -0.5})
        Vector3f.({x = 1.; y = 1.; z = 1.})
    in
    let colors = 
      [| 
         1.0; 0.0; 0.0;
         1.0; 0.0; 0.0;
         1.0; 0.0; 0.0;
         1.0; 0.0; 0.0;
         1.0; 0.0; 0.0;
         1.0; 0.0; 0.0;
         0.0; 1.0; 0.0;
         0.0; 1.0; 0.0;
         0.0; 1.0; 0.0;
         0.0; 1.0; 0.0;
         0.0; 1.0; 0.0;
         0.0; 1.0; 0.0;
         0.0; 0.0; 1.0;
         0.0; 0.0; 1.0;
         0.0; 0.0; 1.0;
         0.0; 0.0; 1.0;
         0.0; 0.0; 1.0;
         0.0; 0.0; 1.0;
         1.0; 1.0; 0.0;
         1.0; 1.0; 0.0;
         1.0; 1.0; 0.0;
         1.0; 1.0; 0.0;
         1.0; 1.0; 0.0;
         1.0; 1.0; 0.0;
         0.0; 1.0; 1.0;
         0.0; 1.0; 1.0;
         0.0; 1.0; 1.0;
         0.0; 1.0; 1.0;
         0.0; 1.0; 1.0;
         0.0; 1.0; 1.0;
         1.0; 0.0; 1.0;
         1.0; 0.0; 1.0;
         1.0; 0.0; 1.0;
         1.0; 0.0; 1.0;
         1.0; 0.0; 1.0;
         1.0; 0.0; 1.0;
      |]
    in
    Array.concat [vertices; colors]
  in

  let axis = 
    let vertices = Poly.axis 0. 30. in
    let colors = 
      [|
        1.0; 0.0; 0.0;
        1.0; 0.0; 0.0;
        0.0; 1.0; 0.0;
        0.0; 1.0; 0.0;
        0.0; 0.0; 1.0;
        0.0; 0.0; 1.0
      |]
    in
    Array.concat [vertices; colors]
  in

  (* VBO creation *)
  let vbo_cube = Buffers.VBO.build (Buffers.Data.of_float_array cube) in
  let vbo_axis = Buffers.VBO.build (Buffers.Data.of_float_array axis) in

  (* Compile GL program *)
  let vertex_shader   = Shader.create (`String vertex)   Shader.Vertex   in
  let fragment_shader = Shader.create (`String fragment) Shader.Fragment in
  let program = Program.build 
    ~shaders:[vertex_shader; fragment_shader]
    ~attributes:["position"; "in_color"]
    ~uniforms:["MVPMatrix"]
  in

  (* VAO creation *)
  let open Buffers in
  let vao_cube = VAO.create () in
  VAO.bind (Some vao_cube);
  VBO.bind (Some vbo_cube);
  (* Position attribute *)
  VAO.enable_attrib (Program.attribute program "position");
  VAO.set_attrib
    ~attribute:(Program.attribute program "position")
    ~size:3
    ~kind:VAO.Float
    ~offset:0 ();
  (* color attribute *)
  VAO.enable_attrib (Program.attribute program "in_color");
  VAO.set_attrib
    ~attribute:(Program.attribute program "in_color")
    ~size:3
    ~kind:VAO.Float
    ~offset:(36 * 12) ();
  VBO.bind None;
  VAO.bind None;

  let vao_axis = VAO.create () in
  VAO.bind (Some vao_axis);
  VBO.bind (Some vbo_axis);
  (* Position attribute *)
  VAO.enable_attrib (Program.attribute program "position");
  VAO.set_attrib
    ~attribute:(Program.attribute program "position")
    ~size:3
    ~kind:VAO.Float
    ~offset:0 ();
  (* color attribute *)
  VAO.enable_attrib (Program.attribute program "in_color");
  VAO.set_attrib
    ~attribute:(Program.attribute program "in_color")
    ~size:3
    ~kind:VAO.Float
    ~offset:(18 * 4) ();

  VAO.bind None; 
  VBO.bind None;

  (* Create matrices *)
  let proj = Matrix3f.perspective ~near:0.01 ~far:1000. ~width:800. ~height:600. ~fov:(90. *. 3.141592 /. 180.) in
(*   let proj = Matrix3f.orthographic ~near:(-20.) ~far:(20.) ~left:(-2.) ~right:(2.) ~top:(1.5) ~bottom:(-1.5) in *)
  let view = Matrix3f.look_at 
    ~from:Vector3f.({x = 1.; y = 0.6; z = 1.4}) 
    ~at:Vector3f.({x = 0.; y = 0.; z = 0.})
    ~up:Vector3f.unit_y
  in
  let vp = Matrix3f.product proj view in

  let rot_angle = ref 0. in


  (* Display *)
  let display () = 
    Program.use (Some program);

    (* Compute model matrix *)
    let t = Unix.gettimeofday () in
    let rot_vector = Vector3f.({x = (cos t); y = (sin t); z = (cos t) *. (sin t)}) in
    let model = Matrix3f.rotation rot_vector !rot_angle in
    let mvp = Matrix3f.product vp model in
    rot_angle := !rot_angle +. (abs_float (cos (Unix.gettimeofday ()) /. 10.));

    (* Display the cube *)
    Uniform.set (Uniform.Matrix4 (Matrix3f.to_bigarray mvp)) 
                (Program.uniform program "MVPMatrix");
    VAO.bind_draw vao_cube VAO.Triangles 0 36;
    
    (* Display the axis *)
    Uniform.set (Uniform.Matrix4 (Matrix3f.to_bigarray vp)) 
                (Program.uniform program "MVPMatrix");
    VAO.bind_draw vao_axis VAO.Lines 0 6;

    Program.use None;
  in

  (* Event loop *)
  let rec event_loop () = 
    match Event.next d win with
    |Some e -> begin
      match Event.data e with
      | Event.ClientMessage _ -> print_endline "Window closed"; true
      | _ -> event_loop ()
    end
    |None -> false
  in

  (* Main loop *)
  let rec loop () = 
    Config.clear ();
    display ();
    Window.swap d win;
    if event_loop () then ()
    else loop ()
  in

  loop ();
  Window.destroy d win


