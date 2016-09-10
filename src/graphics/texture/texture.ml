open OgamlMath

exception Texture_error of string

module type T = sig

  type t

  val bind : t -> int -> unit

end

module MinifyFilter = GLTypes.MinifyFilter

module MagnifyFilter = GLTypes.MagnifyFilter

module WrapFunction = GLTypes.WrapFunction

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

module Texture2DMipmap = struct

  type t = {
    common  : Common.t;
    width   : int;
    height  : int;
    level   : int
  }

  let bind tex uid = 
    Common.bind tex.common uid

  let size tex = 
    Vector2i.({x = tex.width; y = tex.height})

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
      (Some (Image.data img))

  let level tex = 
    tex.level

  let to_color_attachment tex = 
    Attachment.ColorAttachment.Texture2D (tex.common.Common.internal, tex.level)

end


module Texture2D = struct

  type t = {
    common  : Common.t;
    width   : int;
    height  : int;
  }

  let create (type s) (module M : RenderTarget.T with type t = s) target 
    ?mipmaps:(mipmaps=`AllGenerated) src = 
    let context = M.context target in
    (* Extract the texture parameters *)
    let width, height, img = 
      match src with
      | `File s -> 
        let img = Image.create (`File s) in
        let v = Image.size img in
        v.Vector2i.x, v.Vector2i.y, (Some img)
      | `Image img ->
        let v = Image.size img in
        v.Vector2i.x, v.Vector2i.y, (Some img)
      | `Empty size ->
        size.Vector2i.x, size.Vector2i.y, None
    in
    let levels = 
      let max_levels = Common.max_mipmaps Vector2i.({x = width; y = height}) in
      match mipmaps with
      | `AllGenerated | `AllEmpty    -> max_levels
      | `Empty i      | `Generated i -> max 1 (min max_levels i)
      | `None -> 1
     in
    (* Check that the size is allowed *)
    let capabilities = Context.capabilities context in
    let max_size = capabilities.Context.max_texture_size in
    if width > max_size || height > max_size then
      raise (Texture_error "Maximal texture size exceeded");
    (* Create the internal texture *)
    let common = Common.create context levels GLTypes.TextureTarget.Texture2D in
    let tex = {common; width; height} in
    (* Bind the texture *)
    Common.bind tex.common 0;
    (* Allocate the texture *)
    GL.Texture.storage2D
      GLTypes.TextureTarget.Texture2D 
      levels 
      GLTypes.TextureFormat.RGBA8
      (width, height);
    (* Load the corresponding image in each mipmap if requested *)
    let load_level lvl = 
      let data = 
        match img with
        | Some img -> Some (Image.data (Image.mipmap img lvl))
        | None     -> None
      in
      GL.Texture.subimage2D
        GLTypes.TextureTarget.Texture2D 
        lvl (0,0)
        (width lsr lvl, height lsr lvl)
        GLTypes.PixelFormat.RGBA
        data
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

  let size tex = Vector2i.({x = tex.width; y = tex.height})

  let minify tex filter = Common.minify tex.common filter

  let magnify tex filter = Common.magnify tex.common filter

  let wrap tex func = Common.wrap tex.common func

  let mipmap_levels tex = tex.common.Common.mipmaps

  let mipmap tex i = 
    if i >= tex.common.Common.mipmaps || i < 0 then
      raise (Invalid_argument (Printf.sprintf "Mipmap level out of bounds"))
    else
      {Texture2DMipmap.common = tex.common; 
       width = tex.width lsr i; 
       height = tex.height lsr i;
       level = i}

  let bind tex uid = Common.bind tex.common uid

  let to_color_attachment tex = 
    Attachment.ColorAttachment.Texture2D (tex.common.Common.internal, 0)

end


module Texture2DArrayLayerMipmap = struct

  type t = {
    common : Common.t;
    width  : int;
    height : int;
    level  : int;
    layer  : int
  }

  let size t = Vector2i.({x = t.width; y = t.height})

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
                          (Some (Image.data img))

  let to_color_attachment t = 
    Attachment.ColorAttachment.Texture2DArray (t.common.Common.internal, t.layer, t.level)

end


module Texture2DArrayMipmap = struct

  type t = {
    common : Common.t;
    width  : int;
    height : int;
    depth  : int;
    level  : int
  }

  let size t = Vector3i.({x = t.width; y = t.height; z = t.depth})

  let layers t = t.depth

  let level t = t.level

  let layer t i = 
    if i < 0 || i >= t.depth then 
      raise (Invalid_argument "Texture 2D array : layer out of bounds");
    {Texture2DArrayLayerMipmap.common = t.common;
                               width  = t.width;
                               height = t.height;
                               level  = t.level;
                               layer  = i}

  let bind t uid = Common.bind t.common uid

end


module Texture2DArrayLayer = struct

  type t = {
    common : Common.t;
    width  : int;
    height : int;
    layer  : int
  }

  let size t = Vector2i.({x = t.width; y = t.height})

  let layer t = t.layer

  let mipmap_levels t = t.common.Common.mipmaps

  let mipmap t i = 
    if i < 0 || i >= t.common.Common.mipmaps then 
      raise (Invalid_argument "Texture 2D array : mipmap level out of bounds");
    {Texture2DArrayLayerMipmap.common = t.common;
                               width  = t.width lsr i;
                               height = t.height lsr i;
                               level  = i;
                               layer  = t.layer}

  let bind t uid = Common.bind t.common uid

  let to_color_attachment t = 
    Attachment.ColorAttachment.Texture2DArray (t.common.Common.internal, t.layer, 0)

end


module Texture2DArray = struct

  type t = {
    common : Common.t;
    width  : int;
    height : int;
    depth  : int
  }

  let create (type a) (module M : RenderTarget.T with type t = a) target
    ?mipmaps:(mipmaps = `AllGenerated) src =
    let context = M.context target in
    (* Extract the texture parameters *)
    let width, height, depth, imgs = 
      match src with
      | `File sl -> 
        if sl = [] then raise (Texture_error "Texture 2D array : empty file list");
        let imgs = List.map (fun s -> Image.create (`File s)) sl in
        let size = 
          List.fold_left (fun size img -> 
            let imgsize = Image.size img in
            if imgsize <> size then 
              raise (Texture_error "Texture 2D array : images of different sizes");
            size
         ) (Image.size (List.hd imgs)) imgs
        in
        let depth = List.length imgs in
        size.Vector2i.x, size.Vector2i.y, depth, (List.map (fun i -> Some i) imgs)
      | `Image imgs ->
        if imgs = [] then raise (Texture_error "Texture 2D array : empty image list");
        let size = 
          List.fold_left (fun size img -> 
            let imgsize = Image.size img in
            if imgsize <> size then 
              raise (Texture_error "Texture 2D array : images of different sizes");
            size
         ) (Image.size (List.hd imgs)) imgs
        in
        let depth = List.length imgs in
        size.Vector2i.x, size.Vector2i.y, depth, (List.map (fun i -> Some i) imgs)
      | `Empty size ->
        let imgs = 
          let rec mk = function
           | 0 -> []
           | n -> None :: (mk (n-1))
          in
          mk size.Vector3i.z
        in
        size.Vector3i.x, size.Vector3i.y, size.Vector3i.z, imgs
    in
    let levels = 
      let max_levels = Common.max_mipmaps Vector2i.({x = width; y = height}) in
      match mipmaps with
      | `AllGenerated | `AllEmpty    -> max_levels
      | `Empty i      | `Generated i -> max 1 (min max_levels i)
      | `None -> 1
     in
    (* Check that the size is allowed *)
    let capabilities = Context.capabilities context in
    let max_size = capabilities.Context.max_texture_size in
    let max_depth = capabilities.Context.max_array_texture_layers in
    if width > max_size || height > max_size then
      raise (Texture_error "Maximal texture size exceeded");
    if depth > max_depth then
      raise (Texture_error "Maximal texture depth exceeded");
    (* Create the internal texture *)
    let common = Common.create context levels GLTypes.TextureTarget.Texture2DArray in
    let tex = {common; width; height; depth} in
    (* Bind the texture *)
    Common.bind tex.common 0;
    (* Allocate the texture *)
    GL.Texture.storage3D
      GLTypes.TextureTarget.Texture2DArray
      levels 
      GLTypes.TextureFormat.RGBA8
      (width, height, depth);
    (* Load the corresponding image in each mipmap if requested *)
    let load_level lvl = 
      List.iteri (fun layer img -> 
        let data = 
          match img with
          | Some img -> Some (Image.data (Image.mipmap img lvl))
          | None     -> None
        in
        GL.Texture.subimage3D
          GLTypes.TextureTarget.Texture2DArray
          lvl (0,0,layer)
          (width lsr lvl, height lsr lvl, 1)
          GLTypes.PixelFormat.RGBA
          data
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

  let size tex = Vector3i.({x = tex.width; y = tex.height; z = tex.depth})

  let minify tex filter = Common.minify tex.common filter

  let magnify tex filter = Common.magnify tex.common filter

  let wrap tex func = Common.wrap tex.common func

  let layers t = t.depth

  let mipmap_levels t = t.common.Common.mipmaps

  let layer t i = 
    if i < 0 || i >= t.depth then 
      raise (Invalid_argument "Texture 2D array : layer out of bounds");
    {Texture2DArrayLayer.common = t.common;
                         width  = t.width;
                         height = t.height;
                         layer  = i}

  let mipmap t i = 
    if i < 0 || i >= t.common.Common.mipmaps then 
      raise (Invalid_argument "Texture 2D array : mipmap level out of bounds");
    {Texture2DArrayMipmap.common = t.common;
                          width  = t.width lsr i;
                          height = t.height lsr i;
                          depth  = t.depth;
                          level  = i}

  let bind t uid = Common.bind t.common uid

end
