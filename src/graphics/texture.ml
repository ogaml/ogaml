
module type T = sig

  type t

  val bind : t -> int -> unit

end

module MinifyFilter = GLTypes.MinifyFilter

module MagnifyFilter = GLTypes.MagnifyFilter

module WrapFunction = GLTypes.WrapFunction

module Any = struct

  type t = {
      context : State.t;
      internal: GL.Texture.t;
      target  : GLTypes.TextureTarget.t;
      id      : int;
      mutable minify  : MinifyFilter.t option;
      mutable magnify : MagnifyFilter.t option;
      mutable wrap    : WrapFunction.t option;
  }


  let set_unit st uid = 
    let bound_unit = State.LL.texture_unit st in
    if bound_unit <> uid then begin
      State.LL.set_texture_unit st uid;
      GL.Texture.activate uid
    end

  let bind tex uid = 
    set_unit tex.context uid;
    let bound_tex = State.LL.bound_texture tex.context uid in
    if bound_tex <> Some tex.id then begin
      State.LL.set_bound_texture tex.context uid (Some (tex.id, tex.target));
      GL.Texture.bind tex.target (Some tex.internal)
    end

  let unbind state target uid = 
    set_unit state uid;
    let bound_tex = 
      State.LL.bound_texture state uid
    in
    let bound_target = 
      State.LL.bound_target state uid
    in
    if bound_tex <> None && bound_target = Some target then begin
      State.LL.set_bound_texture
        state uid
        None;
      GL.Texture.bind target None
    end

  let create state target =
    (* Create the texture *)
    let internal = GL.Texture.create () in
    let tex = {internal; 
               context = state;
               target;
               id = State.LL.texture_id state; 
               wrap = None;
               magnify = Some GLTypes.MagnifyFilter.Linear;
               minify = Some GLTypes.MinifyFilter.Linear} in
    (* Bind it *)
    bind tex 0;
    (* Set reasonable parameters *)
    GL.Texture.parameter target (`Minify GLTypes.MinifyFilter.Linear);
    GL.Texture.parameter target (`Magnify GLTypes.MagnifyFilter.Linear);
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

module Texture2D = struct

  type t = {
    internal  : Any.t;
    width     : int;
    height    : int;
  }

  let create (type s) (module M : RenderTarget.T with type t = s) target src = 
    let state = M.state target in
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
    let internal = Any.create state GLTypes.TextureTarget.Texture2D in
    let tex = {internal; 
               width; 
               height} in
    (* Bind the texture *)
    Any.bind tex.internal 0;
    (* Load the corresponding image *)
    GL.Texture.image
      GLTypes.TextureTarget.Texture2D
      GLTypes.PixelFormat.RGBA
      (width, height)
      GLTypes.TextureFormat.RGBA
      (Some data);
    (* Return the texture *)
    tex

  let size tex = OgamlMath.Vector2i.({x = tex.width; y = tex.height})

  let minify tex filter = Any.minify tex.internal filter

  let magnify tex filter = Any.magnify tex.internal filter

  let wrap tex func = Any.wrap tex.internal func

  let bind tex uid = Any.bind tex.internal uid

end
