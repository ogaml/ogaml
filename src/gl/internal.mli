(** Provides unsafe access to the internal openGL state.        
  *
  * All functions in this module modify the GL context 
  * without further verification.
  *
  * Any call to one of these functions should be followed
  * by an update of the current window's State.t
  *
  * NOTE : For internal use only, may cause bugs 
**)

(** Represents an openGL texture *)
module Texture : sig

  (** Abstract texture type *)
  type t

  (** Creates an empty texture *)
  val create : unit -> t

  (** Activates a texture binding point *)
  val activate : int -> unit

  (** Binds a texture to the current point with a given format *)
  val bind : Enum.TextureTarget.t -> t option -> unit

  (** Associates an image with the currently bound texture *)
  val image : Enum.TextureTarget.t -> Enum.PixelFormat.t -> (int * int) 
    -> Enum.TextureFormat.t -> Bytes.t -> unit

  (** Sets the value of a parameter of the currently bound texture2D *)
  val parameter2D : [`Magnify of Enum.MagnifyFilter.t 
                    |`Minify  of Enum.MinifyFilter.t] -> unit

  (** Deletes a texture from the memory *)
  val destroy : t -> unit

end

