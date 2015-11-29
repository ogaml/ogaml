
exception Invalid_source of string

exception Invalid_vertex of string

exception Invalid_attribute of string

exception Missing_attribute of string


module StringMap = Map.Make (struct

  type t = string

  let compare (s1 : string) (s2 : string) = compare s1 s2

end)


module Vertex = struct

  type data = 
    | Vector3f of OgamlMath.Vector3f.t
    | Vector2f of OgamlMath.Vector2f.t
    | Vector3i of OgamlMath.Vector3i.t
    | Vector2i of OgamlMath.Vector2i.t
    | Int   of int
    | Float of float
    | Color of Color.t

  type t = data StringMap.t

  let empty = StringMap.empty

  let vector3f s vec t = StringMap.add s (Vector3f vec) t

  let vector2f s vec t = StringMap.add s (Vector2f vec) t

  let vector3i s vec t = StringMap.add s (Vector3i vec) t

  let vector2i s vec t = StringMap.add s (Vector2i vec) t

  let int   s i t = StringMap.add s (Int i) t

  let float s f t = StringMap.add s (Float f) t

  let color s c t = StringMap.add s (Color c) t

end


module Source = struct

  type t = {
    mutable length : int;
    mutable types : GLTypes.GlslType.t StringMap.t;
    fdata : (float, GL.Data.float_32) GL.Data.t;
    idata : (int32, GL.Data.int_32  ) GL.Data.t;
  }

  let empty () =
    {
      length = 0;
      types  = StringMap.empty;
      fdata  = GL.Data.create_float 64;
      idata  = GL.Data.create_int   64
    }

  let get_type = function
    |Vertex.Vector3f _ -> GLTypes.GlslType.Float3
    |Vertex.Vector3i _ -> GLTypes.GlslType.Int3
    |Vertex.Vector2f _ -> GLTypes.GlslType.Float2 
    |Vertex.Vector2i _ -> GLTypes.GlslType.Int2
    |Vertex.Float    _ -> GLTypes.GlslType.Float
    |Vertex.Int      _ -> GLTypes.GlslType.Int
    |Vertex.Color    _ -> GLTypes.GlslType.Float4

  let get_size = function
    |GLTypes.GlslType.Float4  -> 4
    |GLTypes.GlslType.Float3
    |GLTypes.GlslType.Int3    -> 3
    |GLTypes.GlslType.Float2
    |GLTypes.GlslType.Int2    -> 2
    |GLTypes.GlslType.Float 
    |GLTypes.GlslType.Int      -> 1
    | _ -> assert false

  let is_integer = function
    |GLTypes.GlslType.Int3 |GLTypes.GlslType.Int2 |GLTypes.GlslType.Int -> true
    | _ -> false

  let add src v = 
    let vtype = StringMap.map get_type v in
    if StringMap.is_empty src.types then
      src.types <- vtype;
    if not (StringMap.equal 
              (fun (v1 : GLTypes.GlslType.t) 
                   (v2 : GLTypes.GlslType.t) -> v1 = v2
           ) src.types vtype) 
    then
      raise (Invalid_vertex "The type of the vertex is incompatible with the type of the source");
    StringMap.iter (fun _ v ->
      match v with
      |Vertex.Vector3f v -> GL.Data.add_3f src.fdata v
      |Vertex.Vector2f v -> GL.Data.add_2f src.fdata v
      |Vertex.Vector3i v -> GL.Data.add_3i src.idata v
      |Vertex.Vector2i v -> GL.Data.add_2i src.idata v
      |Vertex.Float    f -> GL.Data.add_float src.fdata f
      |Vertex.Int      i -> GL.Data.add_int   src.idata i
      |Vertex.Color    c -> GL.Data.add_color src.fdata c
    ) v;
    src.length <- src.length + 1

  let (<<) src v = add src v; src

  let length src = src.length

  let rec offset_list off_f off_i = function
    |[] -> []
    |(s,v)::t -> 
      if is_integer v then 
        (off_i, s, v) :: (offset_list off_f (get_size v + off_i) t)
      else
        (off_f, s, v) :: (offset_list (get_size v + off_f) off_i t)

  let attribs src = 
    let binds = StringMap.bindings src.types in
    offset_list 0 0 binds

end


type static

type dynamic

type _ t = {
  vao     : GL.VAO.t;
  mutable buffer  : GL.VBO.t;
  mutable size_f  : int;
  mutable size_i  : int;
  mutable length  : int;
  attribs         : (int * string * GLTypes.GlslType.t) list;
  stride_i        : int;
  stride_f        : int;
  mutable bound   : Program.t option;
}

