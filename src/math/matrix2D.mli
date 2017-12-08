(* Optimized operations on 2D (3x3) float matrices *)

(* Type of 3x3 matrices stored in a flat column major array *)
type t

(* Zero matrix *)
val zero : unit -> t

(* Identity matrix *)
val identity : unit -> t

(* Pretty-printer to string *)
val to_string : t -> string

(* Translation matrix *)
val translation : Vector2f.t -> t

(* Scaling matrix *)
val scaling : Vector2f.t -> t

(* Rotation matrix *)
val rotation : float -> t

(* Product *)
val product : t -> t -> t

(* Transposition *)
val transpose : t -> t

(* Return a new, translated matrix *)
val translate : Vector2f.t -> t -> t

(* Return a new, scaled matrix *)
val scale : Vector2f.t -> t -> t

(* Return a new, rotated matrix *)
val rotate : float -> t -> t

(* Vector right-product *)
val times : t -> Vector2f.t -> Vector2f.t

(* Screen projection matrix *)
val projection : size:Vector2f.t -> (t, [> `Invalid_projection]) result

(* Inverse screen projection matrix *)
val iprojection : size:Vector2f.t -> (t, [> `Invalid_projection]) result

(* Transformation matrix *)
val transformation : 
  translation:Vector2f.t ->
  rotation:float ->
  scale:Vector2f.t ->
  origin:Vector2f.t -> t

(* Returns the matrix as a bigarray *)
val to_bigarray : t -> (float, Bigarray.float32_elt, Bigarray.c_layout) Bigarray.Array1.t

