open OgamlUtils
open Result.Operators

type uniform = 
  | Vector3f  of OgamlMath.Vector3f.t
  | Vector2f  of OgamlMath.Vector2f.t
  | Vector3i  of OgamlMath.Vector3i.t
  | Vector2i  of OgamlMath.Vector2i.t
  | Matrix3D  of OgamlMath.Matrix3D.t
  | Matrix2D  of OgamlMath.Matrix2D.t
  | Color     of Color.RGB.t
  | Texture2D of (int option * Texture.Texture2D.t)
  | Texture3D of (int option * Texture.Texture3D.t)
  | Texture2DArray of (int option * Texture.Texture2DArray.t)
  | DepthTexture2D of (int option * Texture.DepthTexture2D.t)
  | Shadow2D  of (int option * Texture.CompareFunction.t * Texture.DepthTexture2D.t)
  | Cubemap   of (int option * Texture.Cubemap.t)
  | Float     of float
  | Int       of int

module UniformMap = Map.Make (struct

  type t = string

  let compare (s1 : string) (s2 : string) = compare s1 s2

end)

type t = uniform UniformMap.t

let assert_free m s = 
  if UniformMap.mem s m then
    Error (`Duplicate_uniform s)
  else
    Ok ()

let empty = UniformMap.empty

let vector3f s v m = 
  assert_free m s >>>= fun () ->
  UniformMap.add s (Vector3f v) m

let vector3f_r s v m = 
  UniformMap.add s (Vector3f v) m

let vector2f s v m = 
  assert_free m s >>>= fun () ->
  UniformMap.add s (Vector2f v) m

let vector2f_r s v m = 
  UniformMap.add s (Vector2f v) m

let vector3i s v m = 
  assert_free m s >>>= fun () ->
  UniformMap.add s (Vector3i v) m

let vector3i_r s v m = 
  UniformMap.add s (Vector3i v) m

let vector2i s v m = 
  assert_free m s >>>= fun () ->
  UniformMap.add s (Vector2i v) m

let vector2i_r s v m = 
  UniformMap.add s (Vector2i v) m

let matrix3D s mat m = 
  assert_free m s >>>= fun () ->
  UniformMap.add s (Matrix3D mat) m

let matrix3D_r s mat m = 
  UniformMap.add s (Matrix3D mat) m

let matrix2D s mat m = 
  assert_free m s >>>= fun () ->
  UniformMap.add s (Matrix2D mat) m

let matrix2D_r s mat m = 
  UniformMap.add s (Matrix2D mat) m

let color s c m = 
  assert_free m s >>>= fun () ->
  UniformMap.add s (Color (Color.to_rgb c)) m

let color_r s c m = 
  UniformMap.add s (Color (Color.to_rgb c)) m

let texture2D s ?tex_unit t m = 
  assert_free m s >>>= fun () ->
  UniformMap.add s (Texture2D (tex_unit,t)) m

let texture2D_r s ?tex_unit t m = 
  UniformMap.add s (Texture2D (tex_unit,t)) m

let texture3D s ?tex_unit t m = 
  assert_free m s >>>= fun () ->
  UniformMap.add s (Texture3D (tex_unit,t)) m

let texture3D_r s ?tex_unit t m = 
  UniformMap.add s (Texture3D (tex_unit,t)) m

let texture2Darray s ?tex_unit t m = 
  assert_free m s >>>= fun () ->
  UniformMap.add s (Texture2DArray (tex_unit,t)) m

let texture2Darray_r s ?tex_unit t m = 
  UniformMap.add s (Texture2DArray (tex_unit,t)) m

let depthtexture2D s ?tex_unit t m = 
  assert_free m s >>>= fun () ->
  UniformMap.add s (DepthTexture2D (tex_unit,t)) m

let depthtexture2D_r s ?tex_unit t m = 
  UniformMap.add s (DepthTexture2D (tex_unit,t)) m

let shadow2D s ?tex_unit ?(comparison=Texture.CompareFunction.LEqual) t m = 
  assert_free m s >>>= fun () ->
  UniformMap.add s (Shadow2D (tex_unit, comparison, t)) m

let shadow2D_r s ?tex_unit ?(comparison=Texture.CompareFunction.LEqual) t m = 
  UniformMap.add s (Shadow2D (tex_unit, comparison, t)) m

let int s i m = 
  assert_free m s >>>= fun () ->
  UniformMap.add s (Int i) m

let int_r s i m = 
  UniformMap.add s (Int i) m

let float s f m = 
  assert_free m s >>>= fun () ->
  UniformMap.add s (Float f) m

let float_r s f m = 
  UniformMap.add s (Float f) m

let cubemap s ?tex_unit t m = 
  assert_free m s >>>= fun () ->
  UniformMap.add s (Cubemap (tex_unit,t)) m

let cubemap_r s ?tex_unit t m = 
  UniformMap.add s (Cubemap (tex_unit,t)) m


module LL = struct

  let bind context map unifs =
    let capabilities = Context.capabilities context in
    let max_units = capabilities.Context.max_texture_image_units in
    let available_units = Context.LL.pooled_texture_array context in
    Array.fill available_units 0 max_units true;
    let add_unit u =
      if u >= max_units || u < 0 then
        Error (`Invalid_texture_unit u)
      else begin
        available_units.(u) <- false;
        Ok ()
      end
    in
    let rec next_unit i = 
      if i >= max_units then
        Error `Too_many_textures
      else if available_units.(i) then Ok i
      else next_unit (i+1)
    in
    let bind_aux u = 
      let name = Program.Uniform.name u in
      begin try 
        Ok (UniformMap.find name map)
      with Not_found -> 
        Error (`Missing_uniform name)
      end >>= fun v ->
      let location = Program.Uniform.location u in
      match (v, Program.Uniform.kind u) with
      | Vector3f v, GLTypes.GlslType.Float3   -> 
          OgamlMath.Vector3f.(
            GL.Uniform.float3 location v.x v.y v.z
          ); Ok ()
      | Vector2f v, GLTypes.GlslType.Float2   -> 
          OgamlMath.Vector2f.(
            GL.Uniform.float2 location v.x v.y
          ); Ok ()
      | Vector3i v, GLTypes.GlslType.Int3 -> 
          OgamlMath.Vector3i.(
            GL.Uniform.int3 location v.x v.y v.z
          ); Ok ()
      | Vector2i v, GLTypes.GlslType.Int2 -> 
          OgamlMath.Vector2i.(
            GL.Uniform.int2 location v.x v.y
          ); Ok ()
      | Matrix3D m, GLTypes.GlslType.Float4x4 -> 
          OgamlMath.Matrix3D.(
            GL.Uniform.mat4 location (GL.Data.of_bigarray (to_bigarray m))
          ); Ok ()
      | Matrix2D m, GLTypes.GlslType.Float3x3 -> 
          OgamlMath.Matrix2D.(
            GL.Uniform.mat4 location (GL.Data.of_bigarray (to_bigarray m))
          ); Ok ()
      | Color    c, GLTypes.GlslType.Float4   -> 
          Color.RGB.(
            GL.Uniform.float4 location c.r c.g c.b c.a
          ); Ok ()
      | Float    f, GLTypes.GlslType.Float    ->
          GL.Uniform.float1 location f; Ok ()
      | Int      i, GLTypes.GlslType.Int      ->
          GL.Uniform.int1 location i; Ok ()
      | Texture2D (Some u,t), GLTypes.GlslType.Sampler2D ->
          add_unit u >>>= fun () ->
          Texture.Texture2D.bind t u;
          GL.Uniform.int1 location (Context.LL.texture_unit context)
      | Texture2D (None, t), GLTypes.GlslType.Sampler2D ->
          next_unit 0 >>= fun u ->
          add_unit u >>>= fun () ->
          Texture.Texture2D.bind t u;
          GL.Uniform.int1 location (Context.LL.texture_unit context)
      | DepthTexture2D (Some u,t), GLTypes.GlslType.Sampler2D ->
          add_unit u >>>= fun () ->
          Texture.DepthTexture2D.bind t u;
          GL.Uniform.int1 location (Context.LL.texture_unit context)
      | DepthTexture2D (None, t), GLTypes.GlslType.Sampler2D ->
          next_unit 0 >>= fun u ->
          add_unit u >>>= fun () ->
          Texture.DepthTexture2D.bind t u;
          GL.Uniform.int1 location (Context.LL.texture_unit context)
      | Shadow2D (Some u, cmp, t), GLTypes.GlslType.Sampler2DShadow ->
          add_unit u >>>= fun () ->
          Texture.DepthTexture2D.bind t u;
          Texture.DepthTexture2D.compare_function t (Some cmp);
          GL.Uniform.int1 location (Context.LL.texture_unit context)
      | Shadow2D (None, cmp, t), GLTypes.GlslType.Sampler2DShadow ->
          next_unit 0 >>= fun u ->
          add_unit u >>>= fun () ->
          Texture.DepthTexture2D.bind t u;
          Texture.DepthTexture2D.compare_function t (Some cmp);
          GL.Uniform.int1 location (Context.LL.texture_unit context)
      | Texture3D (Some u,t), GLTypes.GlslType.Sampler3D ->
          add_unit u >>>= fun () ->
          Texture.Texture3D.bind t u;
          GL.Uniform.int1 location (Context.LL.texture_unit context)
      | Texture3D (None, t), GLTypes.GlslType.Sampler3D ->
          next_unit 0 >>= fun u ->
          add_unit u >>>= fun () ->
          Texture.Texture3D.bind t u;
          GL.Uniform.int1 location (Context.LL.texture_unit context)
      | Texture2DArray (Some u,t), GLTypes.GlslType.Sampler2DArray ->
          add_unit u >>>= fun () ->
          Texture.Texture2DArray.bind t u;
          GL.Uniform.int1 location (Context.LL.texture_unit context)
      | Texture2DArray (None, t), GLTypes.GlslType.Sampler2DArray ->
          next_unit 0 >>= fun u ->
          add_unit u >>>= fun () ->
          Texture.Texture2DArray.bind t u;
          GL.Uniform.int1 location (Context.LL.texture_unit context)
      | Cubemap (Some u,t), GLTypes.GlslType.SamplerCube ->
          add_unit u >>>= fun () ->
          Texture.Cubemap.bind t u;
          GL.Uniform.int1 location (Context.LL.texture_unit context)
      | Cubemap (None, t), GLTypes.GlslType.SamplerCube ->
          next_unit 0 >>= fun u ->
          add_unit u >>>= fun () ->
          Texture.Cubemap.bind t u;
          GL.Uniform.int1 location (Context.LL.texture_unit context)
      | _ -> 
        Error (`Invalid_uniform_type name)
    in
    Result.List.iter bind_aux unifs

end
