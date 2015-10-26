
module type ShaderType = sig

  type t

  val create : unit -> t

  val source : string -> t -> unit

  val compile : t -> unit

end


module Make (M : ShaderType) = struct

  type t = M.t

  (* Exposed functions *)
  let create arg = 
    let sh = M.create () in
    match arg with
    |`File s -> sh
    |`String s -> sh

end


module Fragment = struct

  type t

  external create : unit -> t = "caml_gl_create_fragment_shader"

  external source : string -> t -> unit = "caml_gl_source_shader"

  external compile : t -> unit = "caml_gl_compile_shader"

end


module Vertex = struct

  type t

  external create : unit -> t = "caml_gl_create_fragment_shader"

  external source : string -> t -> unit = "caml_gl_source_shader"

  external compile : t -> unit = "caml_gl_compile_shader"

end


module FragmentShader = Make (Fragment)


module VertexShader = Make (Vertex)


