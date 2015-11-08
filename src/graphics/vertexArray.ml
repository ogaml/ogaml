
exception Invalid_vertex of string

exception Invalid_attribute of string

exception Missing_attribute of string

exception Invalid_buffer of string


module Vertex = struct

  type t = {
    position : OgamlMath.Vector3f.t option;
    texcoord : (float * float) option;
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
    data     : Internal.Data.t;
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
      data = Internal.Data.create size
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
      |Some vec -> Internal.Data.add_3f src.data vec
      | _ -> ()
    end;
    begin 
      match v.Vertex.texcoord with
      |None when src.texcoord <> None -> 
        raise (Invalid_vertex "Missing texture coordinate")
      |Some _ when src.texcoord = None ->
        raise (Invalid_vertex "Texture coordinate not required by source")
      |Some vec -> Internal.Data.add_2f src.data vec
      | _ -> ()
    end;
    begin 
      match v.Vertex.normal with
      |None when src.normal <> None -> 
        raise (Invalid_vertex "Missing vertex normal")
      |Some _ when src.normal = None ->
        raise (Invalid_vertex "Vertex normal not required by source")
      |Some vec -> Internal.Data.add_3f src.data vec
      | _ -> ()
    end;
    begin 
      match v.Vertex.color with
      |None when src.color <> None -> 
        raise (Invalid_vertex "Missing vertex color")
      |Some _ when src.color = None ->
        raise (Invalid_vertex "Vertex color not required by source")
      |Some vec -> Internal.Data.add_color src.data vec
      | _ -> ()
    end;
    src

  let (<<) src v = add src v

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
    |Position -> Enum.GlslType.Float3
    |Color    -> Enum.GlslType.Float4
    |Normal   -> Enum.GlslType.Float3
    |Texcoord -> Enum.GlslType.Float2

  let stride src = 
    List.fold_left (fun v (t,_,_) -> v + size_of_attrib t) 0 (attribs src)


end

type static = unit

type dynamic = unit

type _ t = {
  buffer  : Internal.VBO.t;
  vao     : Internal.VAO.t;
  size    : int;
  length  : int;
  attribs : (Source.attrib * string * int) list;
  stride  : int;
  mode    : Enum.DrawMode.t;
  mutable bound : Program.t option;
  mutable valid : bool
}

let dynamic src mode = 
  let vao    = Internal.VAO.create () in
  let buffer = Internal.VBO.create () in
  let data = src.Source.data in
  Internal.VBO.bind (Some buffer);
  Internal.VBO.data (Internal.Data.length data * 4) (Some data) (Enum.VBOKind.DynamicDraw);
  Internal.VBO.bind None;
  {
   buffer; vao; 
   size = Internal.Data.length data;
   length = Internal.Data.length data; 
   attribs = Source.attribs src;
   stride = Source.stride src;
   mode;  
   bound = None;
   valid = true
  }

let static src mode = 
  let vao    = Internal.VAO.create () in
  let buffer = Internal.VBO.create () in
  let data = src.Source.data in
  Internal.VBO.bind (Some buffer);
  Internal.VBO.data (Internal.Data.length data * 4) (Some data) (Enum.VBOKind.StaticDraw);
  Internal.VBO.bind None;
  {
   buffer; vao; 
   size = Internal.Data.length data;
   length = Internal.Data.length data; 
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
  Internal.VBO.bind (Some t.buffer);
  if t.size < Internal.Data.length data then
    Internal.VBO.data (Internal.Data.length data * 4) None (Enum.VBOKind.DynamicDraw);
  Internal.VBO.subdata 0 (Internal.Data.length data * 4) data;
  Internal.VBO.bind None;
  {
   buffer = t.buffer;
   vao    = t.vao;
   size   = max (Internal.Data.length data) (t.size);
   length = Internal.Data.length data;
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
    Internal.VAO.bind (Some t.vao);
    State.set_bound_vao state (Some t.vao);
    Internal.VBO.bind (Some t.buffer);
    State.set_bound_vbo state (Some t.buffer);
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
    Program.iter_attributes prog 
      (fun att ->
        let (typ,offset,l) = find_remove (Program.Attribute.name att) !attribs in
        attribs := l;
        if Source.type_of_attrib typ <> Program.Attribute.kind att then
          raise (Invalid_attribute
            (Printf.sprintf "Attribute %s has invalid type"
              (Program.Attribute.name att)
            ));
        Internal.VAO.enable_attrib (Program.Attribute.location att);
        Internal.VAO.attrib_float 
          (Program.Attribute.location att)
          (Source.size_of_attrib typ)
          (Enum.GlFloatType.Float)
          (offset   * 4)
          (t.stride * 4)
      );
    if !attribs <> [] then
      raise (Invalid_attribute
        (Printf.sprintf "Attribute %s not required by program" 
          (let (_,s,_) = List.hd !attribs in s)
        ))
  end
  else if State.bound_vao state <> (Some t.vao) then begin
    Internal.VAO.bind (Some t.vao);
    State.set_bound_vao state (Some t.vao);
    State.set_bound_vbo state (Some t.buffer);
  end

let draw state t prog = 
  if not t.valid then
    raise (Invalid_buffer "Cannot draw buffer, it may have been destroyed");
  bind state t prog;
  Internal.VAO.draw t.mode 0 (t.length * 4)

let length t = t.length

let destroy t =
  if not t.valid then
    raise (Invalid_buffer "Cannot destroy buffer : already destroyed");
  Internal.VAO.destroy t.vao;
  Internal.VBO.destroy t.buffer;
  t.valid <- false


