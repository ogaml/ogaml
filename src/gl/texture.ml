
type t


(* Abstract functions *)

external abstract_create_texture : string -> int -> int -> t 
  = "caml_gl_create_texture"


(* Exposed functions *)

external bind : t option -> unit = "caml_gl_bind_texture"

external activate : int -> unit = "caml_gl_active_texture"

external delete : t -> unit = "caml_gl_delete_texture"

let create = function
  | `File s -> 
    let img = Image.create (`File s) in
    let x,y = Image.size img in
    abstract_create_texture (Image.data img) x y
  | `Image img ->
    let x,y = Image.size img in
    abstract_create_texture (Image.data img) x y

