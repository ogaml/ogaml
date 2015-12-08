
module Glyph : sig

  type t

  (** Space after the glyph *)
  val advance : t -> int

  val bearing : t -> OgamlMath.Vector2i.t

  (** Bounding rectangle *)
  val rect : t -> OgamlMath.IntRect.t

  (** Coordinates of the glyph in the font's texture *)
  val uv : t -> OgamlMath.IntRect.t

end


type t

type code = [`Char of char | `Code of int]

(** Loads a font from a file *)
val load : string -> t

(** Preloads a glyph *)
val load_glyph : t -> code -> int -> bool -> unit

(** Usage : glyph font char size bold *)
val glyph : t -> code -> int -> bool -> Glyph.t

(** Returns the kerning between two chars *)
val kerning : t -> code -> code -> int -> int

(** Returns the coordinate above the baseline the font extends *)
val ascent : t -> int -> int

(** Returns the coordinate below the baseline the font
  * extends (usually negative) *)
val descent : t -> int -> int

(** Returns the distance between the descent of a line
  * and the ascent of the next line *)
val linegap : t -> int -> int

(** Returns the space between the baseline of two lines *)
val spacing : t -> int -> int

(** Returns the texture of a given font size *)
val texture : t -> int -> Texture.Texture2D.t