let create src kind = 
  let vao    = GL.VAO.create () in
  let buffer = GL.VBO.create () in
  let dataf = src.Source.fdata in
  let datai = src.Source.idata in
  let lengthf = GL.Data.length dataf in
  let lengthi = GL.Data.length datai in
  GL.VBO.bind (Some buffer);
  if lengthi = 0 then
    GL.VBO.data (lengthf * 4) (Some dataf) kind
  else begin
    GL.VBO.data ((lengthf + lengthi) * 4) None kind;
    GL.VBO.subdata 0 (lengthf * 4) dataf;
    GL.VBO.subdata (lengthf * 4) (lengthi * 4) datai;
  end;
  GL.VBO.bind None;
  let attribs = Source.attribs src in
  {
   vao;
   buffer;
   attribs;
   size_f   = lengthf;
   size_i   = lengthi;
   length   = Source.length src; 
   stride_i = (List.fold_left 
      (fun v (s,_,t) -> if Source.is_integer t then v+(Source.get_size t) else v) 0 attribs);
   stride_f = (List.fold_left 
      (fun v (s,_,t) -> if Source.is_integer t then v else v+(Source.get_size t)) 0 attribs);
   bound = None;
  }

let dynamic src = create src GLTypes.VBOKind.DynamicDraw

let static  src = create src GLTypes.VBOKind.StaticDraw

let length t = t.length

let rebuild t src start =
  let dataf = src.Source.fdata in
  let datai = src.Source.idata in
  let lengthf = GL.Data.length dataf in
  let lengthi = GL.Data.length datai in
  let start_f = t.stride_f * start in
  let start_i = t.stride_i * start in
  if t.attribs <> Source.attribs src then
    raise (Invalid_source "Cannot rebuild vertex array : incompatible vertex source");
  let new_buffer, new_binding = 
    if t.size_f < lengthf + start_f 
    || t.size_i < lengthi + start_i 
    then begin
      let buf = GL.VBO.create () in
      GL.VBO.bind (Some buf);
      GL.VBO.data ((lengthf + lengthi + start_f + start_i) * 4) None 
                  (GLTypes.VBOKind.DynamicDraw);
      GL.VBO.bind None;
      GL.VBO.copy_subdata t.buffer buf 0 0 (start_f * 4); 
      GL.VBO.copy_subdata t.buffer buf (t.size_f * 4) ((lengthf + start_f) * 4) (start_i * 4); 
      buf, None
    end else 
      t.buffer, t.bound
  in
  GL.VBO.bind (Some new_buffer);
  GL.VBO.subdata (start_f * 4) (lengthf * 4) dataf;
  GL.VBO.subdata ((lengthf + start_f + start_i) * 4) (lengthi * 4) datai;
  GL.VBO.bind None;
  t.buffer <- new_buffer;
  t.bound  <- new_binding;
  t.size_f <- max (lengthf + start_f) t.size_f;
  t.size_i <- max (lengthi + start_i) t.size_i;
  t.length <- Source.length src + start

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
      | (off,name,typ)::t when name = s -> (off,typ,t)
      | h::t -> 
        let (off,typ,l) = find_remove s t in 
        (off,typ,h::l)
    in
    Program.LL.iter_attributes prog 
      (fun att ->
        let (offset,typ,l) = find_remove (Program.Attribute.name att) !attribs in
        attribs := l;
        if typ <> Program.Attribute.kind att then
          raise (Invalid_attribute
            (Printf.sprintf "Attribute %s has invalid type"
              (Program.Attribute.name att)
            ));
        GL.VAO.enable_attrib (Program.Attribute.location att);
        if Source.is_integer typ then begin 
          GL.VAO.attrib_int
            (Program.Attribute.location att)
            (Source.get_size typ)
            (GLTypes.GlIntType.Int)
            ((t.size_f + offset) * 4)
            (t.stride_i * 4)
        end else begin
          GL.VAO.attrib_float 
            (Program.Attribute.location att)
            (Source.get_size typ)
            (GLTypes.GlFloatType.Float)
            (offset     * 4)
            (t.stride_f * 4)
        end
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


let draw ~vertices ~window ?indices ~program ~uniform ~parameters ~mode () =
  let state = Window.state window in
  let cull_mode = DrawParameter.culling parameters in
  if State.culling_mode state <> cull_mode then begin
    State.LL.set_culling_mode state cull_mode;
    GL.Pervasives.culling cull_mode
  end;
  let poly_mode = DrawParameter.polygon parameters in
  if State.polygon_mode state <> poly_mode then begin
    State.LL.set_polygon_mode state poly_mode;
    GL.Pervasives.polygon poly_mode
  end;
  let depth_testing = DrawParameter.depth_test parameters in
  if State.depth_test state <> depth_testing then begin
    State.LL.set_depth_test state depth_testing;
    GL.Pervasives.depthtest depth_testing
  end;
  Program.LL.use state (Some program);
  Program.LL.iter_uniforms program (fun unif -> Uniform.LL.bind state uniform unif);
  bind state vertices program;
  match indices with
  |None -> GL.VAO.draw mode 0 (length vertices)
  |Some ebo ->
    IndexArray.LL.bind state ebo;
    GL.VAO.draw_elements mode (IndexArray.length ebo)


