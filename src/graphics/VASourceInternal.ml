(* Those two modules have been moved from VertexArray to a new (hidden) module
 * to avoid a cyclic dependency between Window and VertexArray when trying to
 * automatically batch draw calls *)

open OgamlMath

exception Invalid_source of string

exception Invalid_vertex of string


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
