open OgamlMath

exception Invalid_attribute of string

exception Missing_attribute of string

exception Out_of_bounds of string


include VASourceInternal


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
         ?start ?length
         ?mode:(mode = DrawMode.Triangles) () =
  let state = Window.state window in
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
  Window.LL.bind_draw_parameters window parameters;
  Program.LL.use state (Some program);
  Program.LL.iter_uniforms program (fun unif -> Uniform.LL.bind state uniform unif);
  bind state vertices program;
  match indices with
  |None -> 
    if start < 0 || start + length > vertices.length then
      raise (Out_of_bounds "Invalid vertex array bounds")
    else GL.VAO.draw mode start length
  |Some ebo ->
    if start < 0 || start + length > (IndexArray.length ebo) then
      raise (Out_of_bounds "Invalid index array bounds")
    else begin
      IndexArray.LL.bind state ebo;
      GL.VAO.draw_elements mode start length 
    end



