
exception Invalid_source of string

exception Invalid_vertex of string

exception Invalid_attribute of string

exception Missing_attribute of string


module Vertex = struct

  type t = {
    position : OgamlMath.Vector3f.t option;
    texcoord : OgamlMath.Vector2f.t option;
    normal   : OgamlMath.Vector3f.t option;
    color    : Color.t option
  }

  let create ?position ?texcoord ?normal ?color () = 
    {
      position;
      texcoord;
      normal  ;
      color
    }
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

  let add src v = 
    begin 
      match v.Vertex.position with
      |None when src.position <> None -> 
        raise (Invalid_vertex "Missing vertex position")
      |Some _ when src.position = None ->
        raise (Invalid_vertex "Vertex position not required by source")
      |Some vec -> GL.Data.add_3f src.data vec
      | _ -> ()
    end;
    begin 
      match v.Vertex.texcoord with
      |None when src.texcoord <> None -> 
        raise (Invalid_vertex "Missing texture coordinate")
      |Some _ when src.texcoord = None ->
        raise (Invalid_vertex "Texture coordinate not required by source")
      |Some vec -> GL.Data.add_2f src.data vec
      | _ -> ()
    end;
    begin 
      match v.Vertex.normal with
      |None when src.normal <> None -> 
        raise (Invalid_vertex "Missing vertex normal")
      |Some _ when src.normal = None ->
        raise (Invalid_vertex "Vertex normal not required by source")
      |Some vec -> GL.Data.add_3f src.data vec
      | _ -> ()
    end;
    begin 
      match v.Vertex.color with
      |None when src.color <> None -> 
        raise (Invalid_vertex "Missing vertex color")
      |Some _ when src.color = None ->
        raise (Invalid_vertex "Vertex color not required by source")
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
    |Color    -> GLTypes.GlslType.Float4
    |Normal   -> GLTypes.GlslType.Float3
    |Texcoord -> GLTypes.GlslType.Float2

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
}

let dynamic src = 
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
  }

let static src = 
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
    State.LL.set_bound_vao state (Some t.vao);
    GL.VBO.bind (Some t.buffer);
    State.LL.set_bound_vbo state (Some t.buffer);
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
    Program.LL.iter_attributes prog 
      (fun att ->
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
      );
    if !attribs <> [] then
      raise (Invalid_attribute
        (Printf.sprintf "Attribute %s not required by program" 
          (let (_,s,_) = List.hd !attribs in s)
        ))
  end
  else if State.LL.bound_vao state <> (Some t.vao) then begin
    GL.VAO.bind (Some t.vao);
    State.LL.set_bound_vao state (Some t.vao);
    State.LL.set_bound_vbo state (Some t.buffer);
  end


let draw ~vertices ~window ?indices ~program 
         ?uniform:(uniform = Uniform.empty) 
         ?parameters:(parameters = DrawParameter.make ()) 
         ~mode () =
  let state = Window.state window in
  Window.LL.bind_draw_parameters window parameters;
  Program.LL.use state (Some program);
  Program.LL.iter_uniforms program (fun unif -> Uniform.LL.bind state uniform unif);
  bind state vertices program;
  match indices with
  |None -> GL.VAO.draw mode 0 (length vertices)
  |Some ebo ->
    IndexArray.LL.bind state ebo;
    GL.VAO.draw_elements mode (IndexArray.length ebo)



