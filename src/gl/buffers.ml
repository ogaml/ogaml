open Bigarray


external abstract_clear : bool -> bool -> bool -> unit = "caml_gl_clear"

let clear ~color ~depth ~stencil =
  abstract_clear color depth stencil


module Data = struct

  type ('a, 'b) t = ('a, 'b, c_layout) Array1.t

  type ft = (float, float32_elt) t

  type it = (int32, int32_elt) t

  let create n k = Array1.create k c_layout n 

  let create_float n = create n Float32 

  let of_array k a = Array1.of_array k c_layout a

  let of_float_array a = Array1.of_array Float32 c_layout a

  let size : type a b. (a, b, c_layout) Array1.t -> int = 
    fun t -> 
    let n = Array1.dim t in
    let s = 
      if max_int / 2 <= 1000000000 then 4
      else 8
    in
    match Array1.kind t with
    | Float32       -> n * 4
    | Float64       -> n * 8
    | Int8_signed   -> n
    | Int8_unsigned -> n
    | Int16_signed  -> n * 2
    | Int16_unsigned-> n * 2
    | Int32         -> n * 4
    | Int64         -> n * 8
    | Int           -> n * s
    | Nativeint     -> n * s
    | Complex32     -> n * 4
    | Complex64     -> n * 8
    | Char          -> n

end


module VBO = struct

  type t

  (* Abstract functions *)
  external abstract_set : ('a, 'b) Data.t -> int -> unit = "caml_gl_buffer_data"

  (* Exposed functions *)
  external create : unit -> t = "caml_gl_gen_buffers"

  external bind : t option -> unit = "caml_gl_bind_buffer"
  
  external delete : t -> unit = "caml_gl_delete_buffer"

  let set t d = 
    bind (Some t);
    abstract_set d (Data.size d);
    bind None

  let build d = 
    let buf = create () in
    set buf d; buf

end


module EBO = struct

  type t

  (* Abstract functions *)
  external abstract_set : ('a, 'b) Data.t -> int -> unit = "caml_gl_element_buffer_data"

  (* Exposed functions *)
  external create : unit -> t = "caml_gl_gen_buffers"

  external bind : t option -> unit = "caml_gl_bind_element_buffer"
  
  external delete : t -> unit = "caml_gl_delete_buffer"

  let set t d = 
    bind (Some t);
    abstract_set d (Data.size d);
    bind None

  let build d = 
    let buf = create () in
    set buf d; buf

end


module VAO = struct

  type t

  type types =
    | Byte
    | UByte
    | Short
    | UShort
    | Int
    | UInt
    | Float
    | Double

  type shape = 
    | Points
    | LineStrip
    | LineLoop
    | Lines
    | LineStripAdjacency
    | LinesAdjacency
    | TriangleStrip
    | TriangleFan
    | Triangles
    | TriangleStripAdjacency
    | TrianglesAdjacency
    | Patches

  (* Abstract functions *)
  external attrib_pointer 
    : Program.attribute -> int -> types -> bool -> (int * int) -> unit 
    = "caml_gl_vertex_attrib_pointer"

  external attrib_i_pointer 
    : Program.attribute -> int -> types -> (int * int) -> unit 
    = "caml_gl_vertex_attrib_ipointer"

  external attrib_divisor
    : Program.attribute -> int -> unit
    = "caml_gl_vertex_attrib_divisor"


  (* Exposed functions *)
  external create : unit -> t = "caml_gl_gen_vertex_array"

  external bind : t option -> unit = "caml_gl_bind_vertex_array"

  external delete : t -> unit = "caml_gl_delete_vertex_array"

  external enable_attrib : Program.attribute -> unit = "caml_gl_enable_vaa"

  external draw : shape -> int -> int -> unit = "caml_gl_draw_arrays"

  let set_attrib ?normalize:(normalize = false) ?integer:(integer = false)
    ?stride:(stride = 0) ?divisor:(divisor = 0) ~attribute
    ~size ~kind ~offset () =
    if integer && kind <> Float && kind <> Double then 
      attrib_i_pointer attribute size kind (stride,offset)
    else 
      attrib_pointer attribute size kind normalize (stride,offset);
    attrib_divisor attribute divisor

end 


