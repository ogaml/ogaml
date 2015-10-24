open Xlib
open Tgl4
open OgamlMath

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
  Gl.enable Gl.cull_face_enum;
  Gl.enable Gl.depth_test;
  Gl.cull_face Gl.back;
  Gl.front_face Gl.ccw;
  Gl.clear_color 1.0 1.0 1.0 1.0;

  (* Pointer utils *)
  let new_int () = Bigarray.Array1.create Bigarray.int32 Bigarray.c_layout 1 in

(*   let new_string l = Bigarray.Array1.create Bigarray.char Bigarray.c_layout l in *)

  let bind_int f = 
    let tab = new_int () in 
    f tab; Int32.to_int tab.{0}
  in

  (* Vertices *)
  let vertices =
    Bigarray.Array1.of_array Bigarray.float32 Bigarray.c_layout [|
      (* Bottom *)
      -0.5; -0.5; -0.5;  1.0; 0.0; 0.0;
      -0.5; -0.5;  0.5;  1.0; 0.0; 0.0;
       0.5; -0.5; -0.5;  1.0; 0.0; 0.0;
               
       0.5; -0.5; -0.5;  1.0; 0.0; 0.0;
      -0.5; -0.5;  0.5;  1.0; 0.0; 0.0;
       0.5; -0.5;  0.5;  1.0; 0.0; 0.0;
                
      (* Up *)  
      -0.5;  0.5; -0.5;  0.0; 1.0; 1.0;
       0.5;  0.5; -0.5;  0.0; 1.0; 1.0;
      -0.5;  0.5;  0.5;  0.0; 1.0; 1.0;
                 
      -0.5;  0.5;  0.5;  0.0; 1.0; 1.0;
       0.5;  0.5; -0.5;  0.0; 1.0; 1.0;
       0.5;  0.5;  0.5;  0.0; 1.0; 1.0;
                  
      (* Right *)
       0.5; -0.5; -0.5;  1.0; 0.0; 1.0;
       0.5; -0.5;  0.5;  1.0; 0.0; 1.0;
       0.5;  0.5; -0.5;  1.0; 0.0; 1.0;
                   
       0.5;  0.5; -0.5;  1.0; 0.0; 1.0;
       0.5; -0.5;  0.5;  1.0; 0.0; 1.0;
       0.5;  0.5;  0.5;  1.0; 0.0; 1.0;
                    
      (* Left *)
      -0.5; -0.5; -0.5;  1.0; 1.0; 0.0;
      -0.5;  0.5; -0.5;  1.0; 1.0; 0.0;
      -0.5; -0.5;  0.5;  1.0; 1.0; 0.0;
                     
      -0.5; -0.5;  0.5;  1.0; 1.0; 0.0;
      -0.5;  0.5; -0.5;  1.0; 1.0; 0.0;
      -0.5;  0.5;  0.5;  1.0; 1.0; 0.0;
                
      (* Front *)
      -0.5; -0.5;  0.5;  0.0; 1.0; 0.0;
      -0.5;  0.5;  0.5;  0.0; 1.0; 0.0;
       0.5; -0.5;  0.5;  0.0; 1.0; 0.0;
                      
       0.5; -0.5;  0.5;  0.0; 1.0; 0.0;
      -0.5;  0.5;  0.5;  0.0; 1.0; 0.0;
       0.5;  0.5;  0.5;  0.0; 1.0; 0.0;
                 
      (* Back *) 
      -0.5; -0.5; -0.5;  0.0; 0.0; 1.0;
       0.5; -0.5; -0.5;  0.0; 0.0; 1.0;
      -0.5;  0.5; -0.5;  0.0; 0.0; 1.0;
                  
      -0.5;  0.5; -0.5;  0.0; 0.0; 1.0;
       0.5; -0.5; -0.5;  0.0; 0.0; 1.0;
       0.5;  0.5; -0.5;  0.0; 0.0; 1.0;
    |]
  in

  (* VBO creation *)
  let vbo = bind_int (Gl.gen_buffers 1) in
  Gl.bind_buffer Gl.array_buffer vbo;
  Gl.buffer_data Gl.array_buffer (Gl.bigarray_byte_size vertices)
    (Some vertices) Gl.static_draw;
  Gl.bind_buffer Gl.array_buffer 0;

  (* Compile GL program *)
  let prog = Gl.create_program () in
  let vert = Gl.create_shader Gl.vertex_shader in
             Gl.shader_source vert vertex;
             Gl.compile_shader vert;
  let frag = Gl.create_shader Gl.fragment_shader in
             Gl.shader_source frag fragment;
             Gl.compile_shader frag;
  Gl.attach_shader prog vert;
  Gl.attach_shader prog frag;
  Gl.link_program prog;
  let mvploc = Gl.get_uniform_location prog "MVPMatrix" in
  let posloc = Gl.get_attrib_location  prog "position"  in
  let colloc = Gl.get_attrib_location  prog "in_color"  in

  (* VAO creation *)
  let vao = bind_int (Gl.gen_vertex_arrays 1) in
  Gl.bind_vertex_array vao;
  Gl.bind_buffer Gl.array_buffer vbo;
  (* Position attribute *)
  Gl.enable_vertex_attrib_array posloc;
  Gl.vertex_attrib_pointer posloc 3 
    Gl.float false
    24 (`Offset 0);
  Gl.vertex_attrib_divisor posloc 0;
  (* Color attribute *)
  Gl.enable_vertex_attrib_array colloc;
  Gl.vertex_attrib_pointer colloc 3 
    Gl.float false
    24 (`Offset 12);
  Gl.vertex_attrib_divisor posloc 0;
  (* Unbinding *)
  Gl.bind_buffer Gl.array_buffer 0;
  Gl.bind_vertex_array 0;

  (* Create matrices *)
(*   let proj = Matrix3f.perspective ~near:0.01 ~far:1000. ~width:800. ~height:600. ~fov:(90. *. 3.141592 /. 180.) in *)
  let proj = Matrix3f.orthographic ~near:(-5.) ~far:(5.) ~left:(-2.) ~right:(2.) ~top:(1.5) ~bottom:(-1.5) in
  let view = Matrix3f.look_at 
    ~from:Vector3f.({x = 1.0; y = 0.; z = 0.}) 
    ~at:Vector3f.({x = 0.; y = 0.; z = 0.})
    ~up:Vector3f.unit_y
  in
  let vp = Matrix3f.product proj view in

  let rot_vector = Vector3f.({x = 0.8; y = 1.; z = 1.2}) in
  let rot_angle = ref 0. in

  (* Display *)
  let display () = 
    Gl.use_program prog;

    let model = Matrix3f.rotation rot_vector !rot_angle in
    let mvp = Matrix3f.product vp model in

    rot_angle := !rot_angle +. (abs_float (cos (Unix.gettimeofday ()) /. 10.));

    Gl.uniform_matrix4fv mvploc 1 false (Matrix3f.to_bigarray mvp);
    Gl.bind_vertex_array vao;
    Gl.draw_arrays Gl.triangles 0 36;
    Gl.bind_vertex_array 0;
    Gl.use_program 0;
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
    Gl.clear (Gl.color_buffer_bit lor Gl.depth_buffer_bit);
    display ();
    Window.swap d win;
    if event_loop () then ()
    else loop ()
  in

  loop ();
  Window.destroy d win


