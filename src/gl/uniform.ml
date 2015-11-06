
external abstract_uniform1f : 
  int -> float -> unit = "caml_gl_uniform1f"

external abstract_uniform2f : 
  int -> float -> float -> unit = "caml_gl_uniform2f"

external abstract_uniform3f : 
  int -> float -> float -> float -> unit = "caml_gl_uniform3f"

external abstract_uniform4f : 
  int -> float -> float -> float -> float -> unit = "caml_gl_uniform4f"

external abstract_uniform1i : 
  int -> int -> unit = "caml_gl_uniform1i"

external abstract_uniform2i : 
  int -> int -> int -> unit = "caml_gl_uniform2i"

external abstract_uniform3i : 
  int -> int -> int -> int -> unit = "caml_gl_uniform3i"

external abstract_uniform4i : 
  int -> int -> int -> int -> int -> unit = "caml_gl_uniform4i"

external abstract_uniform1ui : 
  int -> int -> unit = "caml_gl_uniform1ui"

external abstract_uniform2ui : 
  int -> int -> int -> unit = "caml_gl_uniform2ui"

external abstract_uniform3ui : 
  int -> int -> int -> int -> unit = "caml_gl_uniform3ui"

external abstract_uniform4ui : 
  int -> int -> int -> int -> int -> unit = "caml_gl_uniform4ui"

external abstract_uniformmat2 : 
  int -> Internal.Data.t -> unit = "caml_gl_uniform_mat2"

external abstract_uniformmat3 : 
  int -> Internal.Data.t -> unit = "caml_gl_uniform_mat3"

external abstract_uniformmat4 : 
  int -> Internal.Data.t -> unit = "caml_gl_uniform_mat4"

external abstract_uniformmat23 : 
  int -> Internal.Data.t -> unit = "caml_gl_uniform_mat23"

external abstract_uniformmat32 : 
  int -> Internal.Data.t -> unit = "caml_gl_uniform_mat32"

external abstract_uniformmat24 : 
  int -> Internal.Data.t -> unit = "caml_gl_uniform_mat24"

external abstract_uniformmat42 : 
  int -> Internal.Data.t -> unit = "caml_gl_uniform_mat42"

external abstract_uniformmat34 : 
  int -> Internal.Data.t -> unit = "caml_gl_uniform_mat34"

external abstract_uniformmat43 : 
  int -> Internal.Data.t -> unit = "caml_gl_uniform_mat43"

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
  | Vector3f v, Enum.GlslType.Float3   -> 
      OgamlMath.Vector3f.(
        abstract_uniform3f location v.x v.y v.z
      )
  | Matrix3D m, Enum.GlslType.Float4x4 -> 
      OgamlMath.Matrix3D.(
        abstract_uniformmat4 location (Internal.Data.of_matrix m)
      )
  | Color    c, Enum.GlslType.Float4   -> 
      Color.RGB.(
        abstract_uniform4f location c.r c.g c.b c.a
      )
  | _ -> raise (Invalid_uniform (Printf.sprintf "Uniform %s has wrong type" name))


