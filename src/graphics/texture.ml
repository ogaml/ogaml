

module Texture2D = struct


  type t = {
    internal  : GL.Texture.t;
    width     : int;
    height    : int;
  }

  module LL = struct

    let bind st tex = 
      let bound_tex = 
        State.LL.bound_texture 
          st (State.LL.texture_unit st) 
          GLTypes.TextureTarget.Texture2D 
      in
      match tex with
      |None when bound_tex <> None -> begin
        State.LL.set_bound_texture
          st (State.LL.texture_unit st)
          GLTypes.TextureTarget.Texture2D
          None;
        GL.Texture.bind 
          GLTypes.TextureTarget.Texture2D
          None
      end
      |Some(t) when bound_tex <> Some t.internal -> begin
        State.LL.set_bound_texture
          st (State.LL.texture_unit st)
          GLTypes.TextureTarget.Texture2D
          (Some t.internal);
        GL.Texture.bind 
          GLTypes.TextureTarget.Texture2D
          (Some t.internal)
      end
      | _ -> ()

  end


  let create st src = 
    (* Extract the texture parameters *)
    let width, height, data = 
      match src with
      | `File s -> 
        let img = Image.create (`File s) in
        let x,y = Image.size img in
        x, y, Image.data img
      | `Image img ->
        let x,y = Image.size img in
        x, y, Image.data img
    in
    (* Create the internal texture *)
    let internal = GL.Texture.create () in
    let tex = {internal; width; height} in
    (* Bind the texture *)
    LL.bind st (Some tex);
    (* Load the corresponding image *)
    GL.Texture.image
      GLTypes.TextureTarget.Texture2D
      GLTypes.PixelFormat.RGBA
      (width, height)
      GLTypes.TextureFormat.RGBA
      data;
    (* Set the parameters *)
    GL.Texture.parameter2D 
      (`Magnify GLTypes.MagnifyFilter.Nearest);
    GL.Texture.parameter2D
      (`Minify  GLTypes.MinifyFilter.Nearest);
    (* Return the texture *)
    tex


  let size tex = 
    (tex.width, tex.height)


  
end
