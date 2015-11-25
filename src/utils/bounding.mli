
module B3D : sig

  type aligned

  type any

  type 'a t

  val create_cube : OgamlMath.Vector3f.t -> OgamlMath.Vector3f.t -> aligned t

  val create_sphere : OgamlMath.Vector3f.t -> float -> any t

  val create_triangle : OgamlMath.Vector3f.t -> OgamlMath.Vector3f.t -> 
                        OgamlMath.Vector3f.t -> any t

  val merge : 'a t -> 'b t -> any t

  val rotate : 'a t -> float -> OgamlMath.Vector3f.t -> any t

  val translate : 'a t -> OgamlMath.Vector3f.t -> 'a t

  val scale : 'a t -> OgamlMath.Vector3f.t -> 'a t

  val minimal_aabb : 'a t -> aligned t

  val intersect : 'a t -> 'b t -> bool

end
