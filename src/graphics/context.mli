(** Represents an OpenGL context and keeps track of bound
  * values to avoid costly successive bindings.
  * 
  * Note that setters do not change the value stored
  * by the internal GL state and should not be used alone.
  *
  * NOTE : setters are intended for internal use only
**)

(** Capabilities of the context *)
type capabilities = {
  max_3D_texture_size       : int;
  max_array_texture_layers  : int;
  max_color_texture_samples : int;
  max_cube_map_texture_size : int;
  max_depth_texture_samples : int;
  max_elements_indices      : int;
  max_elements_vertices     : int;
  max_integer_samples       : int;
  max_renderbuffer_size     : int;
  max_texture_buffer_size   : int;
  max_texture_image_units   : int;
  max_texture_size          : int;
  max_color_attachments     : int;
  max_draw_buffers          : int;
}

(** Pool of free IDs (used for textures, buffers, etc)
  * Finalizers should call free on the ID *)
module ID_Pool : sig

  type t

  val get_next : t -> int

  val free : t -> int -> unit

end

(** Type of the GL context *)
type t

(** Returns the capabilities of the context *)
val capabilities : t -> capabilities

(** Returns the current OpenGL version. Format : (major, minor) *)
val version : t -> (int * int)

(** Returns true iff the OpenGL version passed as parameter is supported *)
val is_version_supported : t -> (int * int) -> bool

(** Returns the current GLSL version *)
val glsl_version : t -> int

(** Returns true iff the GLSL version passed as parameter is supported *)
val is_glsl_version_supported : t -> int -> bool

(** Checks that no GL error occurred *)
val check_errors : t -> 
  (unit, [> `Invalid_value | `Invalid_enum | `Invalid_op | `Invalid_fbop
          | `Out_of_memory | `Stack_overflow | `Stack_underflow]) result

(** Flushes the GL buffer *)
val flush : t -> unit

(** Finishes all pending actions *)
val finish : t -> unit


module LL : sig

  (** Creates a new, default-initialized GL context *)
  val create : unit -> 
    (t, [> `Context_initialization_error of string]) result

  (** Returns the internal sprite-drawing program *)
  val sprite_drawing : t -> ProgramInternal.t

  (** Returns the internal shape-drawing program *)
  val shape_drawing : t -> ProgramInternal.t

  (** Returns the internal text-drawing program *)
  val text_drawing : t -> ProgramInternal.t

  (** Returns the current culling mode *)
  val culling_mode : t -> DrawParameter.CullingMode.t

   (** Returns the current polygon drawing mode *)
  val polygon_mode : t -> DrawParameter.PolygonMode.t

  (** Returns if depth testing is currently activated or not *)
  val depth_test : t -> bool

  (** Returns if depth writing is currently activated or not *)
  val depth_writing : t -> bool

  (** Returns if color writing is currently activated or not (RGBA components) *)
  val color_writing : t -> (bool * bool * bool * bool)

  (** Returns the current depth function *)
  val depth_function : t -> DrawParameter.DepthTest.t

  (** Returns the clear color *)
  val clear_color : t -> Color.t

  (** Sets the current culling mode *)
  val set_culling_mode : t -> DrawParameter.CullingMode.t -> unit

  (** Sets the current polygon drawing mode *)
  val set_polygon_mode : t -> DrawParameter.PolygonMode.t -> unit

  (** Sets the current value of depth testing *)
  val set_depth_test : t -> bool -> unit

  (** Sets the current value of depth writing*)
  val set_depth_writing : t -> bool -> unit

  (** Sets the current value of color writing*)
  val set_color_writing : t -> (bool * bool * bool * bool) -> unit

  (** Sets the current value of the depth function *)
  val set_depth_function : t -> DrawParameter.DepthTest.t -> unit

  (** Get the current value of MSAA *)
  val msaa : t -> bool

  (** Sets the current value of MSAA *)
  val set_msaa : t -> bool -> unit

  (** Sets the currently active texture unit *)
  val set_texture_unit : t -> int -> unit

  (** Returns the currently active texture unit *)
  val texture_unit : t -> int

  (** Returns the texture ID pool *)
  val texture_pool : t -> ID_Pool.t

  (** Sets the currently bound texture ID to a texture unit and a target *)
  val set_bound_texture : t -> int -> (GL.Texture.t * int * GLTypes.TextureTarget.t) option -> unit

  (** Returns the texture currently bound to a texture unit *)
  val bound_texture : t -> int -> (GL.Texture.t * int * GLTypes.TextureTarget.t) option

  (** Returns the texture id currently bound to a texture unit *)
  val bound_texture_id : t -> int -> int option

  (** Returns a reusable array of booleans of length max_texture_image_units *)
  val pooled_texture_array : t -> bool array

  (** Sets the currently linked program *)
  val set_linked_program : t -> (GL.Program.t * int) option -> unit

  (** Returns the currently linked program ID *)
  val linked_program : t -> int option

  (** Returns the program ID pool *)
  val program_pool : t -> ID_Pool.t

  (** Sets the currently bound VBO *)
  val set_bound_vbo : t -> (GL.VBO.t * int) option -> unit

  (** Returns the currently bound VBO ID *)
  val bound_vbo : t -> int option

  (** Returns the vbo ID pool *)
  val vbo_pool : t -> ID_Pool.t

  (** Sets the currently bound VBO *)
  val set_bound_vao : t -> (GL.VAO.t * int) option -> unit

  (** Returns the currently bound VBO ID *)
  val bound_vao : t -> int option

  (** Returns the vbo ID pool *)
  val vao_pool : t -> ID_Pool.t

  (** Sets the current clear color *)
  val set_clear_color : t -> Color.t -> unit

  (** Sets the currently bound EBO *)
  val set_bound_ebo : t -> (GL.EBO.t * int) option -> unit

  (** Returns the currently bound EBO ID *)
  val bound_ebo : t -> int option

  (** Returns the ebo ID pool *)
  val ebo_pool : t -> ID_Pool.t

  (** Returns the currently bound FBO ID *)
  val bound_fbo : t -> int

  (** Sets the currently bound FBO *)
  val set_bound_fbo : t -> (GL.FBO.t * int) option -> unit

  (** Returns the fbo ID pool *)
  val fbo_pool : t -> ID_Pool.t

  (** Returns the rbo ID pool *)
  val rbo_pool : t -> ID_Pool.t

  (** Returns whether alpha blending is currently enabled *)
  val blending : t -> bool

  (** Sets if alpha blending is currently enabled *)
  val set_blending : t -> bool -> unit

  (** Returns the current blending mode *)
  val blend_equation : t -> DrawParameter.BlendMode.t

  (** Sets the current blending mode *)
  val set_blend_equation : t -> DrawParameter.BlendMode.t -> unit

  (** Returns the current viewport *)
  val viewport : t -> OgamlMath.IntRect.t

  (** Sets the current viewport *)
  val set_viewport : t -> OgamlMath.IntRect.t -> unit

  (** Returns the current polygon offset *)
  val polygon_offset : t -> (float * float) option

  (** Sets the current polygon offset *)
  val set_polygon_offset : t -> (float * float) option -> unit

end




