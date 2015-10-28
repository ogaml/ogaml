
type t = float array

(* Returns a simple cube with 36 vertices (12 triangles) *)
val cube : Vector3f.t -> Vector3f.t -> t

(* Returns a cube with normals appended at the end *)
val cube_n : Vector3f.t -> Vector3f.t -> t

(* Returns the 3 axis of the cartesian coordinate system *)
val axis : float -> float -> t

(* Returns a sphere of a given radius and precision (>= 0) *)
val sphere : float -> int -> t

(* Returns a sphere of a given radius and precision (>= 0), with normals appended at the end *)
val sphere_n : float -> int -> t
