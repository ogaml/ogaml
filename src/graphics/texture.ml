open OgamlMath
open Utils

module type T = sig

  type t

  val bind : t -> int -> unit

end

module MinifyFilter = GLTypes.MinifyFilter

module MagnifyFilter = GLTypes.MagnifyFilter

module WrapFunction = GLTypes.WrapFunction

module DepthFormat = struct

  type t = 
    | Int16
    | Int24
    | Int32

  let to_texture_format = function
    | Int16 -> GLTypes.TextureFormat.Depth16
    | Int24 -> GLTypes.TextureFormat.Depth24
    | Int32 -> GLTypes.TextureFormat.Depth32

  let byte_size = function
    | Int16 -> 2
    | Int24 -> 3
    | Int32 -> 4

end


(*************************************************************)
(*                                                           *)
(*            Common interface to OpenGL Textures            *)
(*                                                           *)
(*                                                           *)
(*************************************************************)

module Common = struct

  type t = {
      context : Context.t;
      internal: GL.Texture.t;
      target  : GLTypes.TextureTarget.t;
      id      : int;
      mipmaps : int;
      mutable minify  : MinifyFilter.t option;
      mutable magnify : MagnifyFilter.t option;
      mutable wrap    : WrapFunction.t option;
  }

  let max_mipmaps size = 
    let rec log2 i = 
      match i with
      | 0 -> 0
      | 1 -> 0
      | n -> 1 + (log2 (n lsr 1))
    in
    max (log2 size.Vector2i.x) (log2 size.Vector2i.y) + 1

  let max_mipmaps_3D size = 
    let rec log2 i = 
      match i with
      | 0 -> 0
      | 1 -> 0
      | n -> 1 + (log2 (n lsr 1))
    in
    max (max (log2 size.Vector3i.x) (log2 size.Vector3i.y)) (log2 size.Vector3i.z) + 1

  let set_unit st uid = 
    let bound_unit = Context.LL.texture_unit st in
    if bound_unit <> uid then begin
      Context.LL.set_texture_unit st uid;
      GL.Texture.activate uid
    end

  let bind tex uid = 
    set_unit tex.context uid;
    let bound_tex = Context.LL.bound_texture tex.context uid in
    if bound_tex <> Some tex.id then begin
      Context.LL.set_bound_texture tex.context uid (Some (tex.internal, tex.id, tex.target));
      GL.Texture.bind tex.target (Some tex.internal)
    end

  let unbind context target uid = 
    set_unit context uid;
    let bound_tex = 
      Context.LL.bound_texture context uid
    in
    let bound_target = 
      Context.LL.bound_target context uid
    in
    if bound_tex <> None && bound_target = Some target then begin
      Context.LL.set_bound_texture
        context uid
        None;
      GL.Texture.bind target None
    end

  let create context mipmaps target =
    (* Create the texture *)
    let internal = GL.Texture.create () in
    let idpool = Context.LL.texture_pool context in
    let id = Context.ID_Pool.get_next idpool in
    let finalize _ = 
      Context.ID_Pool.free idpool id;
      for i = 0 to (Context.capabilities context).Context.max_texture_image_units - 1 do
        if Context.LL.bound_texture context i = Some id then
          Context.LL.set_bound_texture context i None
      done
    in
    let tex = {internal; 
               context;
               target;
               mipmaps;
               id;
               wrap = Some GLTypes.WrapFunction.ClampEdge;
               magnify = Some GLTypes.MagnifyFilter.Linear;
               minify = Some GLTypes.MinifyFilter.LinearMipmapLinear} in
    Gc.finalise finalize tex;
    (* Bind it *)
    bind tex 0;
    (* Set reasonable parameters *)
    GL.Texture.parameter target (`Minify GLTypes.MinifyFilter.LinearMipmapLinear);
    GL.Texture.parameter target (`Magnify GLTypes.MagnifyFilter.Linear);
    GL.Texture.parameter target (`Wrap GLTypes.WrapFunction.ClampEdge);
    tex

  let minify tex filter = 
    bind tex 0;
    match tex.minify with
    | Some f when f = filter -> ()
    | _ ->
      GL.Texture.parameter tex.target (`Minify filter);
      tex.minify <- Some filter

  let magnify tex filter = 
    bind tex 0;
    match tex.magnify with
    | Some f when f = filter -> ()
    | _ ->
      GL.Texture.parameter tex.target (`Magnify filter);
      tex.magnify <- Some filter

  let wrap tex func = 
    bind tex 0;
    match tex.wrap with
    | Some f when f = func -> ()
    | _ ->
      GL.Texture.parameter tex.target (`Wrap func);
      tex.wrap <- Some func

