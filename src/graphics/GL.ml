
(** Low-level GL enumerations *)
module Types = struct

  (** Shader types enumeration *)
  module ShaderType = struct

    type t = 
      | Fragment
      | Vertex

  end

  (** GLSL types enumeration *)
  module GlslType = struct

    type t =
      | Int
      | Int2
      | Int3
      | Int4
      | Float
      | Float2
      | Float3
      | Float4
      | Float2x2
      | Float2x3
      | Float2x4
      | Float3x2
      | Float3x3
      | Float3x4
      | Float4x2
      | Float4x3
      | Float4x4
      | Sampler1D
      | Sampler2D
      | Sampler3D

  end

  (** Texture targets enumeration *)
  module TextureTarget = struct

    type t = 
      | Texture1D
      | Texture2D
      | Texture3D

  end

  (** Pixel format enumeration *)
  module PixelFormat = struct

    type t = 
      | R
      | RG
      | RGB
      | BGR
      | RGBA
      | BGRA
      | Depth
      | DepthStencil

  end

  (** Texture format enumeration *)
  module TextureFormat = struct

    type t = 
      | RGB
      | RGBA
      | Depth
      | DepthStencil

  end

  (** Texture minify filter values *)
  module MinifyFilter = struct

    type t = 
      | Nearest
      | Linear
      | NearestMipmap
      | LinearMipmap

  end

  (** Texture magnify filter values *)
  module MagnifyFilter = struct

    type t = 
      | Nearest
      | Linear

  end

  (** VBO kinds enumeration *)
  module VBOKind = struct

    type t = 
      | StaticDraw
      | DynamicDraw

  end

  (** GL float types *)
  module GlFloatType = struct

    type t = 
      | Byte
      | UByte
      | Short
      | UShort
      | Int
      | UInt
      | Float
      | Double

  end

  (** GL int types *)
  module GlIntType = struct

    type t  =
      | Byte
      | UByte
      | Short
      | UShort
      | Int
      | UInt

  end

end


module Data = struct

  type ('a, 'b) batype = ('a, 'b, Bigarray.c_layout) Bigarray.Array1.t

  type float_32 = Bigarray.float32_elt

  type int_32 = Bigarray.int32_elt

  type ('a, 'b) t = {
    mutable data   : ('a, 'b) batype;
    mutable kind   : ('a, 'b) Bigarray.kind;
    mutable size   : int;
    mutable length : int
  }

  let create_int i = 
    let arr = 
      Bigarray.Array1.create 
        Bigarray.int32
        Bigarray.c_layout
        (max i 1)
    in
    {data = arr; kind = Bigarray.int32; size = (max i 1); length = 0}

  let create_float i = 
    let arr = 
      Bigarray.Array1.create 
        Bigarray.float32
        Bigarray.c_layout
        (max i 1)
    in
    {data = arr; kind = Bigarray.float32; size = (max i 1); length = 0}


  let double t = 
    let arr = 
      Bigarray.Array1.create
        t.kind
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

  let add_2f t v = 
    alloc t 2;
    t.data.{t.length+0} <- v.OgamlMath.Vector2f.x;
    t.data.{t.length+1} <- v.OgamlMath.Vector2f.x;
    t.length <- t.length+2

  let add_int32 t i =
    alloc t 1;
    t.data.{t.length} <- i;
    t.length <- t.length+1

  let add_int t i = 
    add_int32 t (Int32.of_int i)

  let of_matrix m = {
    data = OgamlMath.Matrix3D.to_bigarray m;
    kind = Bigarray.float32;
    size = 16;
    length = 16
  }

  let length t = t.length

  let get t i = t.data.{i}

end


module Pervasives = struct

  external clear : bool -> bool -> bool -> unit = "caml_gl_clear"

  external color : float -> float -> float -> float -> unit = "caml_clear_color"

  external culling : DrawParameter.CullingMode.t -> unit = "caml_culling_mode"

  external polygon : DrawParameter.PolygonMode.t -> unit = "caml_polygon_mode"

  external depthtest : bool -> unit = "caml_depth_test"

  external glsl_version : unit -> string = "caml_glsl_version"

  external gl_version : unit -> string = "caml_gl_version"

  external max_textures : unit -> int = "caml_max_textures"

end


module Texture = struct

  type t


  (* Abstract functions *)
  external image2D : Types.TextureTarget.t -> Types.PixelFormat.t ->
    (int * int) -> Types.TextureFormat.t -> Bytes.t -> unit = "caml_tex_image_2D"


  (* Exposed functions *)
  external create : unit -> t = "caml_create_texture"

  external activate : int -> unit = "caml_activate_texture"

  external bind : Types.TextureTarget.t -> t option -> unit = "caml_bind_texture"

  external parameter2D : 
    [`Magnify of Types.MagnifyFilter.t |`Minify  of Types.MinifyFilter.t] 
    -> unit = "caml_tex_parameter_2D"

  external destroy : t -> unit = "caml_destroy_texture"

  let image target = 
    match target with
    |Types.TextureTarget.Texture1D -> failwith "Not yet implemented"
    |Types.TextureTarget.Texture2D -> image2D target
    |Types.TextureTarget.Texture3D -> failwith "Not yet implemented"

