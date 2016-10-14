open OgamlMath

module Vertex = struct

  exception Sealed_vertex of string

  exception Unsealed_vertex of string

  exception Unbound_attribute of string

  module AttributeVal = struct

    type s = 
      | Unset
      | Int of int
      | Vec2i of Vector2i.t
      | Vec3i of Vector3i.t
      | Float of float
      | Vec2f of Vector2f.t
      | Vec3f of Vector3f.t
      | Color of Color.t

    let fields = function
      | Unset -> 0
      | Int _  
      | Float _ -> 1
      | Vec2i _
      | Vec2f _ -> 2
      | Vec3i _
      | Vec3f _ -> 3
      | Color _ -> 4

    let is_int = function
      | Int _ 
      | Vec2i _
      | Vec3i _ -> true
      | _ -> false

  end

  module AttributeType = struct

    type 'a s = 
      | Int
      | Vec2i
      | Vec3i
      | Float
      | Vec2f
      | Vec3f
      | Color

    let int = Int

    let vector2i = Vec2i

    let vector3i = Vec3i

    let float = Float

    let vector2f = Vec2f

    let vector3f = Vec3f

    let color = Color

    let value_of (v : 'a) (t : 'a s) = 
      match t with
      | Int   -> AttributeVal.Int (Obj.magic v)
      | Vec2i -> AttributeVal.Vec2i (Obj.magic v)
      | Vec3i -> AttributeVal.Vec3i (Obj.magic v)
      | Float -> AttributeVal.Float (Obj.magic v)
      | Vec2f -> AttributeVal.Vec2f (Obj.magic v)
      | Vec3f -> AttributeVal.Vec3f (Obj.magic v)
      | Color -> AttributeVal.Color (Obj.magic v)

    let unbox (v : AttributeVal.s) (t : 'a s) : 'a =
      match v with
      | AttributeVal.Unset -> assert false
      | AttributeVal.Int   f -> (Obj.magic f)
      | AttributeVal.Vec2i f -> (Obj.magic f)
      | AttributeVal.Vec3i f -> (Obj.magic f)
      | AttributeVal.Float f -> (Obj.magic f)
      | AttributeVal.Vec2f f -> (Obj.magic f)
      | AttributeVal.Vec3f f -> (Obj.magic f)
      | AttributeVal.Color f -> (Obj.magic f)

    let to_glsl (t : 'a s) = 
      match t with
      | Int   -> GLTypes.GlslType.Int
      | Vec2i -> GLTypes.GlslType.Int2
      | Vec3i -> GLTypes.GlslType.Int3
      | Float -> GLTypes.GlslType.Float
      | Vec2f -> GLTypes.GlslType.Float2
      | Vec3f -> GLTypes.GlslType.Float3
      | Color -> GLTypes.GlslType.Float4

    let glsl_size = function
      | GLTypes.GlslType.Int    -> 1
      | GLTypes.GlslType.Int2   -> 2
      | GLTypes.GlslType.Int3   -> 3
      | GLTypes.GlslType.Float  -> 1
      | GLTypes.GlslType.Float2 -> 2
      | GLTypes.GlslType.Float3 -> 3
      | GLTypes.GlslType.Float4 -> 4
      | _ -> assert false

    let glsl_is_int = function
      | GLTypes.GlslType.Int 
      | GLTypes.GlslType.Int2
      | GLTypes.GlslType.Int3   -> true
      | _ -> false

    let fields t =
      glsl_size (to_glsl t)

    let is_int t =
      glsl_is_int (to_glsl t)

  end

  type 'a vertex =
    {
      mutable attribs : 'a boxed_attrib list;
      mutable sealed  : bool;
      mutable total_size : int;
    }

  and _ boxed_attrib = 
    Boxed_Attrib : ('a, 'b) attrib -> 'b boxed_attrib

  and ('a, 'b) attrib =
    {
      aname : string;
      atype : 'a AttributeType.s;
      aoffset : int;
    }

  and 'a t = 
    {
      vertex : 'a vertex;
      data   : 'a data
    }

  and 'a data =
    AttributeVal.s array

  let offset_of attrib = 
    match attrib with
    | Boxed_Attrib a -> a.aoffset

  let name_of attrib = 
    match attrib with
    | Boxed_Attrib a -> a.aname

  let type_of attrib = 
    match attrib with
    | Boxed_Attrib a -> AttributeType.to_glsl a.atype

  module Attribute = struct

    type ('a, 'b) s = ('a, 'b) attrib

    let set (vtx : 'b t) (attr : ('a, 'b) s) (vl : 'a) : unit = 
      vtx.data.(attr.aoffset) <- (AttributeType.value_of vl attr.atype)

    let get (vtx : 'b t) (attr : ('a, 'b) s) : 'a =
      match vtx.data.(attr.aoffset) with
      | AttributeVal.Unset -> raise (Unbound_attribute attr.aname)
      | v -> AttributeType.unbox v attr.atype

    let name attr = 
      attr.aname

    let atype attr = 
      attr.atype

  end

  module type VERTEX = sig

    type s

    val attribute : string -> 'a AttributeType.s -> ('a, s) Attribute.s

    val seal : unit -> unit

    val create : unit -> s t

  end

  let make () = 
    (module struct

      type s 

      let vertex = 
        {attribs = []; sealed = false; total_size = 0}

      let attribute s attr =
        if vertex.sealed then 
          Printf.ksprintf (fun s -> raise (Sealed_vertex s))
            "Cannot add attribute %s to sealed vertex structure" s;
        let attrib = 
          {
            aname = s;
            atype = attr;
            aoffset = vertex.total_size
          }
        in
        vertex.attribs <- (Boxed_Attrib attrib) :: vertex.attribs;
        vertex.total_size <- vertex.total_size + 1;
        attrib

      let seal () = 
        if vertex.sealed then 
          raise (Sealed_vertex "Cannot seal already sealed vertex structure");
        vertex.attribs <- (List.rev vertex.attribs);
        vertex.sealed <- true

      let create () = 
        if not vertex.sealed then 
          raise (Unsealed_vertex "Cannot create vertices from unsealed vertex structure");
        {vertex; data = Array.make vertex.total_size AttributeVal.Unset}

    end : VERTEX)

end


module SimpleVertex = struct

  module T = (val Vertex.make () : Vertex.VERTEX)

  let position =
    T.attribute "position" Vertex.AttributeType.vector3f

  let color =
    T.attribute "color" Vertex.AttributeType.color

  let uv =
    T.attribute "uv" Vertex.AttributeType.vector2f

  let normal = 
    T.attribute "normal" Vertex.AttributeType.vector3f

  let () = 
    T.seal ()

  let create ?position:pp ?color:cl ?uv:tc ?normal:nr () = 
    let vtx = T.create () in
    begin match pp with
    | None   -> ()
    | Some p -> Vertex.Attribute.set vtx position p
    end;
    begin match cl with
    | None   -> ()
    | Some p -> Vertex.Attribute.set vtx color p
    end;
    begin match tc with
    | None   -> ()
    | Some p -> Vertex.Attribute.set vtx uv p
    end;
    begin match nr with
    | None   -> ()
    | Some p -> Vertex.Attribute.set vtx normal p
    end;
    vtx

end


module VertexSource = struct

  exception Uninitialized_field of string

  exception Incompatible_sources

  type 'a t = {
    mutable initialized : bool;
    mutable length : int;
    mutable stridef : int;
    mutable stridei : int;
    mutable init_fields : ('a Vertex.boxed_attrib * int) list;
    init_size : int;
    mutable fdata : (float, GL.Data.float_32) GL.Data.t;
    mutable idata : (int32, GL.Data.int_32  ) GL.Data.t;
    mutable layout : 'a Vertex.vertex option;
  }

  let empty ?size:(size = 4) () =
    {
      initialized = false;
      length = 0;
      stridef = 0;
      stridei = 0;
      init_fields = [];
      init_size = size;
      fdata = GL.Data.create_float 0;
      idata = GL.Data.create_int 0;
      layout = None
    }

  let add src vtx = 
    if src.layout = None then begin
      let (init_fields,stridef,stridei,_) = 
        List.fold_right (fun att (l,sf,si,i) ->
          let elt = vtx.Vertex.data.(Vertex.offset_of att) in
          if elt <> Vertex.AttributeVal.Unset then begin
            if Vertex.AttributeVal.is_int elt then 
              ((att, Vertex.AttributeVal.fields elt+si)::l,
                sf,Vertex.AttributeVal.fields elt+si,i+1)
            else
              ((att, Vertex.AttributeVal.fields elt+sf)::l,
                Vertex.AttributeVal.fields elt+sf,si,i+1)
          end else
            (l,sf,si,i+1)
        ) 
        vtx.Vertex.vertex.Vertex.attribs 
        ([],0,0,Array.length vtx.Vertex.data - 1)
      in
      src.init_fields <- init_fields;
      src.stridei <- stridei;
      src.stridef <- stridef;
      if not src.initialized then begin
        src.fdata <- GL.Data.create_float (stridef * src.init_size);
        src.idata <- GL.Data.create_int   (stridei * src.init_size);
      end;
      src.initialized <- true;
      src.layout <- Some vtx.Vertex.vertex
    end;
    List.iter (fun (att, _) ->
      let i = Vertex.offset_of att in
      match vtx.Vertex.data.(i) with
      | Vertex.AttributeVal.Unset ->
        let open Vertex in
        begin match List.nth vtx.vertex.attribs i with
        | Boxed_Attrib f -> raise (Uninitialized_field f.Vertex.aname)
        end
      | Vertex.AttributeVal.Float v ->
        GL.Data.add_float src.fdata v
      | Vertex.AttributeVal.Vec2f v ->
        GL.Data.add_2f src.fdata v
      | Vertex.AttributeVal.Vec3f v ->
        GL.Data.add_3f src.fdata v
      | Vertex.AttributeVal.Int v ->
        GL.Data.add_int src.idata v
      | Vertex.AttributeVal.Vec2i v ->
        GL.Data.add_2i src.idata v
      | Vertex.AttributeVal.Vec3i v ->
        GL.Data.add_3i src.idata v
      | Vertex.AttributeVal.Color v ->
        GL.Data.add_color src.fdata v
    ) src.init_fields;
    src.length <- src.length + 1

  let (<<) src vtx = 
    add src vtx; src

  let length src =
    src.length

  let clear src =
    src.length <- 0;
    GL.Data.clear src.idata;
    GL.Data.clear src.fdata;
    src.layout <- None

  let append src1 src2 =
    if src2.length <> 0 then begin
      if src1.init_fields <> src2.init_fields then
        raise Incompatible_sources;
      src1.length <- src1.length + src2.length;
      GL.Data.append src1.fdata src2.fdata;
      GL.Data.append src1.idata src2.idata
    end

  let get (src : 'a t) (i : int) : 'a Vertex.t =
    let i_offset, f_offset = 
      src.stridei * i, 
      src.stridef * i
    in
    match src.layout with
    | None     -> assert false
    | Some vtx -> begin
      let vertex = 
      {
        Vertex.vertex = vtx; 
        data = Array.make vtx.Vertex.total_size Vertex.AttributeVal.Unset
      }
      in
      List.fold_left (fun (off_i, off_f) att ->
        match att with
        | Vertex.Boxed_Attrib attrib ->
          let aoffset = attrib.Vertex.aoffset in
          begin match attrib.Vertex.atype with
          | Vertex.AttributeType.Float -> 
            let v = GL.Data.get src.fdata (off_f+0) in
            vertex.Vertex.data.(aoffset) <- Vertex.AttributeVal.Float v;
            (off_i, off_f + 1)
          | Vertex.AttributeType.Vec2f -> 
            let x,y = 
              GL.Data.get src.fdata (off_f+0),
              GL.Data.get src.fdata (off_f+1) 
            in
            let v = 
              Vector2f.({x; y})
            in
            vertex.Vertex.data.(aoffset) <- Vertex.AttributeVal.Vec2f v;
            (off_i, off_f + 2)
          | Vertex.AttributeType.Vec3f -> 
            let x,y,z = 
              GL.Data.get src.fdata (off_f+0),
              GL.Data.get src.fdata (off_f+1),
              GL.Data.get src.fdata (off_f+2) 
            in
            let v = 
              Vector3f.({x; y; z})
            in
            vertex.Vertex.data.(aoffset) <- Vertex.AttributeVal.Vec3f v;
            (off_i, off_f + 3)
          | Vertex.AttributeType.Color -> 
            let r,g,b,a = 
              GL.Data.get src.fdata (off_f+0),
              GL.Data.get src.fdata (off_f+1),
              GL.Data.get src.fdata (off_f+2),
              GL.Data.get src.fdata (off_f+3) 
            in
            let v = 
              `RGB Color.RGB.({r; g; b; a})
            in
            vertex.Vertex.data.(aoffset) <- Vertex.AttributeVal.Color v;
            (off_i, off_f + 4)
          | Vertex.AttributeType.Int -> 
            let i = GL.Data.get src.idata (off_i+0) in
            let v = Int32.to_int i in
            vertex.Vertex.data.(aoffset) <- Vertex.AttributeVal.Int v;
            (off_i + 1, off_f)
          | Vertex.AttributeType.Vec2i -> 
            let x,y = 
              GL.Data.get src.idata (off_i+0),
              GL.Data.get src.idata (off_i+1) 
            in
            let v = 
              Vector2i.({x = Int32.to_int x; y = Int32.to_int y})
            in
            vertex.Vertex.data.(aoffset) <- Vertex.AttributeVal.Vec2i v;
            (off_i + 2, off_f)
          | Vertex.AttributeType.Vec3i -> 
            let x,y,z = 
              GL.Data.get src.idata (off_i+1) |> Int32.to_int,
              GL.Data.get src.idata (off_i+1) |> Int32.to_int,
              GL.Data.get src.idata (off_i+2) |> Int32.to_int 
            in
            let v = 
              Vector3i.({x; y; z})
            in
            vertex.Vertex.data.(aoffset) <- Vertex.AttributeVal.Vec3i v;
            (off_i + 3, off_f)
          end;
      ) (i_offset, f_offset) vtx.Vertex.attribs
      |> ignore;
      vertex
    end
    
  let iter (s : 'a t) (f : 'a Vertex.t -> unit) : unit =
    for i = 0 to s.length - 1 do
      f (get s i)
    done

  let map (s : 'a t) (f : 'a Vertex.t -> 'b Vertex.t) : 'b t = 
    let newsrc = empty () in
    for i = 0 to s.length - 1 do
      add newsrc (f (get s i))
    done;
    newsrc

  let map_to (s : 'a t) (f : 'a Vertex.t -> 'b Vertex.t) (d : 'b t) : unit = 
    for i = 0 to s.length - 1 do
      add d (f (get s i))
    done

end


exception Missing_attribute of string

exception Invalid_attribute of string

exception Out_of_bounds of string

type static

type dynamic

type ('a, 'b) t = {
  vao : GL.VAO.t;
  mutable buffer  : GL.VBO.t;
  mutable size_f  : int;
  mutable size_i  : int;
  mutable length  : int;
  init_fields : ('b Vertex.boxed_attrib * int) list;
  stride_i  : int;
  stride_f  : int;
  mutable bound : Program.t option;
  id : int
}

let create context src kind = 
  let vao    = GL.VAO.create () in
  let buffer = GL.VBO.create () in
  let dataf = src.VertexSource.fdata in
  let datai = src.VertexSource.idata in
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
  {
   vao;
   buffer;
   size_f   = lengthf;
   size_i   = lengthi;
   length   = VertexSource.length src; 
   init_fields = src.VertexSource.init_fields;
   stride_i = src.VertexSource.stridei;
   stride_f = src.VertexSource.stridef;
   bound = None;
   id = Context.LL.vao_id context
  }

let dynamic (type s) (module M : RenderTarget.T with type t = s) target src = 
  create (M.context target) src GLTypes.VBOKind.DynamicDraw

let static (type s) (module M : RenderTarget.T with type t = s) target src = 
  create (M.context target) src GLTypes.VBOKind.StaticDraw

let length t = t.length

let rebuild t src start =
  let dataf = src.VertexSource.fdata in
  let datai = src.VertexSource.idata in
  let lengthf = GL.Data.length dataf in
  let lengthi = GL.Data.length datai in
  let start_f = t.stride_f * start in
  let start_i = t.stride_i * start in
  if t.init_fields <> src.VertexSource.init_fields then
    raise VertexSource.Incompatible_sources;
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
  t.length <- VertexSource.length src + start

let bind context t prog = 
  if t.bound <> Some prog then begin
    t.bound <- Some prog;
    GL.VAO.bind (Some t.vao);
    Context.LL.set_bound_vao context (Some (t.vao, t.id));
    GL.VBO.bind (Some t.buffer);
    Context.LL.set_bound_vbo context (Some (t.buffer, t.id));
    let attribs = ref t.init_fields in
    let rec find_remove s = function
      | [] -> 
        raise (Missing_attribute 
          (Printf.sprintf "Attribute %s not provided in vertex source" s)
        )
      | (attrib,off)::t when Vertex.name_of attrib = s -> (attrib,off,t)
      | h::t -> 
        let (attrib,off,l) = find_remove s t in 
        (attrib,off,h::l)
    in
    List.iter (fun att ->
        let (attrib,offset,l) = find_remove (Program.Attribute.name att) !attribs in
        let typ = Vertex.type_of attrib in
        if typ <> Program.Attribute.kind att then
          raise (Invalid_attribute
            (Printf.sprintf "Attribute %s has invalid type"
              (Program.Attribute.name att)
            ));
        GL.VAO.enable_attrib (Program.Attribute.location att);
        if Vertex.AttributeType.glsl_is_int typ then begin 
          let offset = t.stride_i - offset in
          GL.VAO.attrib_int
            (Program.Attribute.location att)
            (Vertex.AttributeType.glsl_size typ)
            (GLTypes.GlIntType.Int)
            ((t.size_f + offset) * 4)
            (t.stride_i * 4)
        end else begin
          let offset = t.stride_f - offset in
          GL.VAO.attrib_float 
            (Program.Attribute.location att)
            (Vertex.AttributeType.glsl_size typ)
            (GLTypes.GlFloatType.Float)
            (offset     * 4)
            (t.stride_f * 4)
        end
      ) (Program.LL.attributes prog);
    (*if !attribs <> [] then
      Printf.eprintf "Warning : omitting attribute %s not required by program\n%!" 
        (let (_,s,_) = List.hd !attribs in s)*)
  end
  else if Context.LL.bound_vao context <> (Some t.id) then begin
    GL.VAO.bind (Some t.vao);
    Context.LL.set_bound_vao context (Some (t.vao, t.id));
    Context.LL.set_bound_vbo context (Some (t.buffer, t.id));
  end


let draw (type s) (module M : RenderTarget.T with type t = s)
         ~vertices ~target ?indices ~program
         ?uniform:(uniform = Uniform.empty) 
         ?parameters:(parameters = DrawParameter.make ()) 
         ?start ?length
         ?mode:(mode = DrawMode.Triangles) () =
  if vertices.length <> 0 then begin
    let context = M.context target in
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
    M.bind target parameters;
    Program.LL.use context (Some program);
    Uniform.LL.bind context uniform (Program.LL.uniforms program);
    bind context vertices program;
    match indices with
    |None -> 
      if start < 0 || start + length > vertices.length then
        raise (Out_of_bounds "Invalid vertex array bounds")
      else GL.VAO.draw mode start length
    |Some ebo ->
      if start < 0 || start + length > (IndexArray.length ebo) then
        raise (Out_of_bounds "Invalid index array bounds")
      else begin
        IndexArray.LL.bind context ebo;
        GL.VAO.draw_elements mode start length 
      end
  end

