
module Data = struct

  type batype = (float, Bigarray.float32_elt, Bigarray.c_layout) Bigarray.Array1.t

  type t = {
    mutable data   : batype;
    mutable size   : int;
    mutable length : int
  }

  let create i = 
    let arr = 
      Bigarray.Array1.create 
        Bigarray.float32 
        Bigarray.c_layout
        (max i 1)
    in
    {data = arr; size = (max i 1); length = 0}

  let double t = 
    let arr = 
      Bigarray.Array1.create
        Bigarray.float32
        Bigarray.c_layout
        (t.size * 2)
    in
    Bigarray.Array1.sub arr 0 t.size 
    |> Bigarray.Array1.blit t.data;
    t.size <- t.size * 2;
    t.data <- arr

  let rec alloc t i = 
    let space = t.size - t.length in
    if space < i then begin
      double t;
      alloc t i
    end

  let add_3f t vec = 
    alloc t 3;
    t.data.{t.length+0} <- vec.OgamlMath.Vector3f.x;
    t.data.{t.length+1} <- vec.OgamlMath.Vector3f.y;
    t.data.{t.length+2} <- vec.OgamlMath.Vector3f.z;
    t.length <- t.length+3

  let add_color t col = 
    alloc t 4;
    let c = Color.rgb col in
    t.data.{t.length+0} <- c.Color.RGB.r;
    t.data.{t.length+1} <- c.Color.RGB.g;
    t.data.{t.length+2} <- c.Color.RGB.b;
    t.data.{t.length+3} <- c.Color.RGB.a;
    t.length <- t.length+4

  let add_2f t (a,b) = 
    alloc t 2;
    t.data.{t.length+0} <- a;
    t.data.{t.length+1} <- b;
    t.length <- t.length+2

  let of_matrix m = {
    data = OgamlMath.Matrix3D.to_bigarray m;
    size = 16;
    length = 16
  }

  let length t = t.length

  let get t i = t.data.{i}

end


module Pervasives = struct

  external clear : bool -> bool -> bool -> unit = "caml_gl_clear"

  external culling : Enum.CullingMode.t -> unit = "caml_culling_mode"

  external polygon : Enum.PolygonMode.t -> unit = "caml_polygon_mode"

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

  external data : int -> Data.t option -> Enum.VBOKind.t -> unit = "caml_vbo_data"

  external subdata : int -> int -> Data.t -> unit = "caml_vbo_subdata"

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