end


module Shader = struct

  type t

  external create : Types.ShaderType.t -> t = "caml_create_shader"

  external valid : t -> bool = "caml_valid_shader"

  external source : t -> string -> unit = "caml_source_shader"

  external compile : t -> unit = "caml_compile_shader"

  external status : t -> bool = "caml_shader_status"

  external log : t -> string = "caml_shader_log"

end


module Program = struct

  type t

  type u_location = int

  type a_location = int

  external create : unit -> t = "caml_create_program"

  external valid : t -> bool = "caml_valid_program"

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

  external utype : t -> int -> Types.GlslType.t = "caml_uniform_type"

  external atype : t -> int -> Types.GlslType.t = "caml_attribute_type"

  external log : t -> string = "caml_program_log"

end


module VBO = struct

  type t

  external create : unit -> t = "caml_create_buffer"

  external bind : t option -> unit = "caml_bind_vbo"

  external data : int -> (float, Data.float_32) Data.t option -> Types.VBOKind.t -> unit = "caml_vbo_data"

  external subdata : int -> int -> (float, Data.float_32) Data.t -> unit = "caml_vbo_subdata"

  external destroy : t -> unit = "caml_destroy_buffer"

end


module EBO = struct

  type t

  external create : unit -> t = "caml_create_buffer"

  external bind : t option -> unit = "caml_bind_ebo"

  external destroy : t -> unit = "caml_destroy_buffer"

  external data : int -> (int32, Data.int_32) Data.t option -> Types.VBOKind.t -> unit = "caml_ebo_data"

  external subdata : int -> int -> (int32, Data.int_32) Data.t -> unit = "caml_ebo_subdata"

end


module VAO = struct

  type t

  external create : unit -> t = "caml_create_vao"

  external bind : t option -> unit = "caml_bind_vao"

  external destroy : t -> unit = "caml_destroy_vao"

  external enable_attrib : int -> unit = "caml_enable_attrib"

  external attrib_float : 
    int -> int -> Types.GlFloatType.t -> int -> int -> unit = "caml_attrib_float"

  external attrib_int : 
    int -> int -> Types.GlIntType.t -> int -> int -> unit = "caml_attrib_int"

  external draw : DrawMode.t -> int -> int -> unit = "caml_draw_arrays"

  external draw_elements : DrawMode.t -> int -> unit = "caml_draw_elements"

end


module Uniform = struct

  external float1 : int -> float -> unit = "caml_uniform1f"

  external float2 : int -> float -> float -> unit = "caml_uniform2f"

  external float3 : int -> float -> float -> float -> unit = "caml_uniform3f"

  external float4 : int -> float -> float -> float -> float -> unit = "caml_uniform4f"

  external int1 : int -> int -> unit = "caml_uniform1i"

  external int2 : int -> int -> int -> unit = "caml_uniform2i"

  external int3 : int -> int -> int -> int -> unit = "caml_uniform3i"

  external int4 : int -> int -> int -> int -> int -> unit = "caml_uniform4i"

  external uint1 : int -> int -> unit = "caml_uniform1ui"

  external uint2 : int -> int -> int -> unit = "caml_uniform2ui"

  external uint3 : int -> int -> int -> int -> unit = "caml_uniform3ui"

  external uint4 : int -> int -> int -> int -> int -> unit = "caml_uniform4ui"

  external abst_mat2 : int -> (float, Data.float_32) Data.batype -> unit = "caml_uniform_mat2"

  external abst_mat3 : int -> (float, Data.float_32) Data.batype -> unit = "caml_uniform_mat3"

  external abst_mat4 : int -> (float, Data.float_32) Data.batype -> unit = "caml_uniform_mat4"

  external abst_mat23 : int -> (float, Data.float_32) Data.batype -> unit = "caml_uniform_mat23"

  external abst_mat32 : int -> (float, Data.float_32) Data.batype -> unit = "caml_uniform_mat32"

  external abst_mat24 : int -> (float, Data.float_32) Data.batype -> unit = "caml_uniform_mat24"

  external abst_mat42 : int -> (float, Data.float_32) Data.batype -> unit = "caml_uniform_mat42"

  external abst_mat34 : int -> (float, Data.float_32) Data.batype -> unit = "caml_uniform_mat34"

  external abst_mat43 : int -> (float, Data.float_32) Data.batype -> unit = "caml_uniform_mat43"

  let mat2  i m = abst_mat2  i m.Data.data

  let mat3  i m = abst_mat3  i m.Data.data

  let mat4  i m = abst_mat4  i m.Data.data

  let mat23 i m = abst_mat23 i m.Data.data

  let mat32 i m = abst_mat32 i m.Data.data

  let mat24 i m = abst_mat24 i m.Data.data

  let mat42 i m = abst_mat42 i m.Data.data

  let mat34 i m = abst_mat34 i m.Data.data

  let mat43 i m = abst_mat43 i m.Data.data

end



