(** This module provides a way to construct a set
  * of draw parameters to be passed when drawing
**)

(** Type of a set of draw parameters *)
type t

(** Backface culling enumeration *)
module CullingMode : sig

  type t = 
    | CullNone
    | CullClockwise
    | CullCounterClockwise

end

(** Polygon drawing mode enumeration *)
module PolygonMode : sig

  type t = 
    | DrawVertices
    | DrawLines
    | DrawFill

end

module Viewport : sig

  type t = 
    | Full
    | Relative of OgamlMath.FloatRect.t
    | Absolute of OgamlMath.IntRect.t

end

(** Blend mode *)
module BlendMode : sig

  module Factor : sig

    type t = 
      | Zero
      | One
      | SrcColor
      | OneMinusSrcColor
      | DestColor
      | OneMinusDestColor
      | SrcAlpha
      | SrcAlphaSaturate
      | OneMinusSrcAlpha
      | DestAlpha
      | OneMinusDestAlpha
      | ConstColor
      | OneMinusConstColor
      | ConstAlpha
      | OneMinusConstAlpha

  end

  module Equation : sig

    type t = 
      | None
      | Add of Factor.t * Factor.t
      | Sub of Factor.t * Factor.t

  end

  type t = {color : Equation.t; alpha : Equation.t}

  val default : t

  val alpha : t

  val additive : t

  val soft_additive : t
  
end


(** Creates a set *)
val make : ?culling:CullingMode.t -> 
           ?polygon:PolygonMode.t ->
           ?depth_test:bool ->
           ?blend_mode:BlendMode.t -> 
           ?viewport:Viewport.t ->
           ?antialiasing:bool ->
           unit -> t

(** Returns the value of the culling parameter *)
val culling : t -> CullingMode.t

(** Returns the value of the polygon parameter *)
val polygon : t -> PolygonMode.t

(** Returns the value of the depth test parameter *)
val depth_test : t -> bool

val blend_mode : t -> BlendMode.t

val viewport : t -> Viewport.t

val antialiasing : t -> bool
