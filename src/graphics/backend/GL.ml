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
    {data = arr; kind = Bigarray.int32; size = (max i 4); length = 0}

  let create_float i = 
    let arr = 
      Bigarray.Array1.create 
        Bigarray.float32
        Bigarray.c_layout
        (max i 1)
    in
    {data = arr; kind = Bigarray.float32; size = (max i 4); length = 0}

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

  let append t1 t2 = 
    let n = t1.length in
    alloc t1 t2.length;
    Bigarray.Array1.sub t1.data n t2.length
    |> Bigarray.Array1.blit t2.data;
    t1.length <- n + t2.length

  let add_3f t vec = 
    alloc t 3;
    Bigarray.Array1.unsafe_set t.data (t.length+0) vec.OgamlMath.Vector3f.x;
    Bigarray.Array1.unsafe_set t.data (t.length+1) vec.OgamlMath.Vector3f.y;
    Bigarray.Array1.unsafe_set t.data (t.length+2) vec.OgamlMath.Vector3f.z;
    t.length <- t.length+3

  let add_3i t vec = 
    alloc t 3;
    Bigarray.Array1.unsafe_set t.data (t.length+0) (Int32.of_int vec.OgamlMath.Vector3i.x);
    Bigarray.Array1.unsafe_set t.data (t.length+1) (Int32.of_int vec.OgamlMath.Vector3i.y);
    Bigarray.Array1.unsafe_set t.data (t.length+2) (Int32.of_int vec.OgamlMath.Vector3i.z);
    t.length <- t.length+3

  let add_color t col = 
    alloc t 4;
    let c = Color.rgb col in
    Bigarray.Array1.unsafe_set t.data (t.length+0) c.Color.RGB.r;
    Bigarray.Array1.unsafe_set t.data (t.length+1) c.Color.RGB.g;
    Bigarray.Array1.unsafe_set t.data (t.length+2) c.Color.RGB.b;
    Bigarray.Array1.unsafe_set t.data (t.length+3) c.Color.RGB.a;
    t.length <- t.length+4

  let add_2f t v = 
    alloc t 2;
    Bigarray.Array1.unsafe_set t.data (t.length+0) v.OgamlMath.Vector2f.x;
    Bigarray.Array1.unsafe_set t.data (t.length+1) v.OgamlMath.Vector2f.y;
    t.length <- t.length+2

  let add_2i t v = 
    alloc t 2;
    Bigarray.Array1.unsafe_set t.data (t.length+0) (Int32.of_int v.OgamlMath.Vector2i.x);
    Bigarray.Array1.unsafe_set t.data (t.length+1) (Int32.of_int v.OgamlMath.Vector2i.y);
    t.length <- t.length+2

  let add_int32 t i =
    alloc t 1;
    Bigarray.Array1.unsafe_set t.data (t.length) i;
    t.length <- t.length+1

  let add_float t f = 
    alloc t 1;
    Bigarray.Array1.unsafe_set t.data (t.length) f;
    t.length <- t.length+1

  let add_int t i = 
    add_int32 t (Int32.of_int i)

  let of_bigarray m = {
    data = m;
    kind = Bigarray.float32;
    size = Bigarray.Array1.dim m;
    length = Bigarray.Array1.dim m
  }

  let length t = t.length

  let get t i = t.data.{i}
  
  let iter t f = 
    for i = 0 to t.length - 1 do
      f t.data.{i}
    done

  let map t f = 
    let data = 
      Bigarray.Array1.create 
        t.kind
        Bigarray.c_layout
        t.size
    in
    let newt = 
      {data; kind = t.kind; size = t.size; length = t.length}
    in
    for i = 0 to t.length - 1 do
      newt.data.{i} <- (f t.data.{i})
    done;
    newt

end


module Pervasives = struct

  external clear : bool -> bool -> bool -> unit = "caml_gl_clear"

  external error : unit -> GLTypes.GlError.t option = "caml_gl_error"

  external color : float -> float -> float -> float -> unit = "caml_clear_color"

  external viewport : int -> int -> int -> int -> unit = "caml_viewport"

  external culling : DrawParameter.CullingMode.t -> unit = "caml_culling_mode"

  external polygon : DrawParameter.PolygonMode.t -> unit = "caml_polygon_mode"

  external depthtest : bool -> unit = "caml_depth_test"

  external depthfunction : DrawParameter.DepthTest.t -> unit = "caml_depth_fun"

  external glsl_version : unit -> string = "caml_glsl_version"

  external gl_version : unit -> string = "caml_gl_version"

  external max_textures : unit -> int = "caml_max_textures"

  external flush : unit -> unit = "caml_glflush"

  external msaa : bool -> unit = "caml_enable_msaa"

end


module Blending = struct

  external enable : bool -> unit = "caml_blend_enable"

  external blend_func_separate : 
    DrawParameter.BlendMode.Factor.t ->
    DrawParameter.BlendMode.Factor.t ->
    DrawParameter.BlendMode.Factor.t ->
    DrawParameter.BlendMode.Factor.t -> unit = "caml_blend_func_separate"

  external blend_equation_separate : 
    DrawParameter.BlendMode.Equation.t ->
    DrawParameter.BlendMode.Equation.t -> unit = "caml_blend_equation_separate"

