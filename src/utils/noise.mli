
module Perlin2D : sig

  type t

  val create : unit -> t

  val create_with_seed : Random.State.t -> t

  val get : t -> OgamlMath.Vector2f.t -> float

end


module Perlin3D : sig

  type t

  val create : unit -> t

  val create_with_seed : Random.State.t -> t

  val get : t -> OgamlMath.Vector3f.t -> float

end
