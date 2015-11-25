
module B3D : sig

  type aligned

  type any

  type 'a t

  val create_cube : ?origin:OgamlMath.Vector3f.t -> 
                    position:OgamlMath.Vector3f.t -> 
                    corner:OgamlMath.Vector3f.t ->
                    size:OgamlMath.Vector3f.t -> unit -> aligned t

  val create_sphere : ?origin:OgamlMath.Vector3f.t -> 
                      position:OgamlMath.Vector3f.t ->
                      radius:float -> unit -> any t

  val create_triangle : ?origin:OgamlMath.Vector3f.t -> 
                        position:OgamlMath.Vector3f.t -> 
                        point1:OgamlMath.Vector3f.t ->
                        point2:OgamlMath.Vector3f.t ->
                        point3:OgamlMath.Vector3f.t -> unit -> any t

  val merge : 'a t -> 'b t -> any t

  val rotate : 'a t -> angle:float -> axis:OgamlMath.Vector3f.t -> any t

  val translate : 'a t -> OgamlMath.Vector3f.t -> 'a t

  val minimal_aabb : 'a t -> aligned t

  val boundary : aligned t -> OgamlMath.Vector3f.t * OgamlMath.Vector3f.t

  val intersect : 'a t -> 'b t -> bool

end

