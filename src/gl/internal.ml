
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
