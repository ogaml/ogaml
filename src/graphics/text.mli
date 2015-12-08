
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


module Font : sig

  type t 

  type code = [`Char of char | `Code of int]

  (** Loads a font from a file *)
  val load : string -> t

  (** Usage : glyph font char size bold *)
  val glyph : t -> code -> int -> bool -> Glyph.t

  (** Returns the kerning between two chars *)
  val kerning : t -> code -> code -> int -> int

  (** Returns the line spacing *)
  val spacing : t -> int -> int

  (** Returns the texture of a given font size *)
  val texture : t -> int -> Texture.Texture2D.t

  (** Updates the texture for a size, not exposed *)
  val update : t -> int -> unit

end


(* type t *)

(* create : position -> text -> color -> ... -> t *)
