

module Texture2D = struct

  type t = {
    internal  : GL.Texture.t;
    id        : int;
    width     : int;
    height    : int;
  }

  module LL = struct

    let set_unit st uid = 
      let bound_unit = State.LL.texture_unit st in
      if bound_unit <> uid then begin
        State.LL.set_texture_unit st uid;
        GL.Texture.activate uid
      end

    let bind st uid tex = 
      set_unit st uid;
      let bound_tex = 
        State.LL.bound_texture st uid
      in
      let bound_target = 
        State.LL.bound_target st uid
      in
      match tex with
      |None when bound_tex <> None 
              && bound_target = Some GLTypes.TextureTarget.Texture2D -> begin
        State.LL.set_bound_texture
          st uid
          None;
        GL.Texture.bind 
          GLTypes.TextureTarget.Texture2D
          None
      end
      |Some(t) when bound_tex <> Some t.id -> begin
        State.LL.set_bound_texture st uid
          (Some (t.id, GLTypes.TextureTarget.Texture2D));
        GL.Texture.bind 
          GLTypes.TextureTarget.Texture2D
          (Some t.internal)
      end
      | _ -> ()

  end


  let create state src = 
    (* Extract the texture parameters *)
    let width, height, data = 
      match src with
      | `File s -> 
        let img = Image.create (`File s) in
        let v = Image.size img in
        v.OgamlMath.Vector2i.x, v.OgamlMath.Vector2i.y, Image.data img
      | `Image img ->
        let v = Image.size img in
        v.OgamlMath.Vector2i.x, v.OgamlMath.Vector2i.y, Image.data img
    in
    (* Create the internal texture *)
    let internal = GL.Texture.create () in
    let tex = {internal; id = State.LL.texture_id state; width; height} in
    (* Bind the texture *)
    LL.bind state 0 (Some tex);
    (* Load the corresponding image *)
    GL.Texture.image
      GLTypes.TextureTarget.Texture2D
      GLTypes.PixelFormat.RGBA
      (width, height)
      GLTypes.TextureFormat.RGBA
      data;
    (* Set the parameters *)
    GL.Texture.parameter2D 
      (`Magnify GLTypes.MagnifyFilter.Linear);
    GL.Texture.parameter2D
      (`Minify  GLTypes.MinifyFilter.Linear);
    (* Unbind and return the texture *)
    tex


  let size tex = 
    OgamlMath.Vector2i.({x = tex.width; y = tex.height})


  
end
