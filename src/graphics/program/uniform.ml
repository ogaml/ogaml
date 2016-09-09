
exception Unknown_uniform of string

exception Invalid_uniform of string

type uniform = 
  | Vector3f  of OgamlMath.Vector3f.t
  | Vector2f  of OgamlMath.Vector2f.t
  | Vector3i  of OgamlMath.Vector3i.t
  | Vector2i  of OgamlMath.Vector2i.t
  | Matrix3D  of OgamlMath.Matrix3D.t
  | Matrix2D  of OgamlMath.Matrix2D.t
  | Color     of Color.RGB.t
  | Texture2D of (int * Texture.Texture2D.t)
  | Float     of float
  | Int       of int
  | Texture2DArray of (int * Texture.Texture2DArray.t)

module UniformMap = Map.Make (struct

  type t = string

  let compare (s1 : string) (s2 : string) = compare s1 s2

end)

type t = uniform UniformMap.t

let empty = UniformMap.empty

let vector3f s v m = UniformMap.add s (Vector3f v) m

let vector2f s v m = UniformMap.add s (Vector2f v) m

let vector3i s v m = UniformMap.add s (Vector3i v) m

let vector2i s v m = UniformMap.add s (Vector2i v) m

let matrix3D s mat m = UniformMap.add s (Matrix3D mat) m

let matrix2D s mat m = UniformMap.add s (Matrix2D mat) m

let color s c m = UniformMap.add s (Color (Color.rgb c)) m

let texture2D s ?tex_unit:(u=0) t m = UniformMap.add s (Texture2D (u,t)) m

let texture2Darray s ?tex_unit:(u=0) t m = UniformMap.add s (Texture2DArray (u,t)) m

let int s i m = UniformMap.add s (Int i) m

let float s f m = UniformMap.add s (Float f) m


module LL = struct

  let bind state map u =
    let name = Program.Uniform.name u in
    let v = 
      try UniformMap.find name map
      with Not_found -> begin
        let msg = Printf.sprintf "Uniform %s not provided" name in
        raise (Unknown_uniform msg)
      end
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
    | Texture2D (u,t), GLTypes.GlslType.Sampler2D ->
        Texture.Texture2D.bind t u;
        GL.Uniform.int1 location (State.LL.texture_unit state)
    | Texture2DArray (u,t), GLTypes.GlslType.Sampler2DArray ->
        Texture.Texture2DArray.bind t u;
        GL.Uniform.int1 location (State.LL.texture_unit state)
    | _ -> raise (Invalid_uniform (Printf.sprintf "Uniform %s has wrong type" name))

end