end


(*************************************************************)
(*                                                           *)
(*                       2D Textures                         *)
(*                                                           *)
(*                                                           *)
(*************************************************************)

module Texture2DMipmap = struct

  type t = {
    common  : Common.t;
    size    : Vector2i.t;
    level   : int
  }

  let bind tex uid = 
    Common.bind tex.common uid

  let size tex = 
    tex.size

  let write tex ?rect img = 
    bind tex 0;
    let rect = 
      match rect with
      | None   -> IntRect.create Vector2i.zero (size tex)
      | Some r -> r
    in
    GL.Texture.subimage2D 
      GLTypes.TextureTarget.Texture2D
      tex.level (rect.IntRect.x, rect.IntRect.y)
      (rect.IntRect.width, rect.IntRect.height)
      GLTypes.PixelFormat.RGBA
      (Image.data img)

  let level tex = 
    tex.level

  let to_color_attachment tex = 
    Attachment.ColorAttachment.Texture2D (tex.common.Common.internal, tex.level)

end


module Texture2D = struct

  type t = {
    common  : Common.t;
    size    : Vector2i.t;
  }

  let create (type s) (module M : RenderTarget.T with type t = s) target 
    ?mipmaps:(mipmaps=`AllGenerated) src = 
    let context = M.context target in
    (* Extract the texture parameters *)
    begin match src with
    | `File s -> 
      (Image.load s) >>>= fun img -> 
      (Image.size img, Some img)
    | `Image img ->
      let v = Image.size img in
      Ok (v, (Some img))
    | `Empty size ->
      Ok (size, None)
    end >>= fun (size, img) ->
    let levels = 
      let max_levels = Common.max_mipmaps size in
      match mipmaps with
      | `AllGenerated | `AllEmpty    -> max_levels
      | `Empty i      | `Generated i -> max 1 (min max_levels i)
      | `None -> 1
     in
    (* Check that the size is allowed *)
    let capabilities = Context.capabilities context in
    let max_size = capabilities.Context.max_texture_size in
    if size.Vector2i.x > max_size || size.Vector2i.y > max_size then
      Error `Texture_too_large
    else
      Ok () >>>= fun () ->
    (* Create the internal texture *)
    let common = Common.create context levels GLTypes.TextureTarget.Texture2D in
    let tex = {common; size} in
    (* Bind the texture *)
    Common.bind tex.common 0;
    (* Allocate the texture *)
    GL.Texture.storage2D
      GLTypes.TextureTarget.Texture2D 
      levels 
      GLTypes.TextureFormat.RGBA8
      (size.Vector2i.x, size.Vector2i.y);
    (* Load the corresponding image in each mipmap if requested *)
    let load_level lvl = 
      match img with
      | Some img -> 
        let data = (Image.data (Image.mipmap img lvl)) in
        GL.Texture.subimage2D
          GLTypes.TextureTarget.Texture2D 
          lvl (0,0)
          (size.Vector2i.x lsr lvl, size.Vector2i.y lsr lvl)
          GLTypes.PixelFormat.RGBA
          data
      | None -> ()
    in
    begin match mipmaps with
    | `AllGenerated | `Generated _ ->
      for lvl = 0 to levels -1 do
        load_level lvl
      done
    | `None | `AllEmpty | `Empty _ -> 
      load_level 0
    end;
    (* Return the texture *)
    tex

  let size tex = tex.size

  let minify tex filter = Common.minify tex.common filter

  let magnify tex filter = Common.magnify tex.common filter

  let wrap tex func = Common.wrap tex.common func

  let mipmap_levels tex = tex.common.Common.mipmaps

  let mipmap tex i = 
    if i >= tex.common.Common.mipmaps || i < 0 then
      Error `Invalid_mipmap
    else
      Ok {Texture2DMipmap.common = tex.common; 
       size = Vector2i.({x = tex.size.x lsr i; y = tex.size.y lsr i});
       level = i}

  let bind tex uid = Common.bind tex.common uid

  let to_color_attachment tex = 
    Attachment.ColorAttachment.Texture2D (tex.common.Common.internal, 0)

end


(*************************************************************)
(*                                                           *)
(*                    2D Depth Textures                      *)
(*                                                           *)
(*                                                           *)
(*************************************************************)

module DepthTexture2DMipmap = struct

  type t = {
    common  : Common.t;
    size    : Vector2i.t;
    level   : int
  }

  let bind tex uid = 
    Common.bind tex.common uid

  let size tex = 
    tex.size

  let write tex ?rect img = 
    bind tex 0;
    let rect = 
      match rect with
      | None   -> IntRect.create Vector2i.zero (size tex)
      | Some r -> r
    in
    GL.Texture.subimage2D 
      GLTypes.TextureTarget.Texture2D
      tex.level (rect.IntRect.x, rect.IntRect.y)
      (rect.IntRect.width, rect.IntRect.height)
      GLTypes.PixelFormat.Depth
      (Image.data img)

  let level tex = 
    tex.level

  let to_depth_attachment tex = 
    Attachment.DepthAttachment.Texture2D (tex.common.Common.internal, tex.level)

end


module DepthTexture2D = struct

  type t = {
    common  : Common.t;
    size    : Vector2i.t;
    format  : GLTypes.TextureFormat.t
  }

  let create (type s) (module M : RenderTarget.T with type t = s) target 
    ?mipmaps:(mipmaps=`AllGenerated) format src = 
    let context = M.context target in
    (* Extract the texture parameters *)
    let bytesize = DepthFormat.byte_size format in
    begin match src with
    | `Data (size, data) ->
      if size.Vector2i.x * size.Vector2i.y * bytesize > Bytes.length data then
        Error `Insufficient_data
      else
        Ok (size, (Some data))
    | `Empty size ->
      Ok (size, None)
    end >>= fun (size, data) ->
    let levels = 
      let max_levels = Common.max_mipmaps size in
      match mipmaps with
      | `AllGenerated | `AllEmpty    -> max_levels
      | `Empty i      | `Generated i -> max 1 (min max_levels i)
      | `None -> 1
    in
    (* Check that the size is allowed *)
    let capabilities = Context.capabilities context in
    let max_size = capabilities.Context.max_texture_size in
    if size.Vector2i.x > max_size || size.Vector2i.y > max_size then
      Error `Texture_too_large
    else
      Ok () >>>= fun () ->
    (* Create the internal texture *)
    let common = Common.create context levels GLTypes.TextureTarget.Texture2D in
    let format = DepthFormat.to_texture_format format in
    let tex = {common; size; format} in
    (* Bind the texture *)
    Common.bind tex.common 0;
    (* Allocate the texture *)
    GL.Texture.storage2D
      GLTypes.TextureTarget.Texture2D
      levels 
      format
      (size.Vector2i.x, size.Vector2i.y);
    (* Load the corresponding image in each mipmap if requested *)
    let load_level lvl = 
      match data with
      | Some data -> 
        let mipmap_x, mipmap_y = 
          (size.Vector2i.x lsr lvl, size.Vector2i.y lsr lvl) 
        in
        let mipmap_data = Bytes.create (mipmap_x * mipmap_y * bytesize) in 
        for i = 0 to mipmap_x - 1 do
          for j = 0 to mipmap_y - 1 do
            let offset = bytesize * mipmap_x * (j lsl lvl) + bytesize * (i lsl lvl) in
            let mipmap_offset = bytesize * mipmap_x * j + bytesize * i in
            for k = 0 to bytesize - 1 do
              Bytes.set mipmap_data (mipmap_offset + k) (Bytes.get data (offset + k))
            done;
          done;
        done;
        GL.Texture.subimage2D
          GLTypes.TextureTarget.Texture2D 
          lvl (0,0)
          (size.Vector2i.x lsr lvl, size.Vector2i.y lsr lvl)
          GLTypes.PixelFormat.Depth
          data
      | None -> ()
    in
    begin match mipmaps with
    | `AllGenerated | `Generated _ ->
      for lvl = 0 to levels -1 do
        load_level lvl
      done
    | `None | `AllEmpty | `Empty _ -> 
      load_level 0
    end;
    (* Return the texture *)
    tex

  let size tex = tex.size

  let minify tex filter = Common.minify tex.common filter

  let magnify tex filter = Common.magnify tex.common filter

  let wrap tex func = Common.wrap tex.common func

  let mipmap_levels tex = tex.common.Common.mipmaps

  let mipmap tex i = 
    if i >= tex.common.Common.mipmaps || i < 0 then
      Error `Invalid_mipmap 
    else
      Ok {DepthTexture2DMipmap.common = tex.common; 
       size = Vector2i.({x = tex.size.x lsr i; y = tex.size.y lsr i});
       level = i}

  let bind tex uid = Common.bind tex.common uid

  let to_depth_attachment tex = 
    Attachment.DepthAttachment.Texture2D (tex.common.Common.internal, 0)

end


(*************************************************************)
(*                                                           *)
(*                   2D Array Textures                       *)
(*                                                           *)
(*                                                           *)
(*************************************************************)

module Texture2DArrayLayerMipmap = struct

  type t = {
    common : Common.t;
    size   : Vector2i.t;
    level  : int;
    layer  : int
  }

  let size t = t.size

  let layer t = t.layer

  let level t = t.level

  let bind t uid = Common.bind t.common uid

  let write t rect img = 
    bind t 0;
    GL.Texture.subimage3D GLTypes.TextureTarget.Texture2DArray
                          t.level
                          (rect.IntRect.x, rect.IntRect.y, t.layer)
                          (rect.IntRect.width, rect.IntRect.height, 1)
                          GLTypes.PixelFormat.RGBA
                          (Image.data img)

  let to_color_attachment t = 
    Attachment.ColorAttachment.Texture2DArray (t.common.Common.internal, t.layer, t.level)

end


module Texture2DArrayMipmap = struct

  type t = {
    common : Common.t;
    size   : Vector2i.t;
    depth  : int;
    level  : int
  }

  let size t = Vector3i.({x = t.size.Vector2i.x; y = t.size.Vector2i.y; z = t.depth})

  let layers t = t.depth

  let level t = t.level

  let layer t i = 
    if i < 0 || i >= t.depth then 
      Error `Invalid_layer
    else
     Ok {Texture2DArrayLayerMipmap.common = t.common;
         size  = t.size;
         level = t.level;
         layer = i}

  let bind t uid = Common.bind t.common uid

end


module Texture2DArrayLayer = struct

  type t = {
    common : Common.t;
    size   : Vector2i.t;
    layer  : int
  }

  let size t = t.size

  let layer t = t.layer

  let mipmap_levels t = t.common.Common.mipmaps

  let mipmap t i = 
    if i < 0 || i >= t.common.Common.mipmaps then 
      Error `Invalid_mipmap 
    else
      Ok {Texture2DArrayLayerMipmap.common = t.common;
          size  = Vector2i.({x = t.size.x lsr i; y = t.size.y lsr i});
          level = i;
          layer = t.layer}

  let bind t uid = Common.bind t.common uid

  let to_color_attachment t = 
    Attachment.ColorAttachment.Texture2DArray (t.common.Common.internal, t.layer, 0)

end


module Texture2DArray = struct

  type t = {
    common : Common.t;
    size   : Vector2i.t;
    depth  : int
  }

  let create (type a) (module M : RenderTarget.T with type t = a) target
    ?mipmaps:(mipmaps = `AllGenerated) src =
    let context = M.context target in
    (* Extract the texture parameters *)
    let extract_params = function
      | `File s -> 
        (Image.load s) >>>= fun img -> 
        (Image.size img, Some img)
      | `Image img ->
        let v = Image.size img in
        Ok (v, (Some img))
      | `Empty size ->
        Ok (size, None)
    in
    if src = [] then 
      Error `No_input_files
    else
      Ok () >>= fun () ->
    let lparams = 
      List.map extract_params src
    in
    List.hd lparams >>= fun (size, _) ->
    fold_right_result (fun params (n, l_imgs) -> 
      params >>= fun (img_size, img) ->
      if img_size <> size then 
        Error `Non_equal_input_sizes
      else
        Ok (n+1, img :: l_imgs)
    ) lparams (0, []) >>= fun (depth, imgs) ->
    let levels = 
      let max_levels = Common.max_mipmaps size in
      match mipmaps with
      | `AllGenerated | `AllEmpty    -> max_levels
      | `Empty i      | `Generated i -> max 1 (min max_levels i)
      | `None -> 1
     in
    (* Check that the size is allowed *)
    let capabilities = Context.capabilities context in
    let max_size = capabilities.Context.max_texture_size in
    let max_depth = capabilities.Context.max_array_texture_layers in
    if size.Vector2i.x > max_size || size.Vector2i.y > max_size then
      Error `Texture_too_large
    else if depth > max_depth then
      Error `Texture_too_deep
    else 
      Ok () >>>= fun () ->
    (* Create the internal texture *)
    let common = Common.create context levels GLTypes.TextureTarget.Texture2DArray in
    let tex = {common; size; depth} in
    (* Bind the texture *)
    Common.bind tex.common 0;
    (* Allocate the texture *)
    GL.Texture.storage3D
      GLTypes.TextureTarget.Texture2DArray
      levels 
      GLTypes.TextureFormat.RGBA8
      (size.Vector2i.x, size.Vector2i.y, depth);
    (* Load the corresponding image in each mipmap if requested *)
    let load_level lvl = 
      List.iteri (fun layer img -> 
        match img with
        | Some img -> 
          let data = Image.data (Image.mipmap img lvl) in
          GL.Texture.subimage3D
            GLTypes.TextureTarget.Texture2DArray
            lvl (0,0,layer)
            (size.Vector2i.x lsr lvl, size.Vector2i.y lsr lvl, 1)
            GLTypes.PixelFormat.RGBA
            data
        | None     -> ()
      ) imgs;
    in
    begin match mipmaps with
    | `AllGenerated | `Generated _ ->
      for lvl = 0 to levels -1 do
        load_level lvl
      done
    | `None | `AllEmpty | `Empty _ -> 
      load_level 0
    end;
    (* Return the texture *)
    tex

  let size tex = Vector3i.({x = tex.size.Vector2i.x; y = tex.size.Vector2i.y; z = tex.depth})

  let minify tex filter = Common.minify tex.common filter

  let magnify tex filter = Common.magnify tex.common filter

  let wrap tex func = Common.wrap tex.common func

  let layers t = t.depth

  let mipmap_levels t = t.common.Common.mipmaps

  let layer t i = 
    if i < 0 || i >= t.depth then 
      Error `Invalid_layer
    else
      Ok {Texture2DArrayLayer.common = t.common;
          size  = t.size;
          layer = i}

  let mipmap t i = 
    if i < 0 || i >= t.common.Common.mipmaps then 
      Error `Invalid_mipmap
    else
      Ok {Texture2DArrayMipmap.common = t.common;
           size  = Vector2i.({x = t.size.x lsr i; y = t.size.y lsr i});
           depth = t.depth;
           level = i}

  let bind t uid = Common.bind t.common uid

end


(*************************************************************)
(*                                                           *)
(*                    Cubemap Textures                       *)
(*                                                           *)
(*                                                           *)
(*************************************************************)

module CubemapMipmapFace = struct

  type t = {
    common : Common.t;
    size   : Vector2i.t;
    level  : int;
    face   : [`PositiveX | `PositiveY | `PositiveZ | `NegativeX | `NegativeY | `NegativeZ] 
  }

  let size t = t.size

  let bind t uid = Common.bind t.common uid

  let write t rect img =
    let target = 
      match t.face with
      | `PositiveX -> GLTypes.TextureTarget.CubemapPositiveX
      | `NegativeX -> GLTypes.TextureTarget.CubemapNegativeX
      | `PositiveY -> GLTypes.TextureTarget.CubemapPositiveY
      | `NegativeY -> GLTypes.TextureTarget.CubemapNegativeY
      | `PositiveZ -> GLTypes.TextureTarget.CubemapPositiveZ
      | `NegativeZ -> GLTypes.TextureTarget.CubemapNegativeZ
    in
    bind t 0;
    GL.Texture.subimage2D target
                          t.level
                          (rect.IntRect.x, rect.IntRect.y)
                          (rect.IntRect.width, rect.IntRect.height)
                          GLTypes.PixelFormat.RGBA
                          (Image.data img)

  let level t = t.level

  let face t = t.face

  let to_color_attachment t = 
    let f = 
      match t.face with
      | `PositiveX -> 0
      | `NegativeX -> 1
      | `PositiveY -> 2
      | `NegativeY -> 3
      | `PositiveZ -> 4
      | `NegativeZ -> 5
    in
    Attachment.ColorAttachment.TextureCubemap (t.common.Common.internal, f, t.level)

end


module CubemapFace = struct

  type t = {
    common : Common.t;
    size   : Vector2i.t;
    face   : [`PositiveX | `PositiveY | `PositiveZ | `NegativeX | `NegativeY | `NegativeZ] 
  }

  let size t = t.size

  let mipmap_levels t = t.common.Common.mipmaps

  let mipmap t i = 
    if i < 0 || i >= t.common.Common.mipmaps then 
      Error `Invalid_mipmap
    else 
      Ok {CubemapMipmapFace.common = t.common;
          size  = Vector2i.map t.size (fun v -> v lsr i);
          face  = t.face;
          level = i}

  let face t = t.face

  let bind t uid = Common.bind t.common uid

  let to_color_attachment t = 
    let f = 
      match t.face with
      | `PositiveX -> 0
      | `NegativeX -> 1
      | `PositiveY -> 2
      | `NegativeY -> 3
      | `PositiveZ -> 4
      | `NegativeZ -> 5
    in
    Attachment.ColorAttachment.TextureCubemap (t.common.Common.internal, f, 0)

end


module CubemapMipmap = struct

  type t = {
    common : Common.t;
    size   : Vector2i.t;
    level  : int
  }

  let size t = t.size

  let level t = t.level

  let face t f = 
    {CubemapMipmapFace.common = t.common;
                         size = t.size;
                        level = t.level;
                         face = f}

  let bind t uid = Common.bind t.common uid

end


module Cubemap = struct

  type t = {
    common : Common.t;
    size   : Vector2i.t;
  }

  let create (type a) (module M : RenderTarget.T with type t = a) target
    ?mipmaps:(mipmaps = `AllGenerated) 
    ~positive_x ~positive_y ~positive_z 
    ~negative_x ~negative_y ~negative_z () =
    let context = M.context target in
    (* Extract the texture parameters *)
    let extract_params = function
      | `File s -> 
        (Image.load s) >>>= fun img -> 
        (Image.size img, Some img)
      | `Image img ->
        let v = Image.size img in
        Ok (v, (Some img))
      | `Empty size ->
        Ok (size, None)
    in
    extract_params positive_x >>= fun (spx, ipx) ->
    extract_params positive_y >>= fun (spy, ipy) ->
    extract_params positive_z >>= fun (spz, ipz) ->
    extract_params negative_x >>= fun (snx, inx) ->
    extract_params negative_y >>= fun (sny, iny) ->
    extract_params negative_z >>= fun (snz, inz) ->
    if not (List.for_all (fun s -> s = spx) [spy; spz; snx; sny; snz]) then
      Error `Non_equal_input_sizes
    else
      Ok () >>= fun () ->
    let levels = 
      let max_levels = Common.max_mipmaps spx in
      match mipmaps with
      | `AllGenerated | `AllEmpty    -> max_levels
      | `Empty i      | `Generated i -> max 1 (min max_levels i)
      | `None -> 1
     in
    (* Check that the size is allowed *)
    let capabilities = Context.capabilities context in
    let max_size = capabilities.Context.max_cube_map_texture_size in
    if spx.Vector2i.x > max_size || spx.Vector2i.y > max_size then
      Error `Texture_too_large
    else
      Ok () >>>= fun () ->
    (* Create the internal texture *)
    let common = Common.create context levels GLTypes.TextureTarget.CubemapTexture in
    let tex = {common; size = spx} in
    (* Bind the texture *)
    Common.bind tex.common 0;
    (* Allocate the texture *)
    GL.Texture.storage2D
      GLTypes.TextureTarget.CubemapTexture
      levels 
      GLTypes.TextureFormat.RGBA8
      (spx.Vector2i.x, spx.Vector2i.y);
    (* Load the corresponding image in each mipmap if requested *)
    let load_img target lvl img = 
      match img with
      | Some img -> 
        GL.Texture.subimage2D
          target lvl (0,0)
          (spx.Vector2i.x lsr lvl, spx.Vector2i.y lsr lvl)
          GLTypes.PixelFormat.RGBA
          (Image.data (Image.mipmap img lvl))
      | None -> ()
    in
    let load_level lvl = 
      load_img GLTypes.TextureTarget.CubemapPositiveX lvl ipx;
      load_img GLTypes.TextureTarget.CubemapPositiveY lvl ipy;
      load_img GLTypes.TextureTarget.CubemapPositiveZ lvl ipz;
      load_img GLTypes.TextureTarget.CubemapNegativeX lvl inx;
      load_img GLTypes.TextureTarget.CubemapNegativeY lvl iny;
      load_img GLTypes.TextureTarget.CubemapNegativeZ lvl inz;
    in
    begin match mipmaps with
    | `AllGenerated | `Generated _ ->
      for lvl = 0 to levels -1 do
        load_level lvl
      done
    | `None | `AllEmpty | `Empty _ -> 
      load_level 0
    end;
    (* Return the texture *)
    tex

  let size tex = tex.size

  let minify tex filter = Common.minify tex.common filter

  let magnify tex filter = Common.magnify tex.common filter

  let wrap tex func = Common.wrap tex.common func

  let mipmap_levels t = t.common.Common.mipmaps

  let mipmap t i = 
    if i < 0 || i >= t.common.Common.mipmaps then 
      Error `Invalid_mipmap
    else
      Ok {CubemapMipmap.common = t.common;
          size  = Vector2i.map t.size (fun v -> v lsr i);
          level = i}

  let face t f = 
    {CubemapFace.common = t.common;
                   size = t.size;
                   face = f}

  let bind t uid = Common.bind t.common uid

end


(*************************************************************)
(*                                                           *)
(*                    3D Textures                            *)
(*                                                           *)
(*                                                           *)
(*************************************************************)

module Texture3DMipmap = struct

  type t = {
    common : Common.t;
    size   : Vector3i.t;
    level  : int;
    layer  : int
  }

  let size t = t.size

  let level t = t.level

  let bind t uid = Common.bind t.common uid

  let layer t i = 
    if i < 0 || i >= t.size.Vector3i.z then
      Error `Invalid_layer
    else 
      Ok {t with layer = i}

  let current_layer t =
    t.layer

  let write t rect img = 
    bind t 0;
    GL.Texture.subimage3D GLTypes.TextureTarget.Texture3D
                          t.level
                          (rect.IntRect.x, rect.IntRect.y, t.layer)
                          (rect.IntRect.width, rect.IntRect.height, 1)
                          GLTypes.PixelFormat.RGBA
                          (Image.data img)

  let to_color_attachment t = 
    Attachment.ColorAttachment.Texture3D (t.common.Common.internal, t.layer, t.level)

end


module Texture3D = struct

  type t = {
    common : Common.t;
    size   : Vector3i.t;
  }

  let create (type a) (module M : RenderTarget.T with type t = a) target
    ?mipmaps:(mipmaps = `AllGenerated) src =
    let context = M.context target in
    (* Extract the texture parameters *)
    let extract_params = function
      | `File s -> 
        (Image.load s) >>>= fun img -> 
        (Image.size img, Some img)
      | `Image img ->
        let v = Image.size img in
        Ok (v, (Some img))
      | `Empty size ->
        Ok (size, None)
    in
    if src = [] then 
      Error `No_input_files
    else
      Ok () >>= fun () ->
    let lparams =
      List.map extract_params src
    in
    List.hd lparams >>= fun (size2D, _) ->
    fold_right_result (fun params (n, l_imgs) -> 
      params >>= fun (img_size, img) ->
      if img_size <> size2D then 
        Error `Non_equal_input_sizes
      else
        Ok (n+1, img :: l_imgs)
    ) lparams (0, []) >>= fun (depth, imgs) ->
    let size = {Vector3i.x = size2D.Vector2i.x; y = size2D.Vector2i.y; z = depth} in
    let levels = 
      let max_levels = Common.max_mipmaps_3D size in
      match mipmaps with
      | `AllGenerated | `AllEmpty    -> max_levels
      | `Empty i      | `Generated i -> max 1 (min max_levels i)
      | `None -> 1
     in
    (* Check that the size is allowed *)
    let capabilities = Context.capabilities context in
    let max_size = capabilities.Context.max_3D_texture_size in
    if size.Vector3i.x > max_size || size.Vector3i.y > max_size || size.Vector3i.z > max_size then
      Error `Texture_too_large
    else
      Ok () >>>= fun () ->
    (* Create the internal texture *)
    let common = Common.create context levels GLTypes.TextureTarget.Texture3D in
    let tex = {common; size} in
    (* Bind the texture *)
    Common.bind tex.common 0;
    (* Allocate the texture *)
    GL.Texture.storage3D
      GLTypes.TextureTarget.Texture3D
      levels 
      GLTypes.TextureFormat.RGBA8
      (size.Vector3i.x, size.Vector3i.y, size.Vector3i.z);
    (* Load the corresponding image in each mipmap if requested *)
    let load_level lvl = 
      List.iteri (fun layer img -> 
        match img with
        | Some img -> 
          let data = Image.data (Image.mipmap img lvl) in
          GL.Texture.subimage3D
            GLTypes.TextureTarget.Texture3D
            lvl (0,0,layer)
            (size.Vector3i.x lsr lvl, size.Vector3i.y lsr lvl, 1)
            GLTypes.PixelFormat.RGBA
            data
        | None     -> ()
      ) imgs;
    in
    begin match mipmaps with
    | `AllGenerated | `Generated _ ->
      for lvl = 0 to levels -1 do
        load_level lvl
      done
    | `None | `AllEmpty | `Empty _ -> 
      load_level 0
    end;
    (* Return the texture *)
    tex

  let size tex = tex.size

  let minify tex filter = Common.minify tex.common filter

  let magnify tex filter = Common.magnify tex.common filter

  let wrap tex func = Common.wrap tex.common func

  let mipmap_levels t = t.common.Common.mipmaps

  let mipmap t i = 
    if i < 0 || i >= t.common.Common.mipmaps then 
      Error `Invalid_mipmap
    else
      Ok {Texture3DMipmap.common = t.common;
          size   = Vector3i.({x = t.size.x lsr i; y = t.size.y lsr i; z = t.size.z lsr i});
          level  = i;
          layer  = 0}

  let bind t uid = Common.bind t.common uid

end


