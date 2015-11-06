
exception Invalid_vertex of string

exception Invalid_attribute of string

exception Missing_attribute of string


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

  let attribs src = 
    let rec build_list_opt = function
      |[] -> []
      |(_, None)   ::t -> build_list_opt t
      |(n, Some s) :: t -> (n, s) :: (build_list_opt t)
    in
    build_list_opt [Position, src.position;
                    Normal  , src.normal;
                    Texcoord, src.texcoord;
                    Color   , src.color]

  let size_of_attrib = function
    |Position -> 3
    |Color    -> 4
    |Normal   -> 3
    |Texcoord -> 2

  let type_of_attrib = function
    |Position -> Enum.GlslType.Float3
    |Color    -> Enum.GlslType.Float4
    |Normal   -> Enum.GlslType.Float3
    |Texcoord -> Enum.GlslType.Float2

  let offset_of_attrib = function
    |Position -> 0
    |Texcoord -> 3
    |Normal   -> 5
    |Color    -> 8

  let stride = 12

end

type static = unit

type dynamic = unit

type _ t = {
  buffer  : Internal.VBO.t;
  vao     : Internal.VAO.t;
  size    : int;
  length  : int;
  attribs : (Source.attrib * string) list;
  mutable bound  : Program.t option
}

let dynamic src = 
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
   bound = None
  }

let static src = 
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
   bound = None
  }

let rebuild t src = 
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
   bound  = t.bound
  }

let bind state t prog = 
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
      | (e,h)::t when h = s -> (e,t)
      | h::t -> 
        let (e,l) = find_remove s t in 
        (e,h::l)
    in
    Program.iter_attributes prog 
      (fun att ->
        let (t, l) = find_remove (Program.Attribute.name att) !attribs in
        attribs := l;
        if Source.type_of_attrib t <> Program.Attribute.kind att then
          raise (Invalid_attribute
            (Printf.sprintf "Attribute %s has invalid type"
              (Program.Attribute.name att)
            ));
        Internal.VAO.enable_attrib (Program.Attribute.location att);
        Internal.VAO.attrib_float 
          (Program.Attribute.location att)
          (Source.size_of_attrib t)
          (Enum.GlFloatType.Float)
          (Source.offset_of_attrib t * 4)
          (Source.stride * 4)
      );
    if !attribs <> [] then
      raise (Invalid_attribute
        (Printf.sprintf "Attribute %s not required by program" 
          (List.hd !attribs |> snd)
        ))
  end
  else begin
    Internal.VAO.bind (Some t.vao);
    State.set_bound_vao state (Some t.vao);
    State.set_bound_vbo state (Some t.buffer);
  end

let length t = t.length

