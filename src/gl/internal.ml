
module Data = struct

  type ('a, 'b) t = ('a, 'b, Bigarray.c_layout) Bigarray.Array1.t

  let of_float_array a = 
    Bigarray.Array1.of_array Bigarray.float32 Bigarray.c_layout a

end


module Texture = struct

  type t


  (* Abstract functions *)
  external image2D : Enum.TextureTarget.t -> Enum.PixelFormat.t ->
    (int * int) -> Enum.TextureFormat.t -> Bytes.t -> unit = "caml_tex_image_2D"


  (* Exposed functions *)
  external create : unit -> t = "caml_create_texture"

  external activate : int -> unit = "caml_activate_texture"

  external bind : Enum.TextureTarget.t -> t option -> unit = "caml_bind_texture"

  external parameter2D : 
    [`Magnify of Enum.MagnifyFilter.t |`Minify  of Enum.MinifyFilter.t] 
    -> unit = "caml_tex_parameter_2D"

  external destroy : t -> unit = "caml_destroy_texture"

  let image target = 
    match target with
    |Enum.TextureTarget.Texture1D -> failwith "Not yet implemented"
    |Enum.TextureTarget.Texture2D -> image2D target
    |Enum.TextureTarget.Texture3D -> failwith "Not yet implemented"

end


module Shader = struct

  type t

  external create : Enum.ShaderType.t -> t = "caml_create_shader"

  external source : t -> string -> unit = "caml_source_shader"

  external compile : t -> unit = "caml_compile_shader"

  external status : t -> bool = "caml_shader_status"

  external log : t -> string = "caml_shader_log"

end


module Program = struct

  type t

  external create : unit -> t = "caml_create_program"

  external attach : t -> Shader.t -> unit = "caml_attach_shader"

  external link : t -> unit = "caml_link_program"

  external uloc : t -> string -> int = "caml_uniform_location"

  external aloc : t -> string -> int = "caml_attrib_location"

  external ucount : t -> int = "caml_uniform_count"

  external acount : t -> int = "caml_attribute_count"

  external use : t option -> unit = "caml_use_program"

  external status : t -> bool = "caml_program_status"

  external uname : t -> int -> string = "caml_uniform_name"

  external aname : t -> int -> string = "caml_attribute_name"

  external utype : t -> int -> Enum.GlslType.t = "caml_uniform_type"

  external atype : t -> int -> Enum.GlslType.t = "caml_attribute_type"

  external log : t -> string = "caml_program_log"

end


module VBO = struct

  type t

  external create : unit -> t = "caml_create_buffer"

  external bind : t option -> unit = "caml_bind_vbo"

  external data : int -> ('a, 'b) Data.t option -> Enum.VBOKind.t -> unit = "caml_vbo_data"

  external subdata : int -> int -> ('a, 'b) Data.t -> unit = "caml_vbo_subdata"

  external destroy : t -> unit = "caml_destroy_buffer"

end


module VAO = struct

  type t

  external create : unit -> t = "caml_create_vao"

  external bind : t option -> unit = "caml_bind_vao"

  external destroy : t -> unit = "caml_destroy_vao"

  external enable_attrib : int -> unit = "caml_enable_attrib"

  external attrib_float : 
    int -> int -> Enum.GlFloatType.t -> int -> int -> unit = "caml_attrib_float"

  external attrib_int : 
    int -> int -> Enum.GlIntType.t -> int -> int -> unit = "caml_attrib_int"

  external draw : Enum.DrawMode.t -> int -> int -> unit = "caml_draw_arrays"

end



