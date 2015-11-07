

module Texture2D = struct


  type t = {
    internal  : Internal.Texture.t;
    width     : int;
    height    : int;
  }


  let bind st tex = 
    let bound_tex = 
      State.bound_texture 
        st (State.texture_unit st) 
        Enum.TextureTarget.Texture2D 
    in
    match tex with
    |None when bound_tex <> None -> begin
      State.set_bound_texture
        st (State.texture_unit st)
        Enum.TextureTarget.Texture2D
        None;
      Internal.Texture.bind 
        Enum.TextureTarget.Texture2D
        None
    end
    |Some(t) when bound_tex <> Some t.internal -> begin
      State.set_bound_texture
        st (State.texture_unit st)
        Enum.TextureTarget.Texture2D
        (Some t.internal);
      Internal.Texture.bind 
        Enum.TextureTarget.Texture2D
        (Some t.internal)
    end
    | _ -> ()


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
    let internal = Internal.Texture.create () in
    let tex = {internal; width; height} in
    (* Bind the texture *)
    bind st (Some tex);
    (* Load the corresponding image *)
    Internal.Texture.image
      Enum.TextureTarget.Texture2D
      Enum.PixelFormat.RGBA
      (width, height)
      Enum.TextureFormat.RGBA
      data;
    (* Set the parameters *)
    Internal.Texture.parameter2D 
      (`Magnify Enum.MagnifyFilter.Nearest);
    Internal.Texture.parameter2D
      (`Minify  Enum.MinifyFilter.Nearest);
    (* Return the texture *)
    tex


  let size tex = 
    (tex.width, tex.height)


end
