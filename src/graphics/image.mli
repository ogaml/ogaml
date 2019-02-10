type t

val empty : OgamlMath.Vector2i.t -> Color.t -> t

val load : string -> (t, [> `File_not_found of string | `Loading_error of string]) result

val create : [`File of string | 
              `Empty of OgamlMath.Vector2i.t * Color.t | 
              `Data of OgamlMath.Vector2i.t * Bytes.t] -> 
             (t, [> `File_not_found of string
                  | `Loading_error of string
                  | `Wrong_data_length]) result

val save : t -> string -> unit

val size : t -> OgamlMath.Vector2i.t

val set : t -> OgamlMath.Vector2i.t -> Color.t -> (unit, [> `Out_of_bounds]) result

val get : t -> OgamlMath.Vector2i.t -> (Color.RGB.t, [> `Out_of_bounds]) result

val data : t -> Bytes.t

val mipmap : t -> int -> t

val blit : t -> ?rect:OgamlMath.IntRect.t -> t -> OgamlMath.Vector2i.t -> 
           (unit, [> `Out_of_bounds]) result

val pad : t -> ?offset:OgamlMath.Vector2i.t -> ?color:Color.t -> 
               OgamlMath.Vector2i.t -> t
