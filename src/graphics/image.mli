
exception Load_error of string

type t

val create : [`File of string | 
              `Empty of int * int * Color.t | 
              `Data of int * int * Bytes.t] -> t

val size : t -> OgamlMath.Vector2i.t

val set : t -> OgamlMath.Vector2i.t -> Color.t -> unit

val get : t -> OgamlMath.Vector2i.t -> Color.RGB.t

val data : t -> Bytes.t

val blit : t -> ?rect:OgamlMath.IntRect.t -> t -> OgamlMath.Vector2i.t -> unit

