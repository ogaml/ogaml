open Bigarray

module Data = struct

  type ('a, 'b) t = ('a, 'b, c_layout) Array1.t

  let create n k = Array1.create k c_layout n 

  let create_float n = create n Float32 

  let create_int n = create n Int32

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

end




