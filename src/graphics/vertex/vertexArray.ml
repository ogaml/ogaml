open OgamlMath

exception Invalid_source of string

exception Invalid_vertex of string

exception Invalid_attribute of string

exception Missing_attribute of string

exception Out_of_bounds of string


module Vertex = struct

  type t = {
    position : Vector3f.t option;
    texcoord : Vector2f.t option;
    normal   : Vector3f.t option;
    color    : Color.t option
  }

  let create ?position ?texcoord ?normal ?color () = 
    {
      position;
      texcoord;
      normal  ;
      color
    }

  let position v = v.position

  let texcoord v = v.texcoord

  let normal v = v.normal

  let color v = v.color

end


module Source = struct

  type attrib =
    | Position
    | Texcoord
    | Normal
    | Color

  type t = {
    position : string option;
    texcoord : string option;
    normal   : string option;
    color    : string option;
    mutable length   : int;
    data     : (float, GL.Data.float_32) GL.Data.t;
  }

  let empty ?position ?normal ?texcoord ?color ~size () = 
    let sizep = if position <> None then 3 else 0 in
    let sizen = if normal   <> None then 3 else 0 in
    let sizet = if texcoord <> None then 2 else 0 in
    let sizec = if color    <> None then 4 else 0 in
    let size  = size * (sizep + sizen + sizet + sizec) in
    {
      position;
      texcoord;
      normal;
      color;
      length = 0;
      data = GL.Data.create_float size
    }

  let requires_position s = s.position <> None

  let requires_normal s = s.normal <> None

  let requires_uv s = s.texcoord <> None

  let requires_color s = s.color <> None

  let attrib_position s = s.position

  let attrib_normal s = s.normal

  let attrib_uv s = s.texcoord

  let attrib_color s = s.color

  let add src v = 
    begin 
      match v.Vertex.position with
      |None when src.position <> None -> 
        raise (Invalid_vertex "Missing vertex position")
      |Some _ when src.position = None -> ()
      |Some vec -> GL.Data.add_3f src.data vec
      | _ -> ()
    end;
    begin 
      match v.Vertex.texcoord with
      |None when src.texcoord <> None -> 
        raise (Invalid_vertex "Missing texture coordinate")
      |Some _ when src.texcoord = None -> ()
      |Some vec -> GL.Data.add_2f src.data vec
      | _ -> ()
    end;
    begin 
      match v.Vertex.normal with
      |None when src.normal <> None -> 
        raise (Invalid_vertex "Missing vertex normal")
      |Some _ when src.normal = None -> ()
      |Some vec -> GL.Data.add_3f src.data vec
      | _ -> ()
    end;
    begin 
      match v.Vertex.color with
      |None when src.color <> None -> 
        raise (Invalid_vertex "Missing vertex color")
      |Some _ when src.color = None -> ()
      |Some vec -> GL.Data.add_color src.data vec
      | _ -> ()
    end;
    src.length <- src.length + 1

  let (<<) src v = add src v; src

  let length src = src.length

  let size_of_attrib = function
    |Position -> 3
    |Color    -> 4
    |Normal   -> 3
    |Texcoord -> 2

  let attribs src = 
    let rec build_list_opt i = function
      |[] -> []
      |(_, None)   :: t -> build_list_opt i t
      |(n, Some s) :: t -> (n, s, i) :: (build_list_opt (size_of_attrib n + i) t)
    in
    build_list_opt 0 [Position, src.position;
                      Texcoord, src.texcoord;
                      Normal  , src.normal;
                      Color   , src.color]

  let type_of_attrib = function
    |Position -> GLTypes.GlslType.Float3
    |Texcoord -> GLTypes.GlslType.Float2
    |Normal   -> GLTypes.GlslType.Float3
    |Color    -> GLTypes.GlslType.Float4

  let stride src = 
    List.fold_left (fun v (t,_,_) -> v + size_of_attrib t) 0 (attribs src)

  let append s1 s2 =
    if (requires_position s1) = (requires_position s2)
    && (requires_normal   s1) = (requires_normal   s2)
    && (requires_uv       s1) = (requires_uv       s2)
    && (requires_color    s1) = (requires_color    s2)
    then begin 
      s1.length <- s1.length + s2.length;
      GL.Data.append s1.data s2.data;
      s1
    end else 
      raise (Invalid_source "Cannot append a source at the end of another source of different type")

  let get s i = 
    let stride = stride s in
    let offset = ref (stride * i) in
    let position =      
      match s.position with
      | None   -> None
      | Some _ -> 
        let vec = (Vector3f.{x = GL.Data.get s.data (!offset+0);
                             y = GL.Data.get s.data (!offset+1);
                             z = GL.Data.get s.data (!offset+2);})
        in
        offset := !offset + 3;
        Some vec
    in
    let texcoord =      
      match s.texcoord with
      | None   -> None
      | Some _ -> 
        let vec = (Vector2f.{x = GL.Data.get s.data (!offset+0);
                             y = GL.Data.get s.data (!offset+1)})
        in
        offset := !offset + 2;
        Some vec
    in
   let normal =      
      match s.normal with
      | None   -> None
      | Some _ -> 
        let vec = (Vector3f.{x = GL.Data.get s.data (!offset+0);
                             y = GL.Data.get s.data (!offset+1);
                             z = GL.Data.get s.data (!offset+2);})
        in
        offset := !offset + 3;
        Some vec
    in
    let color =      
      match s.color with
      | None   -> None
      | Some _ -> 
        let vec = (Color.RGB.{r = GL.Data.get s.data (!offset+0);
                              g = GL.Data.get s.data (!offset+1);
                              b = GL.Data.get s.data (!offset+2);
                              a = GL.Data.get s.data (!offset+3);})
        in
        offset := !offset + 4;
        Some (`RGB vec)
    in
    Vertex.create ?position ?texcoord ?normal ?color ()

  let iter s f = 
    for i = 0 to s.length - 1 do
      f (get s i)
    done

  let map s f = 
    let newsrc = 
      empty ?position:s.position
            ?texcoord:s.texcoord
            ?normal:s.normal
            ?color:s.color
            ~size:s.length ()
    in
    for i = 0 to s.length - 1 do
      add newsrc (f (get s i))
    done;
    newsrc

  let mapto s f d = 
    for i = 0 to s.length - 1 do
      add d (f (get s i))
    done

end


type static

type dynamic

type _ t = {
  mutable buffer  : GL.VBO.t;
  vao     : GL.VAO.t;
  mutable size    : int;
  mutable length  : int;
  attribs : (Source.attrib * string * int) list;
  stride  : int;
  mutable bound : Program.t option;
  id : int
}

let dynamic (type s) (module M : RenderTarget.T with type t = s) target src = 
  let vao    = GL.VAO.create () in
  let buffer = GL.VBO.create () in
  let data = src.Source.data in
  GL.VBO.bind (Some buffer);
  GL.VBO.data (GL.Data.length data * 4) (Some data) (GLTypes.VBOKind.DynamicDraw);
  GL.VBO.bind None;
  {
   buffer; vao; 
   size = GL.Data.length data;
   length = Source.length src; 
   attribs = Source.attribs src;
   stride = Source.stride src;
   bound = None;
   id = State.LL.vao_id (M.state target);
  }

let static (type s) (module M : RenderTarget.T with type t = s) target src = 
  let vao    = GL.VAO.create () in
  let buffer = GL.VBO.create () in
  let data = src.Source.data in
  GL.VBO.bind (Some buffer);
  GL.VBO.data (GL.Data.length data * 4) (Some data) (GLTypes.VBOKind.StaticDraw);
  GL.VBO.bind None;
  {
   buffer; vao; 
   size = GL.Data.length data;
   length = Source.length src; 
   attribs = Source.attribs src;
   stride = Source.stride src;
   bound = None;
   id = State.LL.vao_id (M.state target)
  }

let rebuild t src start =
  let data = src.Source.data in
  let start_vals = t.stride * start in
  if Source.attribs src <> t.attribs then
    raise (Invalid_source "Cannot rebuild vertex array : incompatible vertex source");
  let new_buffer, new_binding = 
    if t.size < GL.Data.length data + start_vals then begin
      let buf = GL.VBO.create () in
      GL.VBO.bind (Some buf);
      GL.VBO.data ((GL.Data.length data + start_vals) * 4) None (GLTypes.VBOKind.DynamicDraw);
      GL.VBO.bind None;
      GL.VBO.copy_subdata t.buffer buf 0 0 (start_vals * 4); 
      buf, None
    end else 
      t.buffer, t.bound
  in
  GL.VBO.bind (Some new_buffer);
  GL.VBO.subdata (start_vals * 4) (GL.Data.length data * 4) data;
  GL.VBO.bind None;
  t.buffer <- new_buffer;
  t.bound  <- new_binding;
  t.length <- Source.length src + start;
  t.size   <- max (GL.Data.length data + start_vals) t.size


let length t = t.length


let bind state t prog = 
  if t.bound <> Some prog then begin
    t.bound <- Some prog;
    GL.VAO.bind (Some t.vao);
    State.LL.set_bound_vao state (Some (t.vao, t.id));
    GL.VBO.bind (Some t.buffer);
    State.LL.set_bound_vbo state (Some (t.buffer, t.id));
    let attribs = ref t.attribs in
    let rec find_remove s = function
      | [] -> 
        raise (Missing_attribute 
          (Printf.sprintf "Attribute %s not provided in vertex source" s)
        )
      | (e,h,off)::t when h = s -> (e,off,t)
      | h::t -> 
        let (e,off,l) = find_remove s t in 
        (e,off,h::l)
    in
    List.iter (fun att ->
        let (typ,offset,l) = find_remove (Program.Attribute.name att) !attribs in
        attribs := l;
        if Source.type_of_attrib typ <> Program.Attribute.kind att then
          raise (Invalid_attribute
            (Printf.sprintf "Attribute %s has invalid type"
              (Program.Attribute.name att)
            ));
        GL.VAO.enable_attrib (Program.Attribute.location att);
        GL.VAO.attrib_float 
          (Program.Attribute.location att)
          (Source.size_of_attrib typ)
          (GLTypes.GlFloatType.Float)
          (offset   * 4)
          (t.stride * 4)
      ) (Program.LL.attributes prog);
    (*if !attribs <> [] then
      Printf.eprintf "Warning : omitting attribute %s not required by program\n%!" 
        (let (_,s,_) = List.hd !attribs in s)*)
  end
  else if State.LL.bound_vao state <> (Some t.id) then begin
    GL.VAO.bind (Some t.vao);
    State.LL.set_bound_vao state (Some (t.vao, t.id));
    State.LL.set_bound_vbo state (Some (t.buffer, t.id));
  end

type debug_times = {
  mutable param_bind_t : float;
  mutable program_bind_t : float;
  mutable uniform_bind_t : float;
  mutable vao_bind_t : float;
  mutable draw_t : float
}

let debug_t = {
  param_bind_t = 0.;
  program_bind_t = 0.;
  uniform_bind_t = 0.;
  vao_bind_t = 0.;
  draw_t = 0.
}

let tm = Unix.gettimeofday 

let draw (type s) (module M : RenderTarget.T with type t = s)
         ~vertices ~target ?indices ~program 
         ?uniform:(uniform = Uniform.empty) 
         ?parameters:(parameters = DrawParameter.make ()) 
         ?start ?length
         ?mode:(mode = DrawMode.Triangles) () =
  if vertices.length <> 0 then begin
    let state = M.state target in
    let start = 
      match start with
      |None -> 0
      |Some i -> i
    in
    let length = 
      match length, indices with
      |None, None     -> vertices.length - start
      |None, Some ebo -> IndexArray.length ebo - start
      |Some l, _ -> l
    in

    let t = tm () in
    M.bind target parameters;
    debug_t.param_bind_t <- debug_t.param_bind_t +. (tm () -. t);

    let t = tm () in
    Program.LL.use state (Some program);
    debug_t.program_bind_t <- debug_t.program_bind_t +. (tm () -. t);

    let t = tm () in
    Uniform.LL.bind state uniform (Program.LL.uniforms program);
    debug_t.uniform_bind_t <- debug_t.uniform_bind_t +. (tm () -. t);

    let t = tm () in
    bind state vertices program;
    debug_t.vao_bind_t <- debug_t.vao_bind_t +. (tm () -. t);

    match indices with
    |None -> 
      if start < 0 || start + length > vertices.length then
        raise (Out_of_bounds "Invalid vertex array bounds")
      else begin
        let t = tm () in
        GL.VAO.draw mode start length;
        debug_t.draw_t <- debug_t.draw_t +. (tm () -. t);
      end
    |Some ebo ->
      if start < 0 || start + length > (IndexArray.length ebo) then
        raise (Out_of_bounds "Invalid index array bounds")
      else begin
        IndexArray.LL.bind state ebo;
        GL.VAO.draw_elements mode start length 
      end
  end



