
(* Returns a simple cube with 36 vertices (12 triangles) *)
val cube : Vector3f.t -> Vector3f.t -> Vector3f.t list

(* Returns the 3 axis of the cartesian coordinate system *)
val axis : Vector3f.t -> Vector3f.t -> Vector3f.t list

(* Returns a sphere of a given radius and precision (>= 0) *)
val sphere : float -> int -> Vector3f.t list