end


module Texture = struct

  type t


  (* Abstract functions *)
  external image2D : GLTypes.TextureTarget.t -> GLTypes.PixelFormat.t ->
    (int * int) -> GLTypes.TextureFormat.t -> Bytes.t option -> unit = "caml_tex_image_2D"


  (* Exposed functions *)
  external create : unit -> t = "caml_create_texture"

  external activate : int -> unit = "caml_activate_texture"

  external bind : GLTypes.TextureTarget.t -> t option -> unit = "caml_bind_texture"

  external parameter : 
    GLTypes.TextureTarget.t ->
    [`Magnify of GLTypes.MagnifyFilter.t 
    |`Minify  of GLTypes.MinifyFilter.t
    |`Wrap    of GLTypes.WrapFunction.t]
    -> unit = "caml_tex_parameter"

  external destroy : t -> unit = "caml_destroy_texture"

  let image target = 
    match target with
    |GLTypes.TextureTarget.Texture1D -> failwith "Not yet implemented"
    |GLTypes.TextureTarget.Texture2D -> image2D target
    |GLTypes.TextureTarget.Texture3D -> failwith "Not yet implemented"

end


module Shader = struct

  type t

  external create : GLTypes.ShaderType.t -> t = "caml_create_shader"

  external delete : t -> unit = "caml_delete_shader"

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

  external detach : t -> Shader.t -> unit = "caml_detach_shader"

  external link : t -> unit = "caml_link_program"

  external uloc : t -> string -> int = "caml_uniform_location"

  external aloc : t -> string -> int = "caml_attrib_location"

  external ucount : t -> int = "caml_uniform_count"

  external acount : t -> int = "caml_attribute_count"

  external use : t option -> unit = "caml_use_program"

  external status : t -> bool = "caml_program_status"

  external uname : t -> int -> string = "caml_uniform_name"

  external aname : t -> int -> string = "caml_attribute_name"

  external utype : t -> int -> GLTypes.GlslType.t = "caml_uniform_type"

  external atype : t -> int -> GLTypes.GlslType.t = "caml_attribute_type"

  external log : t -> string = "caml_program_log"

  external delete : t -> unit = "caml_delete_program"

end


module VBO = struct

  type t

  external create : unit -> t = "caml_create_buffer"

  external bind : t option -> unit = "caml_bind_vbo"

  external data : int -> ('a, 'b) Data.t option -> GLTypes.VBOKind.t -> unit = "caml_vbo_data"

  external subdata : int -> int -> ('a, 'b) Data.t -> unit = "caml_vbo_subdata"

  external copy_subdata : t -> t -> int -> int -> int -> unit = "caml_vbo_copy_subdata"

  external destroy : t -> unit = "caml_destroy_buffer"

end


module EBO = struct

  type t

  external create : unit -> t = "caml_create_buffer"

  external bind : t option -> unit = "caml_bind_ebo"

  external destroy : t -> unit = "caml_destroy_buffer"

  external data : int -> (int32, Data.int_32) Data.t option -> GLTypes.VBOKind.t -> unit = "caml_ebo_data"

  external subdata : int -> int -> (int32, Data.int_32) Data.t -> unit = "caml_ebo_subdata"

  external copy_subdata : t -> t -> int -> int -> int -> unit = "caml_vbo_copy_subdata"

end


module VAO = struct

  type t

  external create : unit -> t = "caml_create_vao"

  external bind : t option -> unit = "caml_bind_vao"

  external destroy : t -> unit = "caml_destroy_vao"

  external enable_attrib : int -> unit = "caml_enable_attrib"

  external attrib_float : 
    int -> int -> GLTypes.GlFloatType.t -> int -> int -> unit = "caml_attrib_float"

  external attrib_int : 
    int -> int -> GLTypes.GlIntType.t -> int -> int -> unit = "caml_attrib_int"

  external draw : DrawMode.t -> int -> int -> unit = "caml_draw_arrays"

  external draw_elements : DrawMode.t -> int -> int -> unit = "caml_draw_elements"

end


module RBO = struct

  type t

  external create : unit -> t = "caml_create_rbo"

  external bind : t option -> unit = "caml_bind_rbo"

  external destroy : t -> unit = "caml_destroy_rbo"

  external storage : GLTypes.TextureFormat.t -> int -> int -> unit = "caml_rbo_storage"

end


module FBO = struct

  type t 

  external create : unit -> t = "caml_create_fbo"

  external bind : t option -> unit = "caml_bind_fbo"

  external destroy : t -> unit = "caml_destroy_fbo"

  external texture2D : GLTypes.GlAttachement.t -> Texture.t -> int -> unit = "caml_fbo_texture2D"

  external render : GLTypes.GlAttachement.t -> RBO.t -> unit = "caml_fbo_renderbuffer"

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



