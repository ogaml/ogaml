
val bind_fbo : 
  State.t -> int -> GL.FBO.t option -> unit

val clear : 
  ?color:Color.t -> depth:bool -> stencil:bool -> State.t -> unit

val bind_draw_parameters : 
  State.t -> OgamlMath.Vector2i.t -> int -> DrawParameter.t -> unit

