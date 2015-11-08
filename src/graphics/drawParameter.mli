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

(** Creates a set *)
val make : ?culling:CullingMode.t -> 
           ?polygon:PolygonMode.t ->
           ?depth_test:bool ->
           unit -> t

(** Returns the value of the culling parameter *)
val culling : t -> CullingMode.t

(** Returns the value of the polygon parameter *)
val polygon : t -> PolygonMode.t

(** Returns the value of the depth test parameter *)
val depth_test : t -> bool

