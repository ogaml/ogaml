(* Optimized operations on 3D (4x4) float matrices *)

(* Type of 4x4 matrices stored in a flat column major array *)
type t

(* Temporary ? *)
val to_bigarray : t -> (float, Bigarray.float32_elt, Bigarray.c_layout) Bigarray.Array1.t

(* Zero matrix *)
val zero : unit -> t

(* Identity matrix *)
val identity : unit -> t

(* Translation matrix *)
val translation : Vector3f.t -> t

(* Scaling matrix *)
val scaling : Vector3f.t -> t

(* Rotation matrix *)
val rotation : Vector3f.t -> float -> t

(* Product *)
val product : t -> t -> t

(* Translate a matrix in place, returns it for composition *)
val translate : Vector3f.t -> t -> t

(* Return a new, translated matrix *)
val translated : Vector3f.t -> t -> t

(* Scale a matrix in place, returns it for composition *)
val scale : Vector3f.vector3f -> t -> t

(* Return a new, scaled matrix *)
val scaled : Vector3f.vector3f -> t -> t

(* Return a new, rotated matrix *)
val rotated : Vector3f.t -> float -> t -> t

(* Vector right-product *)
val times : t -> Vector3f.t -> Vector3f.t


