
exception Image_error of string

type t

val create : [`File of string | 
              `Empty of OgamlMath.Vector2i.t * Color.t | 
              `Data of OgamlMath.Vector2i.t * Bytes.t] -> t

val save : t -> string -> unit

val size : t -> OgamlMath.Vector2i.t

val set : t -> OgamlMath.Vector2i.t -> Color.t -> unit

val get : t -> OgamlMath.Vector2i.t -> Color.RGB.t

val data : t -> Bytes.t

val mipmap : t -> int -> t

val blit : t -> ?rect:OgamlMath.IntRect.t -> t -> OgamlMath.Vector2i.t -> unit

val pad : t -> ?offset:OgamlMath.Vector2i.t -> ?color:Color.t -> 
               OgamlMath.Vector2i.t -> t
