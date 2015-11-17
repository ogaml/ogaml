
exception Invalid_buffer of string

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
  indices : bool;
  buffer  : GL.EBO.t;
  size    : int;
  length  : int;
  mutable valid : bool
}

let dynamic src = 
  let buffer = GL.EBO.create () in
  let data = src.Source.data in
  GL.EBO.bind (Some buffer);
  GL.EBO.data (GL.Data.length data * 4) (Some data) (GLTypes.VBOKind.DynamicDraw);
  GL.EBO.bind None;
  {
    indices = true;
    buffer;
    size = GL.Data.length data;
    length = Source.length src; 
    valid = true
  }

let static src = 
  let buffer = GL.EBO.create () in
  let data = src.Source.data in
  GL.EBO.bind (Some buffer);
  GL.EBO.data (GL.Data.length data * 4) (Some data) (GLTypes.VBOKind.StaticDraw);
  GL.EBO.bind None;
  {
    indices = true;
    buffer;
    size = GL.Data.length data;
    length = Source.length src; 
    valid = true
  }

let rebuild t src =
  if not t.valid then
    raise (Invalid_buffer "Cannot rebuild buffer, it may have been destroyed");
  let data = src.Source.data in
  GL.EBO.bind (Some t.buffer);
  if t.size < GL.Data.length data then
    GL.EBO.data (GL.Data.length data * 4) None (GLTypes.VBOKind.DynamicDraw);
  GL.EBO.subdata 0 (GL.Data.length data * 4) data;
  GL.EBO.bind None;
  {
    indices = true;
    buffer = t.buffer;
    size   = max (GL.Data.length data) (t.size);
    length = Source.length src;
    valid  = true
  }

let length t = t.length

let destroy t =
  if not t.valid then
    raise (Invalid_buffer "Cannot destroy buffer : already destroyed");
  GL.EBO.destroy t.buffer;
  t.valid <- false


module LL = struct

  let bind state t = 
    if not t.valid then
      raise (Invalid_buffer "Cannot bind buffer, it may have been destroyed");
    if State.LL.bound_ebo state <> (Some t.buffer) then begin
      GL.EBO.bind (Some t.buffer);
      State.LL.set_bound_ebo state (Some t.buffer);
    end

end
