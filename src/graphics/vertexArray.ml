
exception Invalid_vertex of string

exception Invalid_attribute of string

exception Missing_attribute of string

exception Invalid_buffer of string


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
    data     : GL.Data.t;
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
      data = GL.Data.create size
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
    |Position -> GL.Types.GlslType.Float3
    |Color    -> GL.Types.GlslType.Float4
    |Normal   -> GL.Types.GlslType.Float3
    |Texcoord -> GL.Types.GlslType.Float2

  let stride src = 
    List.fold_left (fun v (t,_,_) -> v + size_of_attrib t) 0 (attribs src)


end

type static = unit

type dynamic = unit

type _ t = {
  buffer  : GL.VBO.t;
  vao     : GL.VAO.t;
  size    : int;
  length  : int;
  attribs : (Source.attrib * string * int) list;
  stride  : int;
  mode    : DrawMode.t;
  mutable bound : Program.t option;
  mutable valid : bool
}

let dynamic src mode = 
  let vao    = GL.VAO.create () in
  let buffer = GL.VBO.create () in
  let data = src.Source.data in
  GL.VBO.bind (Some buffer);
  GL.VBO.data (GL.Data.length data * 4) (Some data) (GL.Types.VBOKind.DynamicDraw);
  GL.VBO.bind None;
  {
   buffer; vao; 
   size = GL.Data.length data;
   length = Source.length src; 
   attribs = Source.attribs src;
   stride = Source.stride src;
   mode;  
   bound = None;
   valid = true
  }

let static src mode = 
  let vao    = GL.VAO.create () in
  let buffer = GL.VBO.create () in
  let data = src.Source.data in
  GL.VBO.bind (Some buffer);
  GL.VBO.data (GL.Data.length data * 4) (Some data) (GL.Types.VBOKind.StaticDraw);
  GL.VBO.bind None;
  {
   buffer; vao; 
   size = GL.Data.length data;
   length = Source.length src; 
   attribs = Source.attribs src;
   stride = Source.stride src;
   mode;
   bound = None;
   valid = true
  }

let rebuild t src mode =
  if not t.valid then
    raise (Invalid_buffer "Cannot rebuild buffer, it may have been destroyed");
  let data = src.Source.data in
  GL.VBO.bind (Some t.buffer);
  if t.size < GL.Data.length data then
    GL.VBO.data (GL.Data.length data * 4) None (GL.Types.VBOKind.DynamicDraw);
  GL.VBO.subdata 0 (GL.Data.length data * 4) data;
  GL.VBO.bind None;
  {
   buffer = t.buffer;
   vao    = t.vao;
   size   = max (GL.Data.length data) (t.size);
   length = Source.length src;
   attribs = Source.attribs src;
   stride = Source.stride src;
   mode;
   bound  = t.bound;
   valid  = true
  }

let bind state t prog = 
  if not t.valid then
    raise (Invalid_buffer "Cannot bind buffer, it may have been destroyed");
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
          (GL.Types.GlFloatType.Float)
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

let length t = t.length

let destroy t =
  if not t.valid then
    raise (Invalid_buffer "Cannot destroy buffer : already destroyed");
  GL.VAO.destroy t.vao;
  GL.VBO.destroy t.buffer;
  t.valid <- false

module LL = struct

  let draw state t prog = 
    if not t.valid then
      raise (Invalid_buffer "Cannot draw buffer, it may have been destroyed");
    bind state t prog;
    GL.VAO.draw t.mode 0 t.length

end
