
module RGB : sig

  type t = {r : float; g : float; b : float; a : float}

  val black : t

  val white : t

  val red : t

  val green : t

  val blue : t

  val yellow : t

  val magenta : t

  val cyan : t

  val transparent : t

  val clamp : t -> t

  val map : t -> (float -> float) -> t

  val print : t -> string

end


module HSV : sig

  type t = {h : float; s : float; v : float; a : float}

  val black : t

  val white : t

  val red : t

  val green : t

  val blue : t

  val yellow : t

  val magenta : t

  val cyan : t

  val transparent : t

  val clamp : t -> t

  val print : t -> string

end


type t = [`HSV of HSV.t | `RGB of RGB.t]


val rgb_to_hsv : RGB.t -> HSV.t

val hsv_to_rgb : HSV.t -> RGB.t

val hsv : t -> HSV.t

val rgb : t -> RGB.t

val clamp : t -> t

val map : t -> (float -> float) -> t

val print : t -> string

