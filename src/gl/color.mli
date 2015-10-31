
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

end


val rgb_to_hsv : RGB.t -> HSV.t

val hsv_to_rgb : HSV.t -> RGB.t


