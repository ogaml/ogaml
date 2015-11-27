
module Source = struct

  type t = {
    mutable length   : int;
    data     : (int32, GL.Data.int_32) GL.Data.t;
  }

  let empty size = 
    {
      length = 0;
      data = GL.Data.create_int size
    }

  let add src v = 
    GL.Data.add_int src.data v;
    src.length <- src.length + 1

  let (<<) src v = add src v; src

  let length src = src.length

  let data src = src.data

end


type static 

type dynamic

type _ t = {
  mutable buffer  : GL.EBO.t;
  mutable size    : int;
  mutable length  : int;
}

let dynamic src = 
  let buffer = GL.EBO.create () in
  let data = src.Source.data in
  GL.EBO.bind (Some buffer);
  GL.EBO.data (GL.Data.length data * 4) (Some data) (GLTypes.VBOKind.DynamicDraw);
  GL.EBO.bind None;
  {
    buffer;
    size = GL.Data.length data;
    length = Source.length src; 
  }

let static src = 
  let buffer = GL.EBO.create () in
  let data = src.Source.data in
  GL.EBO.bind (Some buffer);
  GL.EBO.data (GL.Data.length data * 4) (Some data) (GLTypes.VBOKind.StaticDraw);
  GL.EBO.bind None;
  {
    buffer;
    size = GL.Data.length data;
    length = Source.length src; 
  }

let rebuild t src start =
  let data = src.Source.data in
  let new_buffer = 
    if t.size < GL.Data.length data + start then begin
      let buf = GL.EBO.create () in
      GL.EBO.bind (Some buf);
      GL.EBO.data ((GL.Data.length data + start) * 4) None (GLTypes.VBOKind.DynamicDraw);
      GL.EBO.bind None;
      GL.EBO.copy_subdata t.buffer buf 0 0 (start * 4); 
      buf
    end else 
      t.buffer
  in
  GL.EBO.bind (Some new_buffer);
  GL.EBO.subdata (start * 4) (GL.Data.length data * 4) data;
  GL.EBO.bind None;
  t.buffer <- new_buffer;
  t.length <- Source.length src + start;
  t.size   <- max (GL.Data.length data + start) t.size



let length t = t.length


module LL = struct

  let bind state t = 
    if State.LL.bound_ebo state <> (Some t.buffer) then begin
      GL.EBO.bind (Some t.buffer);
      State.LL.set_bound_ebo state (Some t.buffer);
    end

end
