open OgamlMath

exception Texture_error of string

module type T = sig

  type t

  val bind : t -> int -> unit

end

module MinifyFilter = GLTypes.MinifyFilter

module MagnifyFilter = GLTypes.MagnifyFilter

module WrapFunction = GLTypes.WrapFunction

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
    let tex = {internal; 
               context = context;
               target;
               mipmaps;
               id = Context.LL.texture_id context; 
               wrap = Some GLTypes.WrapFunction.ClampEdge;
               magnify = Some GLTypes.MagnifyFilter.Linear;
               minify = Some GLTypes.MinifyFilter.LinearMipmapLinear} in
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
    let size, img = 
      match src with
      | `File s -> 
        let img = Image.create (`File s) in
        let v = Image.size img in
        v, (Some img)
      | `Image img ->
        let v = Image.size img in
        v, (Some img)
      | `Empty size ->
        size, None
    in
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
      raise (Texture_error "Maximal texture size exceeded");
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
      raise (Invalid_argument (Printf.sprintf "Mipmap level out of bounds"))
    else
      {Texture2DMipmap.common = tex.common; 
       size = Vector2i.({x = tex.size.x lsr i; y = tex.size.y lsr i});
       level = i}

  let bind tex uid = Common.bind tex.common uid

  let to_color_attachment tex = 
    Attachment.ColorAttachment.Texture2D (tex.common.Common.internal, 0)

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
      raise (Invalid_argument "Texture 2D array : layer out of bounds");
    {Texture2DArrayLayerMipmap.common = t.common;
                               size   = t.size;
                               level  = t.level;
                               layer  = i}

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
      raise (Invalid_argument "Texture 2D array : mipmap level out of bounds");
    {Texture2DArrayLayerMipmap.common = t.common;
                               size   = Vector2i.({x = t.size.x lsr i; y = t.size.y lsr i});
                               level  = i;
                               layer  = t.layer}

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
        let img = Image.create (`File s) in
        let size = Image.size img in
        (size, Some img)
      | `Image i ->
        (Image.size i, Some i)
      | `Empty s ->
        (s, None)
    in
    if src = [] then 
      raise (Texture_error "Texture 2D array : empty file list");
    let lparams = 
      List.map extract_params src
    in
    let (size, fst_img) = List.hd lparams in
    let depth, imgs = 
      List.fold_left (fun (n, l_imgs) (img_size, img) -> 
        if img_size <> size then 
          raise (Texture_error "Texture 2D array : images of different sizes");
        (n+1, img :: l_imgs)
      ) (1, [fst_img]) (List.tl lparams)
    in
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
      raise (Texture_error "Maximal texture size exceeded");
    if depth > max_depth then
      raise (Texture_error "Maximal texture depth exceeded");
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
      raise (Invalid_argument "Texture 2D array : layer out of bounds");
    {Texture2DArrayLayer.common = t.common;
                         size   = t.size;
                         layer  = i}

  let mipmap t i = 
    if i < 0 || i >= t.common.Common.mipmaps then 
      raise (Invalid_argument "Texture 2D array : mipmap level out of bounds");
    {Texture2DArrayMipmap.common = t.common;
                          size   = Vector2i.({x = t.size.x lsr i; y = t.size.y lsr i});
                          depth  = t.depth;
                          level  = i}

  let bind t uid = Common.bind t.common uid

end


(*************************************************************)
(*                                                           *)
(*                    Cubemap Textures                       *)
(*                                                           *)
(*                                                           *)
(*************************************************************)

module Cubemap = struct

  type t = {
    common : Common.t;
    size   : Vector2i.t;
  }

  let create (type a) (module M : RenderTarget.T with type t = a) target
    ?mipmaps:(mipmaps = `AllGenerated) 
    ~positive_x ~positive_y ~positive_z 
    ~negative_x ~negative_y ~negative_z =
    let context = M.context target in
    (* Extract the texture parameters *)
    let extract_params = function
      | `File s ->
        let img = Image.create (`File s) in
        let size = Image.size img in
        (size, Some img)
      | `Image i ->
        (Image.size i, Some i)
      | `Empty s ->
        (s, None)
    in
    let ((spx, ipx), (spy,ipy), (spz, ipz), (snx, inx), (sny, iny), (snz, inz)) =
      extract_params positive_x,
      extract_params positive_y,
      extract_params positive_z,
      extract_params negative_x,
      extract_params negative_y,
      extract_params negative_z
    in
    if not (List.for_all (fun s -> s = spx) [spy; spz; snx; sny; snz]) then
      raise (Texture_error "Texture cubemap : images of different sizes");
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
      raise (Texture_error "Maximal cubemap texture size exceeded");
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
      raise (Invalid_argument "Cubemap texture : mipmap level out of bounds");
    {CubemapMipmap.common = t.common;
                   size   = Vector2i.map (fun v -> v lsr i) t.size;
                   level  = i}

  let face t f = 
    {CubemapFace.common = t.common;
                   size = t.size;
                   face = f}

  let bind t uid = Common.bind t.common uid

end

