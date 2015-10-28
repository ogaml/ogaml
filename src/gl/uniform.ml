type t = 
  | Float1    of float
  | Float2    of float * float
  | Float3    of float * float * float
  | Float4    of float * float * float * float
  | Int1      of int
  | Int2      of int * int
  | Int3      of int * int * int
  | Int4      of int * int * int * int
  | UInt1     of int
  | UInt2     of int * int
  | UInt3     of int * int * int
  | UInt4     of int * int * int * int
  | Matrix2   of Buffers.Data.ft
  | Matrix3   of Buffers.Data.ft
  | Matrix4   of Buffers.Data.ft
  | Matrix2x3 of Buffers.Data.ft
  | Matrix3x2 of Buffers.Data.ft
  | Matrix2x4 of Buffers.Data.ft
  | Matrix4x2 of Buffers.Data.ft
  | Matrix3x4 of Buffers.Data.ft
  | Matrix4x3 of Buffers.Data.ft


external abstract_uniform1f : 
  Program.uniform -> float -> unit = "caml_gl_uniform1f"

external abstract_uniform2f : 
  Program.uniform -> float -> float -> unit = "caml_gl_uniform2f"

external abstract_uniform3f : 
  Program.uniform -> float -> float -> float -> unit = "caml_gl_uniform3f"

external abstract_uniform4f : 
  Program.uniform -> float -> float -> float -> float -> unit = "caml_gl_uniform4f"

external abstract_uniform1i : 
  Program.uniform -> int -> unit = "caml_gl_uniform1i"

external abstract_uniform2i : 
  Program.uniform -> int -> int -> unit = "caml_gl_uniform2i"

external abstract_uniform3i : 
  Program.uniform -> int -> int -> int -> unit = "caml_gl_uniform3i"

external abstract_uniform4i : 
  Program.uniform -> int -> int -> int -> int -> unit = "caml_gl_uniform4i"

external abstract_uniform1ui : 
  Program.uniform -> int -> unit = "caml_gl_uniform1ui"

external abstract_uniform2ui : 
  Program.uniform -> int -> int -> unit = "caml_gl_uniform2ui"

external abstract_uniform3ui : 
  Program.uniform -> int -> int -> int -> unit = "caml_gl_uniform3ui"

external abstract_uniform4ui : 
  Program.uniform -> int -> int -> int -> int -> unit = "caml_gl_uniform4ui"

external abstract_uniformmat2 : 
  Program.uniform -> Buffers.Data.ft -> unit = "caml_gl_uniform_mat2"

external abstract_uniformmat3 : 
  Program.uniform -> Buffers.Data.ft -> unit = "caml_gl_uniform_mat3"

external abstract_uniformmat4 : 
  Program.uniform -> Buffers.Data.ft -> unit = "caml_gl_uniform_mat4"

external abstract_uniformmat23 : 
  Program.uniform -> Buffers.Data.ft -> unit = "caml_gl_uniform_mat23"

external abstract_uniformmat32 : 
  Program.uniform -> Buffers.Data.ft -> unit = "caml_gl_uniform_mat32"

external abstract_uniformmat24 : 
  Program.uniform -> Buffers.Data.ft -> unit = "caml_gl_uniform_mat24"

external abstract_uniformmat42 : 
  Program.uniform -> Buffers.Data.ft -> unit = "caml_gl_uniform_mat42"

external abstract_uniformmat34 : 
  Program.uniform -> Buffers.Data.ft -> unit = "caml_gl_uniform_mat34"

external abstract_uniformmat43 : 
  Program.uniform -> Buffers.Data.ft -> unit = "caml_gl_uniform_mat43"


let set v loc = 
  match v with
  | Float1 f            -> abstract_uniform1f loc f
  | Float2 (f1,f2)      -> abstract_uniform2f loc f1 f2
  | Float3 (f1,f2,f3)   -> abstract_uniform3f loc f1 f2 f3
  | Float4 (f1,f2,f3,f4)-> abstract_uniform4f loc f1 f2 f3 f4
  | Int1 i              -> abstract_uniform1i loc i
  | Int2 (i1,i2)        -> abstract_uniform2i loc i1 i2
  | Int3 (i1,i2,i3)     -> abstract_uniform3i loc i1 i2 i3
  | Int4 (i1,i2,i3,i4)  -> abstract_uniform4i loc i1 i2 i3 i4
  | UInt1 i             -> abstract_uniform1ui loc i
  | UInt2 (i1,i2)       -> abstract_uniform2ui loc i1 i2
  | UInt3 (i1,i2,i3)    -> abstract_uniform3ui loc i1 i2 i3
  | UInt4 (i1,i2,i3,i4) -> abstract_uniform4ui loc i1 i2 i3 i4
  | Matrix2   d         -> abstract_uniformmat2 loc d
  | Matrix3   d         -> abstract_uniformmat3 loc d
  | Matrix4   d         -> abstract_uniformmat4 loc d
  | Matrix2x3 d         -> abstract_uniformmat23 loc d
  | Matrix3x2 d         -> abstract_uniformmat32 loc d
  | Matrix2x4 d         -> abstract_uniformmat24 loc d
  | Matrix4x2 d         -> abstract_uniformmat42 loc d
  | Matrix3x4 d         -> abstract_uniformmat34 loc d
  | Matrix4x3 d         -> abstract_uniformmat43 loc d



