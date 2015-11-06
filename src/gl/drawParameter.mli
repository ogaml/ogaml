(** This module provides a way to construct a set
  * of draw parameters to be passed when drawing
**)

(** Type of a set of draw parameters *)
type t

(** Creates a set *)
val make : ?culling:Enum.CullingMode.t -> 
           ?polygon:Enum.PolygonMode.t ->
           unit -> t

(** Returns the value of the culling parameter *)
val culling : t -> Enum.CullingMode.t

(** Returns the value of the polygon parameter *)
val polygon : t -> Enum.PolygonMode.t


