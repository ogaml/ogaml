
(* Type of renderable module *)
module type T = sig

  module OutputBuffer : sig

    type t

  end

  (* Type of a render target *)
  type t

  (* Returns the size of a render target *)
  val size : t -> OgamlMath.Vector2i.t

  (* Returns the internal context associated to a render target *)
  val context : t -> Context.t

  (* Clears a render target *)
  val clear : ?buffers:OutputBuffer.t list -> ?color:Color.t option -> 
    ?depth:bool -> ?stencil:bool -> t -> 
    (unit, [> `Too_many_draw_buffers | `Duplicate_draw_buffer | `Invalid_color_buffer]) result

  (* Binds a render target for drawing. System-only function, usually done
   * automatically. *)
  val bind : t -> ?buffers:OutputBuffer.t list -> DrawParameter.t ->
    (unit, [> `Too_many_draw_buffers | `Duplicate_draw_buffer | `Invalid_color_buffer]) result

end

(* Non-exposed low-level functions *)
val bind_fbo : 
  Context.t -> int -> GL.FBO.t option -> unit

val clear : 
  ?color:Color.t -> depth:bool -> stencil:bool -> Context.t -> unit

val bind_draw_parameters : 
  Context.t -> OgamlMath.Vector2i.t -> int -> DrawParameter.t -> unit

