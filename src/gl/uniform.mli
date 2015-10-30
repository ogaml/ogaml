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
  | Matrix3D  of OgamlMath.Matrix3D.t

val set : t -> Program.uniform -> unit

