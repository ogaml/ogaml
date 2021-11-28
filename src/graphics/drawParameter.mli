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

  val premultiplied_alpha : t
  
end


module DepthTest : sig

  type t = 
    | None
    | Always
    | Never
    | Less
    | Greater
    | Equal
    | LEqual
    | GEqual
    | NEqual

end


module Query : sig

  module LL : sig

    type t

    val begin_ : t -> unit

    val end_ : t -> unit

  end

  module SamplesPassed : sig

    type t = LL.t

    val create : unit -> t

    val get : ?wait:bool -> t -> int

  end

  module AnySamplesPassed : sig

    type t = LL.t

    val create : unit -> t

    val get : ?wait:bool -> t -> bool

  end

  module PrimitivesGenerated : sig

    type t = LL.t

    val create : unit -> t

    val get : ?wait:bool -> t -> int

  end

  module TimeElapsed : sig

    type t = LL.t

    val create : unit -> t

    val get : ?wait:bool -> t -> float

  end

end


(** Creates a set *)
val make : ?culling:CullingMode.t -> 
           ?polygon:PolygonMode.t ->
           ?depth_test:DepthTest.t ->
           ?depth_write:bool ->
           ?color_write:(bool * bool * bool * bool) ->
           ?blend_mode:BlendMode.t -> 
           ?viewport:Viewport.t ->
           ?antialiasing:bool ->
           ?samples_query:Query.SamplesPassed.t ->
           ?any_samples_query:Query.AnySamplesPassed.t ->
           ?primitives_query:Query.PrimitivesGenerated.t ->
           ?time_query:Query.TimeElapsed.t ->
           ?polygon_offset:(float * float) ->
           unit -> t

(** Returns the value of the culling parameter *)
val culling : t -> CullingMode.t

(** Returns the value of the polygon parameter *)
val polygon : t -> PolygonMode.t

(** Returns the value of the depth test parameter *)
val depth_test : t -> DepthTest.t

(** Returns true iff depth writing is enabled *)
val depth_write : t -> bool

val color_write : t -> (bool * bool * bool * bool)

val blend_mode : t -> BlendMode.t

val viewport : t -> Viewport.t

val antialiasing : t -> bool

val samples_query : t -> Query.SamplesPassed.t option

val any_samples_query : t -> Query.AnySamplesPassed.t option

val primitives_query : t -> Query.PrimitivesGenerated.t option

val time_query : t -> Query.TimeElapsed.t option

val polygon_offset : t -> (float * float) option
