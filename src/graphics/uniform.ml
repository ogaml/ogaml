
exception Unknown_uniform of string

exception Invalid_uniform of string

type uniform = 
  | Vector3f of OgamlMath.Vector3f.t
  | Matrix3D of OgamlMath.Matrix3D.t
  | Color of Color.RGB.t

module UniformMap = Map.Make (struct

  type t = string

  let compare (s1 : string) (s2 : string) = compare s1 s2

end)

type t = uniform UniformMap.t

let empty = UniformMap.empty

let vector3f s v m = UniformMap.add s (Vector3f v) m

let matrix3D s mat m = UniformMap.add s (Matrix3D mat) m

let color s c m = UniformMap.add s (Color (Color.rgb c)) m


module LL = struct

  let bind map u =
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
    | Vector3f v, GL.Types.GlslType.Float3   -> 
        OgamlMath.Vector3f.(
          GL.Uniform.float3 location v.x v.y v.z
        )
    | Matrix3D m, GL.Types.GlslType.Float4x4 -> 
        OgamlMath.Matrix3D.(
          GL.Uniform.mat4 location (GL.Data.of_matrix m)
        )
    | Color    c, GL.Types.GlslType.Float4   -> 
        Color.RGB.(
          GL.Uniform.float4 location c.r c.g c.b c.a
        )
    | _ -> raise (Invalid_uniform (Printf.sprintf "Uniform %s has wrong type" name))

end
