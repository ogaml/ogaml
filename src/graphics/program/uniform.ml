
exception Invalid_uniform of string

let error fmt = Printf.ksprintf (fun s -> raise (Invalid_uniform s)) fmt

type uniform = 
  | Vector3f  of OgamlMath.Vector3f.t
  | Vector2f  of OgamlMath.Vector2f.t
  | Vector3i  of OgamlMath.Vector3i.t
  | Vector2i  of OgamlMath.Vector2i.t
  | Matrix3D  of OgamlMath.Matrix3D.t
  | Matrix2D  of OgamlMath.Matrix2D.t
  | Color     of Color.RGB.t
  | Texture2D of (int option * Texture.Texture2D.t)
  | Float     of float
  | Int       of int
  | Texture2DArray of (int option * Texture.Texture2DArray.t)
  | Cubemap   of (int option * Texture.Cubemap.t)

module UniformMap = Map.Make (struct

  type t = string

  let compare (s1 : string) (s2 : string) = compare s1 s2

end)

type t = uniform UniformMap.t

let assert_free m s = 
  if UniformMap.mem s m then
    error "Uniform %s is bound twice" s

let empty = UniformMap.empty

let vector3f s v m = 
  assert_free m s;
  UniformMap.add s (Vector3f v) m

let vector2f s v m = 
  assert_free m s;
  UniformMap.add s (Vector2f v) m

let vector3i s v m = 
  assert_free m s;
  UniformMap.add s (Vector3i v) m

let vector2i s v m = 
  assert_free m s;
  UniformMap.add s (Vector2i v) m

let matrix3D s mat m = 
  assert_free m s;
  UniformMap.add s (Matrix3D mat) m

let matrix2D s mat m = 
  assert_free m s;
  UniformMap.add s (Matrix2D mat) m

let color s c m = 
  assert_free m s;
  UniformMap.add s (Color (Color.to_rgb c)) m

let texture2D s ?tex_unit t m = 
  assert_free m s;
  UniformMap.add s (Texture2D (tex_unit,t)) m

let texture2Darray s ?tex_unit t m = 
  assert_free m s;
  UniformMap.add s (Texture2DArray (tex_unit,t)) m

let int s i m = 
  assert_free m s;
  UniformMap.add s (Int i) m

let float s f m = 
  assert_free m s;
  UniformMap.add s (Float f) m

let cubemap s ?tex_unit t m = 
  assert_free m s;
  UniformMap.add s (Cubemap (tex_unit,t)) m


module LL = struct

  let bind context map unifs =
    let capabilities = Context.capabilities context in
    let max_units = capabilities.Context.max_texture_image_units in
    let available_units = Context.LL.pooled_texture_array context in
    Array.fill available_units 0 max_units true;
    let add_unit u =
      if u >= max_units || u < 0 then
        error "Texture unit out of bounds";
      available_units.(u) <- false
    in
    let rec next_unit i = 
      if i >= max_units then
        error "No available texture unit left"
      else if available_units.(i) then i
      else next_unit (i+1)
    in
    let bind_aux u = 
      let name = Program.Uniform.name u in
      let v = 
        try UniformMap.find name map
        with Not_found -> 
          error "Uniform %s required by the program but not provided" name
      in
      let location = Program.Uniform.location u in
      match (v, Program.Uniform.kind u) with
      | Vector3f v, GLTypes.GlslType.Float3   -> 
          OgamlMath.Vector3f.(
            GL.Uniform.float3 location v.x v.y v.z
          )
      | Vector2f v, GLTypes.GlslType.Float2   -> 
          OgamlMath.Vector2f.(
            GL.Uniform.float2 location v.x v.y
          )
      | Vector3i v, GLTypes.GlslType.Int3 -> 
          OgamlMath.Vector3i.(
            GL.Uniform.int3 location v.x v.y v.z
          )
      | Vector2i v, GLTypes.GlslType.Int2 -> 
          OgamlMath.Vector2i.(
            GL.Uniform.int2 location v.x v.y
          )
      | Matrix3D m, GLTypes.GlslType.Float4x4 -> 
          OgamlMath.Matrix3D.(
            GL.Uniform.mat4 location (GL.Data.of_bigarray (to_bigarray m))
          )
      | Matrix2D m, GLTypes.GlslType.Float3x3 -> 
          OgamlMath.Matrix2D.(
            GL.Uniform.mat4 location (GL.Data.of_bigarray (to_bigarray m))
          )
      | Color    c, GLTypes.GlslType.Float4   -> 
          Color.RGB.(
            GL.Uniform.float4 location c.r c.g c.b c.a
          )
      | Float    f, GLTypes.GlslType.Float    ->
          GL.Uniform.float1 location f
      | Int      i, GLTypes.GlslType.Int      ->
          GL.Uniform.int1 location i
      | Texture2D (Some u,t), GLTypes.GlslType.Sampler2D ->
          add_unit u;
          Texture.Texture2D.bind t u;
          GL.Uniform.int1 location (Context.LL.texture_unit context)
      | Texture2D (None, t), GLTypes.GlslType.Sampler2D ->
          let u = next_unit 0 in
          add_unit u;
          Texture.Texture2D.bind t u;
          GL.Uniform.int1 location (Context.LL.texture_unit context)
      | Texture2DArray (Some u,t), GLTypes.GlslType.Sampler2DArray ->
          add_unit u;
          Texture.Texture2DArray.bind t u;
          GL.Uniform.int1 location (Context.LL.texture_unit context)
      | Texture2DArray (None, t), GLTypes.GlslType.Sampler2DArray ->
          let u = next_unit 0 in
          add_unit u;
          Texture.Texture2DArray.bind t u;
          GL.Uniform.int1 location (Context.LL.texture_unit context)
      | Cubemap (Some u,t), GLTypes.GlslType.SamplerCube ->
          add_unit u;
          Texture.Cubemap.bind t u;
          GL.Uniform.int1 location (Context.LL.texture_unit context)
      | Cubemap (None, t), GLTypes.GlslType.SamplerCube ->
          let u = next_unit 0 in
          add_unit u;
          Texture.Cubemap.bind t u;
          GL.Uniform.int1 location (Context.LL.texture_unit context)
      | _ -> 
        error "Uniform %s does not have the type required by the program" name
    in
    List.iter bind_aux unifs

end
