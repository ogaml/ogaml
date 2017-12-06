(** 2D and 3D rendering, provides high-level and type-safe wrappers
  * around openGL functions *)

(** Color manipulation and creation *)
module Color : sig

  (** This module provides an easy way to manipulate colors with
    * different formats and to convert between them. *)

  (** Manipulation of RGBA colors *)
  module RGB : sig

    (** Type of a color in RGBA format *)
    type t = {r : float; g : float; b : float; a : float}

    (** Fast way to create an RGB color (alpha defaults to 1) *)
    val make : ?alpha:float -> float -> float -> float -> t

    (** Opaque black *)
    val black : t

    (** Opaque white *)
    val white : t

    (** Opaque red *)
    val red : t

    (** Opaque green *)
    val green : t

    (** Opaque blue *)
    val blue : t

    (** Opaque yellow *)
    val yellow : t

    (** Opaque magenta *)
    val magenta : t

    (** Opaque cyan *)
    val cyan : t

    (** Transparent black *)
    val transparent : t

    (** Clamps all the values of a color between 0 and 1 *)
    val clamp : t -> t

    (** Maps each value of a color *)
    val map : t -> (float -> float) -> t

    (** Pretty-prints a color to a string *)
    val print : t -> string

  end

  (** Manipulation of HSVA colors *)
  module HSV : sig

    (** Type of a color in HSVA format *)
    type t = {h : float; s : float; v : float; a : float}

    (** Fast way to create an HSV color (alpha defaults to 1) *)
    val make : ?alpha:float -> float -> float -> float -> t

    (** Opaque black *)
    val black : t

    (** Opaque white *)
    val white : t

    (** Opaque red *)
    val red : t

    (** Opaque green *)
    val green : t

    (** Opaque blue *)
    val blue : t

    (** Opaque yellow *)
    val yellow : t

    (** Opaque magenta *)
    val magenta : t

    (** Opaque cyan *)
    val cyan : t

    (** Transparent black *)
    val transparent : t

    (** Clamps the s,v,a values of a color between 0 and 1,
      * and h between 0 and 2*pi *)
    val clamp : t -> t

    (** Pretty-prints a color to a string *)
    val print : t -> string

  end


  (** Polymorphic variant representing both color formats
    * @see:OgamlGraphics.Color.HSV
    * @see:OgamlGraphics.Color.RGB *)
  type t = [`HSV of HSV.t | `RGB of RGB.t]

  (** Converts a color from RGB to HSV
    * @see:OgamlGraphics.Color.HSV
    * @see:OgamlGraphics.Color.RGB *)
  val rgb_to_hsv : RGB.t -> HSV.t

  (** Converts a color from HSV to RGB
    * @see:OgamlGraphics.Color.HSV
    * @see:OgamlGraphics.Color.RGB *)
  val hsv_to_rgb : HSV.t -> RGB.t

  (** Converts a color to HSV
    * @see:OgamlGraphics.Color.HSV *)
  val to_hsv : t -> HSV.t

  (** Converts a color to RGB
    * @see:OgamlGraphics.Color.RGB *)
  val to_rgb : t -> RGB.t

  (** Fast way to create a HSV color
    * @see:OgamlGraphics.Color.HSV *)
  val hsv : ?alpha:float -> float -> float -> float -> t

  (** Fast way to create a RGB color
    * @see:OgamlGraphics.Color.RGB *)
  val rgb : ?alpha:float -> float -> float -> float -> t

  (** Returns the alpha value of a color *)
  val alpha : t -> float

  (** Clamps a color w.r.t RGB.clamp and HSV.clamp *)
  val clamp : t -> t

  (** Maps each value of a color (assumed in RGB format) *)
  val map : t -> (float -> float) -> t

  (** Pretty-prints a color to a string *)
  val print : t -> string

end


(** Draw modes enumeration *)
module DrawMode : sig
  (** This module consists of only one type enumerating OpenGL draw modes *)

  (** OpenGL draw modes *)
  type t =
    | TriangleStrip
    | TriangleFan
    | Triangles
    | Lines

end


(** Encapsulates draw parameters used for rendering *)
module DrawParameter : sig

  (** This module encapsulates the data passed to the GPU when rendering.
    * State changes are optimized such that calling a rendering primitive
    * with the same parameters twice does not induce a state change. *)

  (** Type of a set of draw parameters *)
  type t

  (** Culling modes enumeration *)
  module CullingMode : sig
    (** This module consists of only one type enumerating OpenGL culling modes *)

    (** Backface culling modes *)
    type t =
      | CullNone (* Culls no face (default) *)
      | CullClockwise (* Culls all faces displayed in CW order from the camera POV *)
      | CullCounterClockwise (* Same with CCW *)

  end

  (** Polygon modes enumeration *)
  module PolygonMode : sig

    (** This module consists of only one type enumerating OpenGL polygon modes *)

    (** Polygon drawing modes *)
    type t =
      | DrawVertices (* Draws only vertices *)
      | DrawLines (* Draws only lines *)
      | DrawFill (* Draws full polygons (default) *)

  end

  (** Viewports enumeration *)
  module Viewport : sig

    (** This module consists of only one type enumerating different ways of
      * providing a viewport *)

    (** Type of a viewport *)
    type t =
      | Full (* Full window viewport (default) *)
      | Relative of OgamlMath.FloatRect.t (* Viewport given as a fraction of the window's size *)
      | Absolute of OgamlMath.IntRect.t (* Viewport given in pixels *)

  end

  (** Blending modes manipulation *)
  module BlendMode : sig

    (** Blending factors enumeration *)
    module Factor : sig

      (** This module consists of only one type enumerating openGL blending factors *)

      (** Blending factors *)
      type t =
        | Zero
        | One
        | SrcColor
        | OneMinusSrcColor
        | DestColor
        | OneMinusDestColor
        | SrcAlpha
        | SrcAlphaSaturate
        | OneMinusSrcAlpha
        | DestAlpha
        | OneMinusDestAlpha
        | ConstColor
        | OneMinusConstColor
        | ConstAlpha
        | OneMinusConstAlpha

    end

    (** Blending equations enumeration *)
    module Equation : sig

      (** This module consists of only one type enumerating openGL blending equations *)

      (** Blending equations @see:OgamlGraphics.DrawParameter.BlendMode.Factor *)
      type t =
        | None (* Default equation, replaces the old color by the new one *)
        | Add of Factor.t * Factor.t
        | Sub of Factor.t * Factor.t

    end

    (** Blending mode structure. This encapsulates a color blending equation and an
      * alpha blending equation. @see:OgamlGraphics.DrawParameter.BlendMode.Equation *)
    type t = {color : Equation.t; alpha : Equation.t}

    (** Default blending mode, replaces the old color by the new one *)
    val default : t

    (** Common alpha blending mode *)
    val alpha : t

    (** Additive blending mode *)
    val additive : t

    (** Soft additive blending mode *)
    val soft_additive : t

    (** Premutliplied alpha blending mode *)
    val premultiplied_alpha : t

  end

  (** Depth testing functions enumeration *)
  module DepthTest : sig

    (** This module consists of one enumeration of openGL depth functions *)

    (** Depth testing functions *)
    type t = 
      | None (* Disables depth testing *)
      | Always (* Test always passes *)
      | Never (* Test never passes *)
      | Less (* Test passes if the incoming value is less (object is closer) than the stored value. Default function *)
      | Greater (* Test passes if the incoming value is greater *)
      | Equal (* Test passes if the incoming value is equal *)
      | LEqual (* Test passes if the incoming value is less than or equal *)
      | GEqual (* Test passes if the incoming value is greater than or equal *)
      | NEqual (* Test passes if the incoming value is different than the stored value *)

  end

  (** Creates a set of draw parameters with the following options :
    *
    * $culling$ specifies which face should be culled (defaults to $CullNone$)
    *
    * $polygon$ specifies how to render polygons (defaults to $DrawFill$)
    *
    * $depth_test$ specifies the depth function to be used when rendering vertices (defaults to $Less$)
    *
    * $depth_write$ specifies whether depth should be written to the depth buffer (defaults to $true$)
    *
    * $blend_mode$ specifies the blending equation (defaults to $BlendingMode.default$)
    *
    * $viewport$ specifies the viewport (defaults to $Full$)
    *
    * $antialiasing$ specifies whether to activate AA or not (ignored if AA is not supported by the context, defaults to $true$)
    *
    * @see:OgamlGraphics.DrawParameter.CullingMode
    * @see:OgamlGraphics.DrawParameter.PolygonMode
    * @see:OgamlGraphics.DrawParameter.Viewport
    * @see:OgamlGraphics.DrawParameter.BlendMode *)
  val make : ?culling:CullingMode.t ->
             ?polygon:PolygonMode.t ->
             ?depth_test:DepthTest.t ->
             ?depth_write:bool ->
             ?blend_mode:BlendMode.t ->
             ?viewport:Viewport.t ->
             ?antialiasing:bool ->
             unit -> t

end


(** Encapsulates data about an OpenGL internal context *)
module Context : sig

  (** This module encapsulates a copy of the internal GL context.
    * This allows efficient optimizations of state changes.
    *
    * To get an instance of a Context.t, create a GL context (via a window) and
    * use Window.context *)

  (** Rendering capabilities of a context *)
  type capabilities = {
    max_3D_texture_size       : int; (* Maximal 3D texture size *)
    max_array_texture_layers  : int; (* Maximal number of layers in a texture array *)
    max_color_texture_samples : int; (* Maximal number of samples in a multisampled color texture *)
    max_cube_map_texture_size : int; (* Maximal cubemap texture size *)
    max_depth_texture_samples : int; (* Maximal number of samples in a multisampled depth texture *)
    max_elements_indices      : int; (* Maximal number of indices in an element buffer *)
    max_elements_vertices     : int; (* Maximal number of vertices in an element buffer *)
    max_integer_samples       : int; (* Maximal number of samples in a multisampled integer texture *)
    max_renderbuffer_size     : int; (* Maximal size of a renderbuffer *)
    max_texture_buffer_size   : int; (* Maximal size of a texture buffer *)
    max_texture_image_units   : int; (* Number of available texture units *)
    max_texture_size          : int; (* Maximal size of a texture *)
    max_color_attachments     : int; (* Maximal number of color attachments in a framebuffer *)
    max_draw_buffers          : int; (* Maximal number of draw buffers *)
  }

  (** Type of a GL context *)
  type t

  (** Returns the rendering capabilities of a context *)
  val capabilities : t -> capabilities

  (** Returns the GL version supported by this context in (major, minor) format *)
  val version : t -> (int * int)

  (** Returns true iff the given GL version in (major, minor) format
    * is supported by the given context *)
  val is_version_supported : t -> (int * int) -> bool

  (** Returns the GLSL version supported by this context *)
  val glsl_version : t -> int

  (** Returns true iff the given GLSL version is supported by this context *)
  val is_glsl_version_supported : t -> int -> bool

  (** Checks that no openGL error occurred internally. Used for debugging and testing. *)
  val check_errors : t -> 
    (unit, [> `Invalid_value | `Invalid_enum | `Invalid_op | `Invalid_fbop
            | `Out_of_memory | `Stack_overflow | `Stack_underflow]) result

  (** Flushes the GL buffer *)
  val flush : t -> unit

  (** Finishes all pending actions *)
  val finish : t -> unit

end


(** Render target specification *)
module RenderTarget : sig

  (** This module contains the common signature for all valid render targets.
    * This includes the module Window and all the submodules of RenderTexture. *)

  (** Signature of a valid render target module *)
  module type T = sig

    (** Module encapsulating the enumeration of the output buffers 
      * of a render target *)
    module OutputBuffer : sig
 
      (** Enumeration of the output buffers of a render target *)
      type t
  
    end

    (** Type of a render target *)
    type t

    (** Returns the size of a render target *)
    val size : t -> OgamlMath.Vector2i.t

    (** Returns the internal context associated to a render target *)
    val context : t -> Context.t

    (** Clears a render target *)
    val clear : ?buffers:OutputBuffer.t list -> ?color:Color.t option -> ?depth:bool -> ?stencil:bool -> t -> unit

    (** Binds a render target for drawing. System-only function, usually done
      * automatically. *)
    val bind : t -> ?buffers:OutputBuffer.t list -> DrawParameter.t -> unit

  end

end


(** Framebuffer attachments *)
module Attachment : sig

  (** This module contains the common interfaces 
    * shared by textures or renderbuffers that can be attached
    * to a certain attachment of an FBO *)

  (** Represents a color attachment *)
  module ColorAttachment : sig

    (** Contains only the abstract type of a color attachment *)

    (** Abstract type of a color attachment *)
    type t 

  end

  (** Represents a depth attachment *)
  module DepthAttachment : sig

    (** Contains only the abstract type of a depth attachment *)

    (** Abstract type of a depth attachment *)
    type t

  end

  (** Represents a stencil attachment *)
  module StencilAttachment : sig

    (** Contains only the abstract type of a stencil attachment *)

    (** Abstract type of a stencil attachment *)
    type t

  end

  (** Represents a depth-stencil attachment *)
  module DepthStencilAttachment : sig

    (** Contains only the abstract type of a depth-stencil attachment *)

    (** Abstract type of a depth-stencil attachment *)
    type t

  end

  (** Interface of a color-attachable texture or RBO *)
  module type ColorAttachable = sig

    type t

    val to_color_attachment : t -> ColorAttachment.t

    val size : t -> OgamlMath.Vector2i.t

  end

  (** Interface of a depth-attachable texture or RBO *)
  module type DepthAttachable = sig

    type t 

    val to_depth_attachment : t -> DepthAttachment.t

    val size : t -> OgamlMath.Vector2i.t

  end

  (** Interface of a stencil-attachable texture or RBO *)
  module type StencilAttachable = sig

    type t

    val to_stencil_attachment : t -> StencilAttachment.t

    val size : t -> OgamlMath.Vector2i.t

  end

  (** Interface of a depth-stencil-attachable texture or RBO *)
  module type DepthStencilAttachable = sig

    type t

    val to_depthstencil_attachment : t -> DepthStencilAttachment.t

    val size : t -> OgamlMath.Vector2i.t

  end

end


(** Renderbuffer creation and manipulation *)
module Renderbuffer : sig

  (** This module provides several implementations of Renderbuffer Objects (RBO)
    * that can be attached to framebuffer objects. *)

  (** Raised if an error occurs while manipulating a renderbuffer. *)
  exception RBO_Error of string

  (** Color Renderbuffer *)
  module ColorBuffer : sig

    (** Type of a color renderbuffer *)
    type t

    (** Creates a color renderbuffer from a context and a size 
      * Raises $RBO_Error$ if the requested size exceeds the maximum size
      * allowed by the context. *)
    val create : (module RenderTarget.T with type t = 'a) -> 'a -> OgamlMath.Vector2i.t -> t

    (** ColorBuffer implements the interface ColorAttachable *)
    val to_color_attachment : t -> Attachment.ColorAttachment.t

    (** Returns the size of a renderbuffer *)
    val size : t -> OgamlMath.Vector2i.t

  end


  (** Depth Renderbuffer *)
  module DepthBuffer : sig

    (** Type of a depth renderbuffer *)
    type t

    (** Creates a depth renderbuffer from a context and a size
      * Raises $RBO_Error$ if the requested size exceeds the maximum size
      * allowed by the context. *)
    val create : (module RenderTarget.T with type t = 'a) -> 'a -> OgamlMath.Vector2i.t -> t

    (** DepthBuffer implements the interface DepthAttachable *)
    val to_depth_attachment : t -> Attachment.DepthAttachment.t

    (** Returns the size of a renderbuffer *)
    val size : t -> OgamlMath.Vector2i.t

  end


  (** Stencil Renderbuffer *)
  module StencilBuffer : sig

    (** Type of a stencil renderbuffer *)
    type t

    (** Creates a stencil renderbuffer from a context and a size 
      * Raises $RBO_Error$ if the requested size exceeds the maximum size
      * allowed by the context. *)
    val create : (module RenderTarget.T with type t = 'a) -> 'a -> OgamlMath.Vector2i.t -> t

    (** StencilBuffer implements the interface StencilAttachable *)
    val to_stencil_attachment : t -> Attachment.StencilAttachment.t

    (** Returns the size of a renderbuffer *)
    val size : t -> OgamlMath.Vector2i.t

  end


  (** Depth and Stencil Renderbuffer *)
  module DepthStencilBuffer : sig

    (** Type of a depth stencil renderbuffer *)
    type t

    (** Creates a depth stencil renderbuffer from a context and a size 
      * Raises $RBO_Error$ if the requested size exceeds the maximum size
      * allowed by the context. *)
    val create : (module RenderTarget.T with type t = 'a) -> 'a -> OgamlMath.Vector2i.t -> t

    (** DepthStencilBuffer implements the interface DepthStencilAttachable *)
    val to_depth_stencil_attachment : t -> Attachment.DepthStencilAttachment.t

    (** Returns the size of a renderbuffer *)
    val size : t -> OgamlMath.Vector2i.t

  end

end


(** Framebuffer creation and manipulation *)
module Framebuffer : sig

  (** This module provides a safe way to create framebuffer objects (FBO) and 
    * attach textures to them. *)

  (** Type of a framebuffer object *)
  type t

  (** Module encapsulating an enumeration of the output buffers of a framebuffer *)
  module OutputBuffer : sig

    (** Enumeration of the output buffers of a framebuffer *)
    type t = 
      | Color of int
      | None

  end

  (** Creates a framebuffer from a valid context *)
  val create : (module RenderTarget.T with type t = 'a) -> 'a -> t

  (** Attaches a valid color attachment to a framebuffer at a given index.
    * Returns an error if the index is greater than the maximum number of color
    * attachments allowed by the context, or if the attachment is larger
    * than the maximum size allowed by the context.
    *
    * @see:OgamlGraphics.Attachment.ColorAttachable
    * @see:OgamlGraphics.Context *)
  val attach_color : (module Attachment.ColorAttachable with type t = 'a) 
                      -> t -> int -> 'a ->
                      (unit, [> `Attachment_too_large | `Too_many_color_attachments]) result

  (** Attaches a valid depth attachment to a framebuffer.
    * Returns an error if the attachment is larger than the maximum size 
    * allowed by the context.
    *
    * @see:OgamlGraphics.Attachment.DepthAttachable
    * @see:OgamlGraphics.Context *)
  val attach_depth : (module Attachment.DepthAttachable with type t = 'a)
                      -> t -> 'a -> (unit, [> `Attachment_too_large]) result

  (** Attaches a valid stencil attachment to a framebuffer.
    * Returns an error if the attachment is larger than the maximum size 
    * allowed by the context.
    *
    * @see:OgamlGraphics.Attachment.StencilAttachable
    * @see:OgamlGraphics.Context *)
  val attach_stencil : (module Attachment.StencilAttachable with type t = 'a)
                      -> t -> 'a -> (unit, [> `Attachment_too_large]) result

  (** Attaches a valid depth and stencil attachment to a framebuffer.
    * Returns an error if the attachment is larger than the maximum size 
    * allowed by the context.
    *
    * @see:OgamlGraphics.Attachment.DepthStencilAttachable
    * @see:OgamlGraphics.Context *)
  val attach_depthstencil : (module Attachment.DepthStencilAttachable with type t = 'a)
                            -> t -> 'a -> (unit, [> `Attachment_too_large]) result

  (** Returns true iff the FBO has a color attachment *)
  val has_color : t -> bool

  (** Returns true iff the FBO has a depth attachment *)
  val has_depth : t -> bool

  (** Returns true iff the FBO has a stencil attachment *)
  val has_stencil : t -> bool

  (** Returns the size of an FBO, that is the intersection of the sizes of 
    * its attachments.
    * Returns the maximal allowed size if nothing has been attached to this FBO *)
  val size : t -> OgamlMath.Vector2i.t

  (** Returns the GL context associated to the FBO *) 
  val context : t -> Context.t

  (** Clears the FBO 
    * 
    * $buffers$ defaults to $[Color 0]$ *)
  val clear : ?buffers:OutputBuffer.t list -> ?color:Color.t option -> 
              ?depth:bool -> ?stencil:bool -> t -> 
              (unit, [> `Duplicate_color_buffer | `Invalid_color_buffer | `Too_many_draw_buffers]) result

  (** Binds the FBO for drawing. Internal use only. *)
  val bind : t -> ?buffers:OutputBuffer.t list -> DrawParameter.t -> 
             (unit, [> `Duplicate_color_buffer | `Invalid_color_buffer | `Too_many_draw_buffers]) result

end



(** Image manipulation and creation *)
module Image : sig

  (** This module provides a safe way to load and access images stored in the RAM.
    * Images stored this way are uncompressed arrays of bytes and are therefore
    * not meant to be stored in large quantities. *)

  (** Type of an image stored in the RAM *)
  type t

  (** Creates an empty image filled with a default color *)
  val empty : OgamlMath.Vector2i.t -> Color.t -> t

  (** Loads an image from a file *)
  val load : string -> (t, [> `File_not_found | `Loading_error of string]) result

  (** Creates an image from a file, some RGBA-formatted data, or an empty one
    * filled with a default color
    *
    * @see:OgamlGraphics.Color *)
  val create : [`File of string 
               | `Empty of OgamlMath.Vector2i.t * Color.t 
               | `Data of OgamlMath.Vector2i.t * Bytes.t] -> 
               (t, [> `File_not_found
                    | `Loading_error of string
                    | `Wrong_data_length]) result

  (** Saves an image to a file.
    *
    * Warning: PNG format only ! *)
  val save : t -> string -> unit

  (** Return the size of an image *)
  val size : t -> OgamlMath.Vector2i.t

  (** Sets a pixel of an image
    * @see:OgamlGraphics.Color *)
  val set : t -> OgamlMath.Vector2i.t -> Color.t -> (unit, [> `Out_of_bounds]) result

  (** Gets the color of a pixel of an image
    * @see:OgamlGraphics.Color.RGB *)
  val get : t -> OgamlMath.Vector2i.t -> (Color.RGB.t, [> `Out_of_bounds]) result

  (** $blit src ~rect dest offset$ blits the subimage of $src$ defined by $rect$
    * on the image $dest$ at position $offset$ (relative to the top-left pixel).
    *
    * If $rect$ is not provided then the whole image $src$ is used.
    * @see:OgamlMath.IntRect @see:OgamlMath.Vector2i *)
  val blit : t -> ?rect:OgamlMath.IntRect.t -> t -> OgamlMath.Vector2i.t ->
             (unit, [> `Out_of_bounds]) result

  (** $mipmap img lvl$ returns a new, fresh image that is the $lvl$-th reduction 
    * of the image $img$ *)
  val mipmap : t -> int -> t

  (** $pad img offset color size$ returns a new image of size $size$, which 
    * contains $img$ placed at position $offset$, and where the empty pixels
    * are filled with $color$ *)
  val pad : t -> ?offset:OgamlMath.Vector2i.t -> ?color:Color.t -> 
                 OgamlMath.Vector2i.t -> t

end


(** High-level wrapper around GL textures *)
module Texture : sig

  (** This module provides wrappers around different kinds
    * of OpenGL textures *)

  (** Common signature for all texture types *)
  module type T = sig

    (** Type of a texture *)
    type t

    (** System only function, binds a texture to a texture unit for drawing *)
    val bind : t -> int -> unit

  end

  (** Module containing an enumeration of the minifying filters *)
  module MinifyFilter : sig

    (** Enumeration of the minifying filters *)
    type t = 
      | Nearest
      | Linear
      | NearestMipmapNearest
      | LinearMipmapNearest
      | NearestMipmapLinear
      | LinearMipmapLinear

  end

  (** Module containing an enumeration of the magnifying filters *)
  module MagnifyFilter : sig

    (** Enumeration of the magnifying filters *)
    type t = 
      | Nearest
      | Linear

  end

  (** Module containing an enumeration of the wrapping functions *)
  module WrapFunction : sig

    (** Enumeration of the wrapping functions *)
    type t = 
      | ClampEdge
      | ClampBorder
      | MirrorRepeat
      | Repeat
      | MirrorClamp

  end


  (** Module containing an enumeration of the depth texture formats *)
  module DepthFormat : sig
 
    (** Enumeration of the depth texture formats *)
    type t = 
      | Int16
      | Int24
      | Int32
  
  end


  (** Represents a mipmap level of a 2D texture *)
  module Texture2DMipmap : sig

    (** Type of a 2D mipmap level *)
    type t

    (** Size of the mipmap level @see:OgamlMath.Vector2i *)
    val size : t -> OgamlMath.Vector2i.t

    (** Writes an image to a sub-rectangle of a mipmap level.
      * Writes to the full mipmap level by default. 
      * @see:OgamlMath.IntRect
      * @see:OgamlGraphics.Image *)
    val write : t -> ?rect:OgamlMath.IntRect.t -> Image.t -> unit

    (** Returns the level of a Texture2DMipmap.t *)
    val level : t -> int
 
    (** System only function, binds the original texture of the mipmap *)
    val bind : t -> int -> unit 

    (** Texture2DMipmap implements the interface ColorAttachable and
      * can be attached to an FBO.
      * @see:OgamlGraphics.Attachment.ColorAttachment *)
    val to_color_attachment : t -> Attachment.ColorAttachment.t

  end


  (** Represents a simple 2D texture *)
  module Texture2D : sig

    (** This module provides an abstraction of OpenGL 2D textures
      * that can be used for 2D rendering (with sprites) or
      * 3D rendering when passed to a GLSL program. *)

    (** Type of a 2D texture *)
    type t

    (** Creates a texture from a source (a file or an image), or an empty texture.
      * Generates all mipmaps by default.
      *
      * @see:OgamlGraphics.RenderTarget.T 
      * @see:OgamlMath.Vector2i 
      * @see:OgamlGraphics.Context *)
    val create : (module RenderTarget.T with type t = 'a) -> 'a -> 
                 ?mipmaps:[`AllEmpty | `Empty of int | `AllGenerated | `Generated of int | `None] ->
                 [< `File of string | `Image of Image.t | `Empty of OgamlMath.Vector2i.t] -> 
                 (t, [> `Texture_too_large]) result

    (** Returns the size of a texture 
      * @see:OgamlMath.Vector2i *)
    val size : t -> OgamlMath.Vector2i.t

    (** Sets the minifying filter of a texture. Defaults as LinearMipmapLinear. *)
    val minify : t -> MinifyFilter.t -> unit

    (** Sets the magnifying filter of a texture. Defaults as Linear *)
    val magnify : t -> MagnifyFilter.t -> unit

    (** Sets the wrapping function of a texture. Defaults as ClampEdge.  *)
    val wrap : t -> WrapFunction.t -> unit
    
    (** Returns the number of mipmap levels of a texture *)
    val mipmap_levels : t -> int

    (** Returns a mipmap level of a texture. *)
    val mipmap : t -> int -> (Texture2DMipmap.t, [> `Invalid_mipmap]) result

    (** System only function, binds a texture to a texture unit for drawing *)
    val bind : t -> int -> unit

    (** Texture2D implements the interface ColorAttachable and can be attached
      * to an FBO. Binds the mipmap level 0. *)
    val to_color_attachment : t -> Attachment.ColorAttachment.t

  end


  (** Represents a mipmap level of a 2D depth texture *)
  module DepthTexture2DMipmap : sig

    (** Type of a 2D mipmap level *)
    type t

    (** Size of the mipmap level @see:OgamlMath.Vector2i *)
    val size : t -> OgamlMath.Vector2i.t

    (** Writes an image to a sub-rectangle of a mipmap level.
      * Writes to the full mipmap level by default. 
      * @see:OgamlMath.IntRect
      * @see:OgamlGraphics.Image *)
    val write : t -> ?rect:OgamlMath.IntRect.t -> Image.t -> unit

    (** Returns the level of a DepthTexture2DMipmap.t *)
    val level : t -> int
 
    (** System only function, binds the original texture of the mipmap *)
    val bind : t -> int -> unit 

    (** DepthTexture2DMipmap implements the interface DepthAttachable and
      * can be attached to an FBO.
      * @see:OgamlGraphics.Attachment.DepthAttachment *)
    val to_depth_attachment : t -> Attachment.DepthAttachment.t

  end


  (** Represents a 2D depth texture *)
  module DepthTexture2D : sig

    (** This module provides an abstraction of OpenGL 2D depth textures
      * that can be used for 2D rendering (with sprites) or
      * 3D rendering when passed to a GLSL program. *)

    (** Type of a 2D depth texture *)
    type t

    (** Creates a texture from some data (in row-major order, starting from the
      * bottom left corner), or an empty texture.
      * Generates all mipmaps by default.
      *
      * @see:OgamlGraphics.RenderTarget.T 
      * @see:OgamlMath.Vector2i 
      * @see:OgamlGraphics.Context *)
    val create : (module RenderTarget.T with type t = 'a) -> 'a -> 
                 ?mipmaps:[`AllEmpty | `Empty of int | `AllGenerated | `Generated of int | `None] ->
                 DepthFormat.t ->
                 [< `Data of (OgamlMath.Vector2i.t * Bytes.t) | `Empty of OgamlMath.Vector2i.t] ->
                 (t, [> `Insufficient_data | `Texture_too_large]) result

    (** Returns the size of a texture 
      * @see:OgamlMath.Vector2i *)
    val size : t -> OgamlMath.Vector2i.t

    (** Sets the minifying filter of a texture. Defaults as LinearMipmapLinear. *)
    val minify : t -> MinifyFilter.t -> unit

    (** Sets the magnifying filter of a texture. Defaults as Linear *)
    val magnify : t -> MagnifyFilter.t -> unit

    (** Sets the wrapping function of a texture. Defaults as ClampEdge.  *)
    val wrap : t -> WrapFunction.t -> unit
    
    (** Returns the number of mipmap levels of a texture *)
    val mipmap_levels : t -> int

    (** Returns a mipmap level of a texture. *)
    val mipmap : t -> int -> (DepthTexture2DMipmap.t, [> `Invalid_mipmap]) result

    (** System only function, binds a texture to a texture unit for drawing *)
    val bind : t -> int -> unit

    (** DepthTexture2D implements the interface DepthAttachable and can be
      * attached to an FBO. Binds the mipmap level 0. *)
    val to_depth_attachment : t -> Attachment.DepthAttachment.t

  end

  (** Represents a layer's mipmap of a 2D texture array *)
  module Texture2DArrayLayerMipmap : sig
  
    (** This module gives an abstract representation of a mipmap level
      * of a particular layer of a texture array *)

    (** Type of a layer's mipmap *)
    type t

    (** Size of a mipmap *)
    val size : t -> OgamlMath.Vector2i.t

    (** Writes to a layer's mipmap *)
    val write : t -> OgamlMath.IntRect.t -> Image.t -> unit

    (** Returns the layer's index *)
    val layer : t -> int

    (** Returns the mipmap's level *)
    val level : t -> int

    (** System only : binds the original texture array for drawing *)
    val bind : t -> int -> unit
    
    (** Texture2DArrayLayerMipmap implements the interface ColorAttachable
      * and can be attached to an FBO *)
    val to_color_attachment : t -> Attachment.ColorAttachment.t

  end

  
  (** Represents a mipmap level of a 2D texture array *)
  module Texture2DArrayMipmap : sig

    (** This module gives an abstract representation of a mipmap level
      * of a 2D texture array (that is, a mipmap array) *)

    (** Type of a mipmap *)
    type t

    (** Size of a mipmap *)
    val size : t -> OgamlMath.Vector3i.t

    (** Number of layers in the array of mipmaps *)
    val layers : t -> int

    (** Returns the mipmap's level *)
    val level : t -> int

    (** Returns the mipmap of a particular layer *)
    val layer : t -> int -> (Texture2DArrayLayerMipmap.t, [> `Invalid_layer]) result

  end


  (** Represents a layer of a 2D texture array *)
  module Texture2DArrayLayer : sig

    (** This module gives an abstract representation of a particular layer
      * of a 2D texture array *)

    (** Type of a 2D texture array's layer *)
    type t

    (** Size of a layer *)
    val size : t -> OgamlMath.Vector2i.t

    (** Returns the layer's index *)
    val layer : t -> int

    (** Returns the number of mipmap levels of a layer *)
    val mipmap_levels : t -> int

    (** Returns a particular mipmap level of a layer *)
    val mipmap : t -> int -> (Texture2DArrayLayerMipmap.t, [> `Invalid_mipmap]) result

    (** System only : binds the original texture array for drawing *)
    val bind : t -> int -> unit

    (** Texture2DArrayLayerMipmap implements the interface ColorAttachable
      * and can be attached to an FBO. Binds the mipmap level 0. *)
    val to_color_attachment : t -> Attachment.ColorAttachment.t 

  end


  (** Represents arrays of 2D textures *)
  module Texture2DArray : sig

    (** This module provides an abstraction of OpenGL 2D texture arrays *)

    (** Type of a 2D texture array *)
    type t 

    (** Creates a texture array from a list of files, images, or empty
      * layers of given dimensions.
      * Generates all mipmaps by default for every layer by default. *)
    val create : (module RenderTarget.T with type t = 'a) -> 'a
                 -> ?mipmaps:[`AllEmpty | `Empty of int | `AllGenerated | `Generated of int | `None]
                 -> [< `File of string | `Image of Image.t | `Empty of OgamlMath.Vector2i.t] list ->
                 (t, [> `No_input_files
                      | `Non_equal_input_sizes
                      | `Texture_too_large
                      | `Texture_too_deep]) result

    (** Returns the size of a texture array *)
    val size : t -> OgamlMath.Vector3i.t

    (** Sets the minifying filter of a texture. Defaults as LinearMipmapLinear. *)
    val minify : t -> MinifyFilter.t -> unit

    (** Sets the magnifying filter of a texture. Defaults as Linear. *)
    val magnify : t -> MagnifyFilter.t -> unit

    (** Sets the wrapping function of a texture. Defaults as ClampEdge. *)
    val wrap : t -> WrapFunction.t -> unit

    (** Returns the number of layers of a texture. Equivalent to $(size tex).z$ *)
    val layers : t -> int

    (** Returns the number of mipmap levels of a texture. *)
    val mipmap_levels : t -> int

    (** Returns a particular layer of a texture array. *)
    val layer : t -> int -> (Texture2DArrayLayer.t, [> `Invalid_layer]) result

    (** Returns a particular mipmap of a texture array. *)
    val mipmap : t -> int -> (Texture2DArrayMipmap.t, [> `Invalid_mipmap]) result

  end


  (** Mipmap level of a cubemap face *)
  module CubemapMipmapFace : sig

    (** Represents a single mipmap level of a cubemap texture's face *)

    (** Type of a face's mipmap level *)
    type t

    (** Size of the mipmap *)
    val size : t -> OgamlMath.Vector2i.t

    (** Writes an image to a subrectangle of the mipmap *)
    val write : t -> OgamlMath.IntRect.t -> Image.t -> unit

    (** Returns the mipmap level of this mipmap *)
    val level : t -> int

    (** Returns the face corresponding to this face's mipmap *)
    val face : t -> [`PositiveX | `PositiveY | `PositiveZ | `NegativeX | `NegativeY | `NegativeZ] 

    (** System only : binds the original cubemap texture *)
    val bind : t -> int -> unit

    (** CubemapMipmapFace implements the interface ColorAttachable *)
    val to_color_attachment : t -> Attachment.ColorAttachment.t

  end


  (** Cubemap face *)
  module CubemapFace : sig

    (** Represents a single cubemap texture's face *)

    (** Type of a face *)
    type t

    (** Size of the texture *)
    val size : t -> OgamlMath.Vector2i.t

    (** Returns the number of mipmap levels of this texture *)
    val mipmap_levels : t -> int

    (** Returns a particular mipmap level of this face *)
    val mipmap : t -> int -> (CubemapMipmapFace.t, [> `Invalid_mipmap]) result

    (** Returns the face corresponding to this texture *)
    val face : t -> [`PositiveX | `PositiveY | `PositiveZ | `NegativeX | `NegativeY | `NegativeZ] 

    (** System only : binds the original texture for drawing *)
    val bind : t -> int -> unit

    (** CubemapFace implements the interface ColorAttachable *)
    val to_color_attachment : t -> Attachment.ColorAttachment.t

  end

  
  (** Mipmap level of a cubemap texture *)
  module CubemapMipmap : sig
    
    (** Represents a single mipmap level of a cubemap texture *)

    (** Type of a mipmap level *)
    type t

    (** Size of a face of a mipmap *)
    val size : t -> OgamlMath.Vector2i.t

    (** Returns the level associated to a mipmap *)
    val level : t -> int

    (** Returns a particular face of this mipmap *)
    val face : t -> [`PositiveX | `PositiveY | `PositiveZ | `NegativeX | `NegativeY | `NegativeZ] 
                 -> CubemapMipmapFace.t

    (** System only : binds the original texture for drawing *)
    val bind : t -> int -> unit

  end


  (** Cubemap textures *)
  module Cubemap : sig
    
    (** This module provides an abstraction of OpenGL's cubemap textures *)

    (** Cubemap texture *)
    type t

    (** Creates a cubemap texture from 6 textures, images or empty layers of
      * a given dimension.
      * Generates all mipmaps by default. *)
    val create : (module RenderTarget.T with type t = 'a) -> 'a
                 -> ?mipmaps:[`AllEmpty | `Empty of int | `AllGenerated | `Generated of int | `None]
                 -> positive_x:[< `File of string | `Image of Image.t | `Empty of OgamlMath.Vector2i.t]
                 -> positive_y:[< `File of string | `Image of Image.t | `Empty of OgamlMath.Vector2i.t]
                 -> positive_z:[< `File of string | `Image of Image.t | `Empty of OgamlMath.Vector2i.t]
                 -> negative_x:[< `File of string | `Image of Image.t | `Empty of OgamlMath.Vector2i.t]
                 -> negative_y:[< `File of string | `Image of Image.t | `Empty of OgamlMath.Vector2i.t]
                 -> negative_z:[< `File of string | `Image of Image.t | `Empty of OgamlMath.Vector2i.t]
                 -> unit ->
                 (t, [> `Texture_too_large
                      | `Non_equal_input_sizes]) result

    (** Size of a face of a cubemap texture *)
    val size : t -> OgamlMath.Vector2i.t

    (** Sets the minifying filter of a texture. Defaults as LinearMipmapLinear. *)
    val minify : t -> MinifyFilter.t -> unit

    (** Sets the magnifying filter of a texture. Defaults as Linear. *)
    val magnify : t -> MagnifyFilter.t -> unit

    (** Sets the wrapping function of a texture. Defaults as ClampEdge. *)
    val wrap : t -> WrapFunction.t -> unit

    (** Returns the number of mipmap levels of a texture *)
    val mipmap_levels : t -> int

    (** Returns a particular mipmap level of a texture *)
    val mipmap : t -> int -> (CubemapMipmap.t, [> `Invalid_mipmap]) result

    (** Returns a particular face of a texture *)
    val face : t -> [`PositiveX | `PositiveY | `PositiveZ | `NegativeX | `NegativeY | `NegativeZ] 
                 -> CubemapFace.t

    (** System only : binds the texture for drawing *)
    val bind : t -> int -> unit

  end


  (** Represents a mipmap level of a 3D texture *)
  module Texture3DMipmap : sig
  
    (** This module gives an abstract representation of a mipmap level
      * of a 3D texture *)

    (** Type of a 3D texture's mipmap *)
    type t

    (** Size of a mipmap *)
    val size : t -> OgamlMath.Vector3i.t

    (** Returns the mipmap level *)
    val level : t -> int

    (** Focuses a particular layer of the 3D texture's mipmap *)
    val layer : t -> int -> (t, [> `Invalid_layer]) result

    (** Returns the currently focused layer of the 3D texture's mipmap *)
    val current_layer : t -> int

    (** Writes to the currently focused layer of the mipmap *)
    val write : t -> OgamlMath.IntRect.t -> Image.t -> unit

    (** System only : binds the original 3D texture for drawing *)
    val bind : t -> int -> unit
    
    (** Texture3DMipmap implements the interface ColorAttachable
      * and the focused layer can be attached to an FBO *)
    val to_color_attachment : t -> Attachment.ColorAttachment.t

  end


  (** Represents 3D textures *)
  module Texture3D : sig

    (** This module provides an abstraction of OpenGL 3D textures *)

    (** Type of a 3D texture *)
    type t 

    (** Creates a 3D texture from a list of files, images, or empty
      * layers of given dimensions.
      * Generates all mipmaps by default. *)
    val create : (module RenderTarget.T with type t = 'a) -> 'a
                 -> ?mipmaps:[`AllEmpty | `Empty of int | `AllGenerated | `Generated of int | `None]
                 -> [< `File of string | `Image of Image.t | `Empty of OgamlMath.Vector2i.t] list ->
                 (t, [> `Texture_too_large
                      | `Non_equal_input_sizes
                      | `No_input_files]) result

    (** Returns the size of a 3D texture *)
    val size : t -> OgamlMath.Vector3i.t

    (** Sets the minifying filter of a texture. Defaults as LinearMipmapLinear. *)
    val minify : t -> MinifyFilter.t -> unit

    (** Sets the magnifying filter of a texture. Defaults as Linear. *)
    val magnify : t -> MagnifyFilter.t -> unit

    (** Sets the wrapping function of a texture. Defaults as ClampEdge. *)
    val wrap : t -> WrapFunction.t -> unit

    (** Returns the number of mipmap levels of a texture. *)
    val mipmap_levels : t -> int

    (** Returns a particular mipmap of a 3D texture. *)
    val mipmap : t -> int -> (Texture3DMipmap.t, [> `Invalid_mipmap]) result

  end

end


(** Information about a font *)
module Font : sig

  (** Representation of a character *)
  module Glyph : sig

    (** This module encapsulates the data associated to a character's glyph.
      *
      * All coordinates are given relatively to the
      * glyph's origin, and with an up-increasing Y coordinate *)

    (** Type of a glyph *)
    type t

    (** Space between the origin of this glyph and the origin of the next glyph *)
    val advance : t -> float

    (** Returns the offset between the origin and the top-left corner of the glyph *)
    val bearing : t -> OgamlMath.Vector2f.t

    (** Returns the bouding rectangle of the glyph
      * relatively to the origin *)
    val rect : t -> OgamlMath.FloatRect.t

  end


  (** This module stores a font and dynamically
    * loads sizes and glyphs as requested by the user *)

  (** Type of a font *)
  type t

  (** Type alias for a character given in ASCII or UTF-8 *)
  type code = [`Char of char | `Code of int]

  (** Loads a font from a file *)
  val load : string -> (t, [> `File_not_found | `Invalid_font_file]) result

  (** $glyph font code size bold$ returns the glyph
    * representing the character $code$ in $font$
    * of size $size$ and with the modifier $bold$ *)
  val glyph : t -> code -> int -> bool -> Glyph.t

  (** Returns the kerning between two chars of
    * a given size, that is the horizontal offset
    * that must be applied between the two glyphs
    * (usually negative) *)
  val kerning : t -> code -> code -> int -> float

  (** Returns the coordinate above the baseline the font extends *)
  val ascent : t -> int -> float

  (** Returns the coordinate below the baseline the font
    * extends (usually negative) *)
  val descent : t -> int -> float

  (** Returns the distance between the descent of a line
    * and the ascent of the next line *)
  val linegap : t -> int -> float

  (** Returns the space between the baseline of two lines
    * (equals ascent + linegap - descent) *)
  val spacing : t -> int -> float

  (** Returns the texture associated to a font.
    * In this texture, every layer correspond to a font size (in loading order).
    * Use $Font.size_index$ to get the layer associated to a font size. 
    * This texture is not mipmapped. *)
  val texture : (module RenderTarget.T with type t = 'a) -> 'a -> 
                t -> 
                (Texture.Texture2DArray.t,
                  [> `Font_texture_size_overflow
                   | `Font_texture_depth_overflow]) result

  (** Returns the index associated to a font size in the font's texture. *)
  val size_index : t -> int -> (int, [> `Invalid_font_size]) result

end


(** High-level wrapper around GL shader programs *)
module Program : sig

  (** This module provides a high-level wrapper around GL shader programs
    * and can be used to compile shaders. *)

  (** Type of a program *)
  type t

  (** Type of a source, from a file or from a string *)
  type src = [`File of string | `String of string]

  (** Compiles a program from a rendering context, a vertex source 
    * and a fragment source.
    * Compilation errors will be reported on the provided log.
    * The source must begin with a version assigment $#version xxx$ 
    * @see:OgamlUtils.Log *)
  val from_source : (module RenderTarget.T with type t = 'a) -> 
    context:'a -> vertex_source:src -> fragment_source:src ->
    (t, [> `Context_failure 
         | `Vertex_compilation_error of string
         | `Fragment_compilation_error of string
         | `Linking_failure
         | `Unsupported_GLSL_type]) result

  (** Compiles a program from a rendering context and
    * a list of sources paired with their required GLSL version.
    * The function will chose the best source for the current context.
    * Compilation errors will be reported on the provided log.
    * @see:OgamlGraphics.Context
    * @see:OgamlUtils.Log *)
  val from_source_list : (module RenderTarget.T with type t = 'a) ->
    context:'a  -> vertex_source:(int * src) list -> fragment_source:(int * src) list ->
    (t, [> `Context_failure 
         | `Vertex_compilation_error of string
         | `Fragment_compilation_error of string
         | `Linking_failure
         | `Unsupported_GLSL_version
         | `Unsupported_GLSL_type]) result

  (** Compiles a program from a rendering context and a source.
    * The source should not begin with a $#version xxx$ assignment,
    * as the function will preprocess the sources and prepend the
    * best version declaration.
    * Compilation errors will be reported on the provided log.
    * @see:OgamlGraphics.Context 
    * @see:OgamlUtils.Log *)
  val from_source_pp : (module RenderTarget.T with type t = 'a) ->
    context:'a -> vertex_source:src -> fragment_source:src -> 
    (t, [> `Context_failure 
         | `Vertex_compilation_error of string
         | `Fragment_compilation_error of string
         | `Linking_failure
         | `Unsupported_GLSL_type]) result

end


(** Encapsulates a group of uniforms for rendering *)
module Uniform : sig

  (** This module encapsulates a set of uniforms that
    * can be passed to GLSL programs. *)

  (** Type of a set of uniforms *)
  type t

  (** Empty set of uniforms *)
  val empty : t

  (** $vector3f name vec set$ adds the uniform $vec$ to $set$.
    * the uniform should be refered to as $name$ in a glsl program.
    * Type : vec3.
    * @see:OgamlMath.Vector3f *)
  val vector3f : string -> OgamlMath.Vector3f.t -> t -> (t, [> `Duplicate_uniform of string]) result

  (** See vector3f. Type : vec2. @see:OgamlMath.Vector2f *)
  val vector2f : string -> OgamlMath.Vector2f.t -> t -> (t, [> `Duplicate_uniform of string]) result

  (** See vector3f. Type : vec3i. @see:OgamlMath.Vector3i *)
  val vector3i : string -> OgamlMath.Vector3i.t -> t -> (t, [> `Duplicate_uniform of string]) result

  (** See vector3f. Type : vec2i. @see:OgamlMath.Vector2i *)
  val vector2i : string -> OgamlMath.Vector2i.t -> t -> (t, [> `Duplicate_uniform of string]) result

  (** See vector3f. Type : int. *)
  val int : string -> int -> t -> (t, [> `Duplicate_uniform of string]) result

  (** See vector3f. Type : float. *)
  val float : string -> float -> t -> (t, [> `Duplicate_uniform of string]) result

  (** See vector3f. Type : mat3. @see:OgamlMath.Matrix3D *)
  val matrix3D : string -> OgamlMath.Matrix3D.t -> t -> (t, [> `Duplicate_uniform of string]) result

  (** See vector3f. Type : mat2. @see:OgamlMath.Matrix2D *)
  val matrix2D : string -> OgamlMath.Matrix2D.t -> t -> (t, [> `Duplicate_uniform of string]) result

  (** See vector3f. Type : vec4. @see:OgamlGraphics.Color *)
  val color : string -> Color.t -> t -> (t, [> `Duplicate_uniform of string]) result

  (** See vector3f. Type : sampler2D.
   *
    * The optional parameter $tex_unit$ corresponds to the texture
    * unit that is used to bind this texture. If not provided, it
    * defaults to the next available unit. If no additional units
    * are available, or if a unit is explicitly bound twice, drawing
    * with the uniform will raise $Invalid_uniform$.
    *
    * See $Context.capabilities$ for the number of available units.
    * @see:OgamlGraphics.Texture.Texture2D
    * @see:OgamlGraphics.Context *)
  val texture2D : string -> ?tex_unit:int -> Texture.Texture2D.t -> t -> 
    (t, [> `Duplicate_uniform of string]) result

  (** See texture2D. Type : sampler2D.
    *
    * @see:OgamlGraphics.Texture.Texture3D *)
  val depthtexture2D : string -> ?tex_unit:int -> Texture.DepthTexture2D.t -> t -> 
    (t, [> `Duplicate_uniform of string]) result

  (** See texture2D. Type : sampler3D.
    *
    * @see:OgamlGraphics.Texture.Texture3D *)
  val texture3D : string -> ?tex_unit:int -> Texture.Texture3D.t -> t ->
    (t, [> `Duplicate_uniform of string]) result

  (** See texture2D. Type : sampler2Darray.
    *
    * @see:OgamlGraphics.Texture.Texture2DArray *)
  val texture2Darray : string -> ?tex_unit:int -> Texture.Texture2DArray.t -> t -> 
    (t, [> `Duplicate_uniform of string]) result

  (** See texture2D. Type : samplerCube. 
    *
    * @see:OgamlGraphics.Texture.Cubemap *)
  val cubemap : string -> ?tex_unit:int -> Texture.Cubemap.t -> t -> 
    (t, [> `Duplicate_uniform of string]) result

end


(** High-level window wrapper for rendering and event management *)
module Window : sig

  (** This module provides a high-level wrapper around the low-level
    * window interface of OgamlCore and also provides drawing functions.
    *
    * Windows encapsulate a copy of the GL context that can be retrieved
    * to obtain information about the GL context. *)

  (*** Window creation *)

  (** The type of a window *)
  type t

  (** Module encapsulating an enumeration of the output buffers of a window *)
  module OutputBuffer : sig

    (** Enumeration of the output buffers of a window *)
    type t = 
      | FrontLeft
      | FrontRight
      | BackLeft
      | BackRight
      | None

  end

  (** Creates a window of size $width$ x $height$.
    * This window will create its openGL context following the specified settings.
    *
    * $width$ defaults to 800
    *
    * $height$ defaults to 600
    *
    * $title$ defaults to ""
    *
    * $settings$ defaults to the default context settings
    *
    * @see:OgamlCore.ContextSettings *)
  val create :
    ?width:int ->
    ?height:int ->
    ?title:string ->
    ?settings:OgamlCore.ContextSettings.t -> unit -> 
    (t, [> `Window_creation_error of string
         | `Context_initialization_error of string]) result

  (** Returns the settings used at the creation of the window *)
  val settings : t -> OgamlCore.ContextSettings.t

  (** Returns the internal GL context of the window
    * @see:OgamlGraphics.Context *)
  val context : t -> Context.t

  (** Changes the title of the window. *)
  val set_title : t -> string -> unit

  (** Sets a framerate limit *)
  val set_framerate_limit : t -> int option -> unit

  (** Closes a window, but does not free the memory.
    * This should prevent segfaults when calling functions on this window. *)
  val close : t -> unit

  (** Frees the window and the memory *)
  val destroy : t -> unit

  (** Resizes the window.
    * @see:OgamlMath.Vector2i *)
  val resize : t -> OgamlMath.Vector2i.t -> unit

  (** Toggles the full screen mode of a window. Returns $true$ if successful. *)
  val toggle_fullscreen : t -> bool

  (** Returns the rectangle associated to a window, in screen coordinates
    * @see:OgamlMath.IntRect *)
  val rect : t -> OgamlMath.IntRect.t

  (*** Information About Windows *)
  (** Returns in pixel the width and height of the window
    * (it only takes into account the size of the content where you can draw, *ie* the useful information).
    * @see:OgamlMath.Vector2i *)
  val size : t -> OgamlMath.Vector2i.t

  (** Tells whether the window is currently open *)
  val is_open : t -> bool

  (** Return true iff the window has the focus *)
  val has_focus : t -> bool

  (*** Event Handling *)
  (** Returns the next event on the event stack, or None if the stack is empty.
    * @see:OgamlCore.Event *)
  val poll_event : t -> OgamlCore.Event.t option

  (*** Displaying and Drawing *)
  (** Displays the window after the GL calls *)
  val display : t -> unit

  (** Clears the window.
    * Clears the color buffer with opaque black by default. 
    * Clears the depth buffer and the stencil buffer by default. 
    *
    * $buffers$ defaults to $[BackLeft]$ *)
  val clear : ?buffers:OutputBuffer.t list -> ?color:Color.t option -> ?depth:bool -> ?stencil:bool -> t ->
              (unit, [> `Invalid_draw_buffer | `Duplicate_draw_buffer]) result

  (** Show or hide the cursor *)
  val show_cursor : t -> bool -> unit

  (** Binds the window for drawing. This function is for internal use only. *)
  val bind : t -> ?buffers:OutputBuffer.t list -> DrawParameter.t -> 
             (unit, [> `Invalid_draw_buffer | `Duplicate_draw_buffer]) result

  (** Takes a screenshot of the window *)
  val screenshot : t -> Image.t 

end


(** High-level wrapper around OpenGL index arrays *)
module IndexArray : sig

  (** This modules provides a high-level and safe access to
    * openGL index arrays. Index arrays can be passed to 3D rendering
    * primitives and are used to render 3D models more efficiently. *)

  (** Represents a source of indices *)
  module Source : sig

    (** This module provides a way to store indices in a source
      * before creating an index array.
      *
      * Note that a source is a mutable structure, therefore
      * add and (<<) will directly modify the source.
      *
      * Sources are redimensionned as needed when adding indices. *)

    (** Type of a source of indices *)
    type t

    (** An empty source *)
    val empty : int -> t

    (** Adds an integer index to a source (redimensions the source as needed) *)
    val add : t -> int -> unit

    (** Syntaxic sugar for sequences of additions
      *
      * $source << index1 << index2 << index3$ *)
    val (<<) : t -> int -> t

    (** Returns the length of a source *)
    val length : t -> int

    (** $append s1 s2$ appends the source $s2$ at the end of the source $s1$ (in place),
      * and returns $s1$.
      * Raises Invalid_source if types are incompatible. *)
    val append : t -> t -> t

  end

  (** Phantom type for static index arrays *)
  type static

  (** Phantom type for dynamic index arrays *)
  type dynamic

  (** Type of an index array (static or dynamic) *)
  type 'a t

  (** Creates a static index array. A static array is faster but can not be modified after creation.
    * @see:OgamlGraphics.IndexArray.Source *)
  val static : (module RenderTarget.T with type t = 'a) -> 'a -> Source.t -> static t

  (** Creates a dynamic index array that can be modified after creation.
    * @see:OgamlGraphics.IndexArray.Source *)
  val dynamic : (module RenderTarget.T with type t = 'a) -> 'a -> Source.t -> dynamic t

  (** $rebuild (module M) context array src offset$ rebuilds $array$ starting from
    * the index at position $offset$ using $src$.
    *
    * The index array is modified in-place and is resized as needed.
    * @see:OgamlGraphics.IndexArray.Source *)
  val rebuild : (module RenderTarget.T with type t = 'a) -> 'a -> dynamic t -> Source.t -> int -> unit

  (** Returns the length of an index array *)
  val length : 'a t -> int

end


(** High-level wrapper around OpenGL vertex arrays *)
module VertexArray : sig

  (** This modules provides a high-level and safe access to
    * openGL vertex arrays. Vertex arrays are used to store
    * vertices on the GPU and can be used to render 3D models. 
    *
    *
    * This module aims at providing a safe way to
    * create vertex arrays in 4 steps:
    *
    *
    *   - First, you will need to create a vertex structure. This 
    * is done using the function Vertex.make. You can add attributes
    * to your structure V by calling V.attribute and giving them a
    * name and type. You can also provide a divisor that will be used
    * for instanced rendering.
    *
    * The attributes will be passed to GLSL programs
    * under the provided name. Once you have added some attributes
    * to your structure, you need to seal it using V.seal. 
    *
    * Be careful as once a structure is sealed, you cannot add 
    * attributes to it anymore. You can then create vertices that will
    * contain the attributes of your structure using V.create.
    *
    * Alternatively, you can use the module SimpleVertex which
    * is a predefined non-instanced vertex structure containing a position, 
    * texture coordinates, a color, and a normal.
    *
    *
    *   - Secondly, you will need to create a source which contains
    * vertices. This is done using Source.empty. The module
    * Source provides several useful functions to manipulate
    * sources of vertices.
    *
    *
    *   - Thirdly, you need to upload the source to the GPU by using the module
    * Buffer, using one of the two functions $Buffer.static$ or $Buffer.dynamic$.
    * Once sent to the GPU, you can use Buffer.unpack to un-protect the type
    * by removing phantom types, which leads us to the fourth and last step:
    *
    *
    *   - Finally, you can create a vertex array from a collection of (unpacked)
    * vertex buffers. This vertex array can be drawn to a target using the
    * function $draw$. Every attribute required by the GLSL program will be 
    * automatically bound to the buffer of the vertex array that contains an
    * attribute with the same name. As such, when calling $VertexArray.create$
    * on a collection of buffers, every attribute name must appear only once.
    * 
    * Moreover, if any of the buffers contains an instanced attribute (that is,
    * an attribute with a non-zero divisor), the vertex array will be flaged as
    * "instanced", and all the draw calls will automatically use instanced rendering.
    *)


  (** Creation and manipulation of vertices *)
  module Vertex : sig

    (** This module provides a way to create and manipulate vertex structures
      * and vertices.
      *
      * A vertex is a collection attributes, and a vertex structure 
      * creates vertices that have the same attributes. *)

    (** Type of a vertex *)
    type 'a t

    (** Attribute types *)
    module AttributeType : sig

      (** This module provides phantom types to enforce the
        * soundness of attributes. *)

      (** Attribute type phantom type *)
      type 'a s

      (** Integer attribute *)
      val int : int s

      (** Vector2i attribute *)
      val vector2i : OgamlMath.Vector2i.t s

      (** Vector3i attribute *)
      val vector3i : OgamlMath.Vector3i.t s

      (** float attribute *)
      val float : float s

      (** Vector2f attribute *)
      val vector2f : OgamlMath.Vector2f.t s

      (** Vector3f attribute *)
      val vector3f : OgamlMath.Vector3f.t s

      (** Color attribute *)
      val color : Color.t s

    end


    (** Manipulation of attributes *)
    module Attribute : sig

      (** This module provides a way to set and access the
        * attributes of a vertex. *)

      (** Type of an attribute *)
      type ('a, 'b) s

      (** Sets the value of a vertex's attribute *)
      val set : 'b t -> ('a, 'b) s -> 'a -> unit

      (** Gets the value of a vertex's attribute.
        * Returns $Error$ if the attribute is not initialized. *)
      val get : 'b t -> ('a, 'b) s -> ('a, [> `Unbound_attribute of string]) result

      (** Returns the divisor of the attribute used during instanced rendering. *)
      val divisor : ('a, 'b) s -> int

      (** Returns the name of an attribute, that is, the name
        * that will refer to this attribute in a GLSL program. *)
      val name : ('a, 'b) s -> string

      (** Returns the type of an attribute *)
      val atype : ('a, 'b) s -> 'a AttributeType.s

    end


    (** Common signature to all vertex structures *)
    module type VERTEX = sig

      (** Phantom type associated to this vertex structure for safety reasons *)
      type s

      (** Adds an attribute to this structure.
        *
        * $divisor$ corresponds to the attribute's divisor for instanced rendering,
        * and defaults to $0$ (non-instanced) *)
      val attribute : string -> ?divisor:int -> 'a AttributeType.s ->
        (('a, s) Attribute.s, [> `Sealed_vertex | `Duplicate_attribute]) result

      (** Seals this structure. Once sealed, the structure can be used to
        * create vertices but cannot receive new attributes.
        * Returns $Error$ if the structure is already sealed. *)
      val seal : unit -> (unit, [> `Sealed_vertex]) result

      (** Creates a vertex following this structure.
        * Returns $Error$ if the structure is not sealed. *)
      val create : unit -> (s t, [>`Unsealed_vertex]) result

      (** Creates a copy of a vertex *)
      val copy : s t -> s t

    end


    (** Creates a new, custom vertex structure *)
    val make : unit -> (module VERTEX)

  end


  (** Simple pre-initialized structure *)
  module SimpleVertex : sig

    (** This module provides a simple pre-initialized structure with some
      * useful attributes :
      *
      *
      * - position, which should be refered to as $"position"$, which stores
      *   values of type $Vector3f.t$.
      *
      *
      * - color, which should be refered to as $"color"$, which stores
      *   values of type $Color.t$.
      *
      *
      * - uv, which should be refered to as $"uv"$, which stores
      *   values of type $Vector2f.t$.
      *
      *
      * - normal, which should be refered to as $"normal"$, which stores
      *   values of type $Vector3f.t$.*)

    (** Associated vertex structure *)
    module T : Vertex.VERTEX

    (** Creates a vertex with predefined attributes *)
    val create : 
      ?position:OgamlMath.Vector3f.t ->
      ?color:Color.t ->
      ?uv:OgamlMath.Vector2f.t ->
      ?normal:OgamlMath.Vector3f.t -> unit -> T.s Vertex.t

    (** Position attribute *)
    val position : (OgamlMath.Vector3f.t, T.s) Vertex.Attribute.s

    (** Color attribute *)
    val color : (Color.t, T.s) Vertex.Attribute.s

    (** UV attribute *)
    val uv : (OgamlMath.Vector2f.t, T.s) Vertex.Attribute.s

    (** Normal attribute *)
    val normal : (OgamlMath.Vector3f.t, T.s) Vertex.Attribute.s

  end


  (** Vertex source *)
  module Source : sig

    (** This module represents vertex sources, which are collections of
      * vertices. 
      *
      *
      * This module ensures that everything goes well. In particular, it
      * verifies that all the vertices of a source are compatible (i.e.
      * have the same initialized attributes).
      *
      *
      * An empty source can receive any vertex. The type of the source
      * is then fixed by the first vertex added to it. Any vertex 
      * added to the source after the first one must have at least the
      * same initialized attributes as the first vertex. 
      *
      *
      * Note that the type of a source is reinitialized if the source is
      * cleared. *)

    (** Type of a vertex source *)
    type 'a t

    (** Empty vertex source. The source will be redimensionned as needed, but
      * an initial size can be specified with $size$. *)
    val empty : ?size:int -> unit -> 'a t

    (** Adds a vertex to a source. If the source is not empty, the vertex must 
      * have at least the same initialized fields as the first vertex put into
      * the source. *)
    val add : 'a t -> 'a Vertex.t -> (unit, [> `Missing_attribute of string]) result

    (** Convenient operator to add vertices to a source. *)
    val (<<) : 'a t -> 'a Vertex.t -> ('a t, [> `Missing_attribute of string]) result

    (** Convenient operator to add vertices to a source that can easily
      * be chained. *)
    val (<<<) : ('a t, [> `Missing_attribute of string] as 'b) result -> 'a Vertex.t -> 
      ('a t, 'b) result

    (** Returns the length (in vertices) of a source. *)
    val length : 'a t -> int

    (** Clears the source. Any source that has been converted into a vertex array
      * can be safely cleared and reused. 
      * This avoids reallocation and garbage collection. *)
    val clear : 'a t -> unit

    (** $append s1 s2$ appends the source $s2$ to $s1$. $s2$ is not modified. 
      *
      * Returns $Error$ if both sources do not contain the same fields. *) 
    val append : 'a t -> 'a t -> (unit, [> `Incompatible_fields]) result

    (** Iterates through all the vertices of a source. *)
    val iter : 'a t -> ?start:int -> ?length:int -> ('a Vertex.t -> unit) -> unit

    (** Maps all the vertices of a source to a new source. *)
    val map : 'a t -> ?start:int -> ?length:int -> ('a Vertex.t -> 'b Vertex.t) ->
      ('b t, [> `Missing_attribute of string]) result

    (** Maps all the vertices of a source to an existing source. *)
    val map_to : 'a t -> ?start:int -> ?length:int -> ('a Vertex.t -> 'b Vertex.t) -> 'b t ->
      (unit, [> `Missing_attribute of string]) result

  end


  (* Vertex buffer *)
  module Buffer : sig

    (** This module represents vertex buffers, which are vertex sources that
      * have been uploaded to the GPU.
      *
      * A buffer can be either static or dynamic. The data of a dynamic 
      * buffer can be changed using $blit$, whereas the data of a static buffer
      * cannot. However, a static buffer provides faster accesses, and
      * should therefore be used whenever possible. 
      *
      * Buffers can also be unpacked using $unpack$ which unprotects the type 
      * but allows the user to build lists of buffers. *)

    (** Phantom type for static buffers *)
    type static
    
    (** Phantom type for dynamic buffers *)
    type dynamic
  
    (** Type of a buffer with vertices of type $'b$ *)
    type ('a, 'b) t 
 
    (** Type of an unprotected buffer *)
    type unpacked
   
    (** Creates a static buffer from a source. A static buffer is faster
      * but cannot be modified later. @see:OgamlGraphics.VertexArray.Source *)
    val static : (module RenderTarget.T with type t = 'a) 
                  -> 'a -> 'b Source.t -> (static, 'b) t
    
    (** Creates a dynamic buffer from a source. A dynamic buffer can be
      * modified later. @see:OgamlGraphics.VertexArray.Source *)
    val dynamic : (module RenderTarget.T with type t = 'a) 
                   -> 'a -> 'b Source.t -> (dynamic, 'b) t
  
    (** Returns the length (in vertices) of a vertex buffer. *)
    val length : (_, _) t -> int
 
    (** $blit (module M) context buffer ~first ~length source$ copies
      * $length$ vertices from $source$ to $buffer$, starting from the
      * $first$-th element of $buffer$. $buffer$ is modified in place and is
      * resized as needed.
      *
      * $first$ defaults to $0$
      *
      * $length$ defaults to the length of $source$ *)
    val blit    : (module RenderTarget.T with type t = 'a) ->
                   'a -> (dynamic, 'b) t ->
                   ?first:int -> ?length:int ->
                   'b Source.t ->
                   (unit, [> `Invalid_start | `Invalid_length | `Incompatible_sources]) result
 
    (** Unprotect a buffer so that it is possible to build lists of buffers. *)
    val unpack : (_, _) t -> unpacked
  
  end

  (** Type of a vertex array *)
  type t
 
  (** Creates a vertex array from a list of vertex buffers.
    * 
    * Raises $Multiple_definition$ if the same attribute is bound twice in the buffers. *)
  val create : (module RenderTarget.T with type t = 'a) -> 'a -> Buffer.unpacked list -> t
  
  (** Returns the maximal number of vertices that can be drawn with the array. *)
  val length : t -> int
  
  (** Returns the maximal number of instanced that can be drawn with the array.
    * Returns $None$ if none of the buffers are instanced. *)
  val max_instances : t -> int option

  (** Draws $length$ vertices starting from $start$ of the vertex array $vertices$
    * on $target$ using the given parameters. Is the vertex array is instanced,
    * it draws $instances$ instances. Otherwise, the parameter $instances$
    * is ignored.
    *
    * $start$ defaults to 0.
    *
    * If $length$ is not provided, then the whole vertex array (starting from $start$) is drawn.
    *
    * If $instances$ is not provided and if the data is instanced, then 
    * $max_instances vertices$ instances are drawn.
    *
    * $uniform$ should provide the uniforms required by $program$ (defaults to empty)
    *
    * $parameters$ defaults to $DrawParameter.make ()$
    *
    * $buffers$ defaults to $[Color 0]$ for custom framebuffers, and to
    * $[BackLeft]$ for the default framebuffer (Window).
    *
    * $mode$ defaults to $DrawMode.Triangles$
    *
    * @see:OgamlGraphics.IndexArray @see:OgamlGraphics.Window
    * @see:OgamlGraphics.Program @see:OgamlGraphics.Uniform
    * @see:OgamlGraphics.DrawParameter @see:OgamlGraphics.DrawMode *)
  val draw :
    (module RenderTarget.T with type t = 'a and type OutputBuffer.t = 'b) ->
    vertices   : t ->
    target     : 'a ->
    ?instances : int ->
    ?indices   : _ IndexArray.t ->
    program    : Program.t ->
    ?uniform    : Uniform.t ->
    ?parameters : DrawParameter.t ->
    ?buffers   : 'b list ->
    ?start     : int ->
    ?length    : int ->
    ?mode      : DrawMode.t ->
    unit -> (unit, [> `Wrong_attribute_type of string 
                   | `Missing_attribute of string 
                   | `Invalid_slice 
                   | `Invalid_instance_count
                   | `Invalid_uniform_type of string
                   | `Invalid_texture_unit of int
                   | `Missing_uniform of string
                   | `Too_many_textures]) result

end


(** Creation, loading and manipulation of 3D models *)
module Model : sig

  (** This module provides helpers to manipulate and load
    * immutable 3D models in the RAM.
    *
    * Moreover, the operations provided in this module are generally costly
    * and should not be used in performance-sensitive code.
    *
    * Models stored in that form are not RAM-friendly, and
    * should not be stored in large numbers. Use vertex arrays
    * instead. *)

  (** Represents a particular vertex of a model *)
  module Vertex : sig

    (** Type of a model vertex *)
    type t

    (** Creates a model vertex *)
    val create : position:OgamlMath.Vector3f.t ->
                ?normal:OgamlMath.Vector3f.t   ->
                ?uv:OgamlMath.Vector2f.t       ->
                ?color:Color.t -> unit -> t

    (** Returns the position of a model vertex *)
    val position : t -> OgamlMath.Vector3f.t

    (** Returns the normal of a model vertex *)
    val normal : t -> OgamlMath.Vector3f.t option

    (** Returns the UV coordinates associated to a model vertex *)
    val uv : t -> OgamlMath.Vector2f.t option

    (** Returns the color of a model vertex *)
    val color : t -> Color.t option

  end


  (** Represents a face of a model *)
  module Face : sig

    (** Type of a face *)
    type t

    (** Creates a face from 3 vertices *)
    val create : Vertex.t -> Vertex.t -> Vertex.t -> t

    (** Returns the two triangles associated to 4 vertices *)
    val quad : Vertex.t -> Vertex.t -> Vertex.t -> Vertex.t -> (t * t)

    (** Returns the 3 vertices of a face *)
    val vertices : t -> (Vertex.t * Vertex.t * Vertex.t)

    (** Returns a new face painted with a given color *)
    val paint : t -> Color.t -> t

    (** Returns the normal of a face *)
    val normal : t -> OgamlMath.Vector3f.t

  end

  (** Represents the location of a parsing error *)
  module Location : sig

    (** Modules that stores a representation of the location of a parsing
      * error for OBJ files *)
 
    (** Location type *)
    type t
 
    (** First line of the error *)
    val first_line : t -> int
  
    (** Last line of the error *)
    val last_line : t -> int
  
    (** First char of the error *)
    val first_char : t -> int
  
    (** Last char of the error *)
    val last_char : t -> int
  
    (** Returns a pretty-printed string of the location *)
    val to_string : t -> string
  
  end


  (** Type of a model *)
  type t

  (*** Model creation *)

  (** Empty model *)
  val empty : t

  (** Returns the model associated to an OBJ file *)
  val from_obj : string -> (t, [> `Syntax_error of (Location.t * string) 
                               | `Parsing_error of Location.t]) result


  (** Creates a cube from two endpoints *)
  val cube : OgamlMath.Vector3f.t -> OgamlMath.Vector3f.t -> t


  (*** Transformations *)

  (** Applies a transformation to a 3D model *)
  val transform : t -> OgamlMath.Matrix3D.t -> t

  (** Scales a 3D model *)
  val scale : t -> OgamlMath.Vector3f.t -> t

  (** Translates a 3D model *)
  val translate : t -> OgamlMath.Vector3f.t -> t

  (** Rotates a 3D model *)
  val rotate : t -> OgamlMath.Quaternion.t -> t


  (*** Model modification *)

  (** Adds a face to a model *)
  val add_face : t -> Face.t -> t

  (** Paints the whole model with a given color *)
  val paint : t -> Color.t -> t

  (** Merges two models *)
  val merge : t -> t -> t

  (** (Re-)computes the normals of a model. If $smooth$ is $true$,
    * then the normals are computed per-vertex instead of per-face *)
  val compute_normals : ?smooth:bool -> t -> t

  (** Simpifies a model (removes all redundant faces) *)
  val simplify : t -> t

  (** Appends a model to a vertex source. Uses indexing if an index source is provided.
    * Use Triangles as DrawMode with this source.
    * @see:OgamlGraphics.IndexArray.Source
    * @see:OgamlGraphics.VertexArray.Source *)
  val source : t -> ?index_source:IndexArray.Source.t 
                 -> vertex_source:VertexArray.SimpleVertex.T.s VertexArray.Source.t 
                 -> unit -> (unit, [> `Missing_attribute of string]) result


  (*** Iterators *)

  (** Iterates through all faces of a model *)
  val iter : t -> (Face.t -> unit) -> unit

  (** Folds through all faces of a model *)
  val fold : t -> ('a -> Face.t -> 'a) -> 'a -> 'a

  (** Maps a model face by face *)
  val map : t -> (Face.t -> Face.t) -> t

end


(** Creation and manipulation of 2D shapes *)
module Shape : sig

  (** Type of shapes *)
  type t

  (** Creates a convex polygon given a list of points.
    * points is this list of points,
    * origin is the origin of the polygon.
    * All coordinates are taken with respect to the top-left corner of the
    * shape. *)
  val create_polygon :
    points        : OgamlMath.Vector2f.t list ->
    color         : Color.t ->
    ?origin       : OgamlMath.Vector2f.t ->
    ?position     : OgamlMath.Vector2f.t ->
    ?scale        : OgamlMath.Vector2f.t ->
    ?rotation     : float ->
    ?thickness    : float ->
    ?border_color : Color.t ->
    unit -> t

  (** Creates a rectangle.
    * Its origin is positioned with respect to the top-left corner. *)
  val create_rectangle :
    position      : OgamlMath.Vector2f.t ->
    size          : OgamlMath.Vector2f.t ->
    color         : Color.t ->
    ?origin       : OgamlMath.Vector2f.t ->
    ?scale        : OgamlMath.Vector2f.t ->
    ?rotation     : float ->
    ?thickness    : float ->
    ?border_color : Color.t ->
    unit -> t

  (** Creates a regular polygon with a given number of vertices.
    * When this number is high, one can expect a circle. *)
  val create_regular :
    position      : OgamlMath.Vector2f.t ->
    radius        : float ->
    amount        : int ->
    color         : Color.t ->
    ?origin       : OgamlMath.Vector2f.t ->
    ?scale        : OgamlMath.Vector2f.t ->
    ?rotation     : float ->
    ?thickness    : float ->
    ?border_color : Color.t ->
    unit -> t

  (** Creates a line from $top$ (zero by default) to $tip$. *)
  val create_line :
    thickness : float ->
    color     : Color.t ->
    ?top      : OgamlMath.Vector2f.t ->
    tip       : OgamlMath.Vector2f.t ->
    ?position : OgamlMath.Vector2f.t ->
    ?origin   : OgamlMath.Vector2f.t ->
    ?rotation : float ->
    unit -> t

  (** Draws a shape on a window using the given parameters.
    *
    * $parameters$ defaults to $DrawParameter.make ~depth_test:false ~blend_mode:DrawParameter.BlendMode.alpha$
    *
    * @see:OgamlGraphics.DrawParameter
    * @see:OgamlGraphics.Window *)
  val draw : (module RenderTarget.T with type t = 'a) ->
             ?parameters:DrawParameter.t -> target:'a -> shape:t -> unit -> unit

  (** Sets the position of the origin in the window. *)
  val set_position : t -> OgamlMath.Vector2f.t -> unit

  (** Sets the position of the origin with respect to the top-left corner of the
    * shape. *)
  val set_origin : t -> OgamlMath.Vector2f.t -> unit

  (** Sets the angle of rotation of the shape. *)
  val set_rotation : t -> float -> unit

  (** Sets the scale of the shape. *)
  val set_scale : t -> OgamlMath.Vector2f.t -> unit

  (** Sets the thickness of the outline. *)
  val set_thickness : t -> float -> unit

  (** Sets the filling color of the shape. *)
  val set_color : t -> Color.t -> unit

  (** Translates the shape by the given vector. *)
  val translate : t -> OgamlMath.Vector2f.t -> unit

  (** Rotates the shape by the given angle. *)
  val rotate : t -> float -> unit

  (** Scales the shape. *)
  val scale : t -> OgamlMath.Vector2f.t -> unit

  (** Returns the position of the origin in window coordinates. *)
  val position : t -> OgamlMath.Vector2f.t

  (** Returns the position of the origin with respect to the first point of the
    * shape. *)
  val origin : t -> OgamlMath.Vector2f.t

  (** Returns the angle of rotation of the shape. *)
  val rotation : t -> float

  (** Returns the scale of the shape. *)
  val get_scale : t -> OgamlMath.Vector2f.t

  (** Returns the thickness of the outline. *)
  val thickness : t -> float

  (** Returns the filling color of the shape. *)
  val color : t -> Color.t

  (*** Vertex array access *)

  (** Outputs a shape to a vertex array source.
    * 
    * This outputs triangles with position
    * and color attributes.
    *
    * Use DrawMode.Triangles with this source. *)
  val to_source : t -> VertexArray.SimpleVertex.T.s VertexArray.Source.t ->
    (unit, [> `Missing_attribute of string]) result

  (** Outputs a shape to a vertex array source by mapping its vertices.
    *
    * See $to_source$ for more information. *)
  val map_to_source : t -> 
    (VertexArray.SimpleVertex.T.s VertexArray.Vertex.t -> 'b VertexArray.Vertex.t) -> 
    'b VertexArray.Source.t -> 
    (unit, [> `Missing_attribute of string]) result

end


(** Creation and manipulation of 2D sprites *)
module Sprite : sig

  (** Type of sprites *)
  type t

  (** Creates a sprite. *)
  val create :
    texture   : Texture.Texture2D.t ->
    ?subrect  : OgamlMath.IntRect.t ->
    ?origin   : OgamlMath.Vector2f.t ->
    ?position : OgamlMath.Vector2f.t ->
    ?scale    : OgamlMath.Vector2f.t ->
    ?color    : Color.t ->
    ?size     : OgamlMath.Vector2f.t ->
    ?rotation : float ->
    unit -> (t, [> `Invalid_subrect]) result

  (** Draws a sprite on a window using the given parameters.
    *
    * $parameters$ defaults to $DrawParameter.make ~depth_test:false ~blend_mode:DrawParameter.BlendMode.alpha$
    *
    * @see:OgamlGraphics.DrawParameter
    * @see:OgamlGraphics.Window *)
  val draw : (module RenderTarget.T with type t = 'a) -> 
             ?parameters:DrawParameter.t -> target:'a -> sprite:t -> unit -> unit

  (** Sets the position of the origin of the sprite in the window. *)
  val set_position : t -> OgamlMath.Vector2f.t -> unit

  (** Sets the position of the origin with respect to the top-left corner of the
    * sprite. The origin is the center of all transformations. *)
  val set_origin : t -> OgamlMath.Vector2f.t -> unit

  (** Sets the angle of rotation of the sprite. *)
  val set_rotation : t -> float -> unit

  (** Sets the scale of the sprite. *)
  val set_scale : t -> OgamlMath.Vector2f.t -> unit

  (** Sets the base size of a sprite. *)
  val set_size : t -> OgamlMath.Vector2f.t -> unit

  (** Sets the color of a sprite. *)
  val set_color : t -> Color.t -> unit

  (** Translates the sprite by the given vector. *)
  val translate : t -> OgamlMath.Vector2f.t -> unit

  (** Rotates the sprite by the given angle. *)
  val rotate : t -> float -> unit

  (** Scales the sprite. *)
  val scale : t -> OgamlMath.Vector2f.t -> unit

  (** Returns the base size of a sprite *)
  val size : t -> OgamlMath.Vector2f.t

  (** Returns the position of the origin in window coordinates. *)
  val position : t -> OgamlMath.Vector2f.t

  (** Returns the position of the origin with respect to the first point of the
    * sprite. *)
  val origin : t -> OgamlMath.Vector2f.t

  (** Returns the angle of rotation of the sprite. *)
  val rotation : t -> float

  (** Returns the color of a sprite. *)
  val color : t -> Color.t

  (** Returns the scale of the sprite. *)
  val get_scale : t -> OgamlMath.Vector2f.t

  (*** Vertex array access *)

  (** Outputs a sprite to a vertex array source.
    * 
    * This outputs two triangles with UV coordinates
    * and position attributes.
    *
    * Use DrawMode.Triangles with this source. *)
  val to_source : t -> VertexArray.SimpleVertex.T.s VertexArray.Source.t ->
    (unit, [> `Missing_attribute of string]) result

  (** Outputs a sprite to a vertex array source by mapping its vertices.
    *
    * See $to_source$ for more information. *)
  val map_to_source : t -> 
                      (VertexArray.SimpleVertex.T.s VertexArray.Vertex.t -> 'b VertexArray.Vertex.t) -> 
                      'b VertexArray.Source.t ->
                      (unit, [> `Missing_attribute of string]) result

end


(** Text rendering *)
module Text : sig

  (** This module provides an efficient way to render
    * text using openGL primitives. *)

  (** Advanced text rendering *)
  module Fx : sig

  (** This module provides a more customisable way to render text through the
    * use of iterators. This might prove more costly and also harder to use than
    * the simple Text.t but it is much more powerful. *)

    (** The type of pre-rendered customised texts. *)
    type t

    (*** Iterators *)

    (** The type of an iterator.
      * The idea behind it is that $'a$ is the type of objects that we
      * manipulate (eg. $Font.code$) while $'b$ is the type of the value
      * computed by the iterator.
      * We rely here on continuation passing style to deal with this vaue at
      * each step. *)
    type ('a,'b) it = 'a -> 'b -> ('b -> 'b) -> 'b

    (** The type of a full iterator also containing its initial value and a
      * post-treatment function, typically to forget information that was useful
      * to the computation but is irrelevant as a value. *)
    type ('a,'b,'c) full_it = ('a, 'b) it * 'b * ('b -> 'c)

    (** This creates a simple iterator that will return a constant for each
      * value in the iterated list. *)
    val forall : 'c -> ('a, 'c list, 'c list) full_it

    (** Lifts a function as map would do. *)
    val foreach : ('a -> 'b) -> ('a, 'b list, 'b list) full_it

    (** Lifts a function as mapi would do: it adds a parameter counting the
      * number of times it has been called starting at 0. *)
    val foreachi : ('a -> int -> 'b) -> ('a, 'b list * int, 'b list) full_it

    (** This iterator is specific to Font.code and allows the user to lift a
      * function taking words instead of characters.
      * It splits strings on blank spaces, hence the requirement for their value
      * as second argument. *)
    val foreachword :
      (Font.code list -> 'a) -> 'a ->
      (Font.code, 'a list * Font.code list, 'a list) full_it

    (** Creates a drawable text with strongly customisable parameters. *)
    val create :
      (module RenderTarget.T with type t = 'a) ->
      target : 'a ->
      text : string ->
      position : OgamlMath.Vector2f.t ->
      font : Font.t ->
      colors : (Font.code,'b,Color.t list) full_it ->
      size : int ->
      unit -> t

    (** Draws a Fx.t. *)
    val draw :
      (module RenderTarget.T with type t = 'a) ->
      ?parameters : DrawParameter.t ->
      text : t ->
      target : 'a ->
      unit ->
      (unit, [> `Font_texture_size_overflow | `Font_texture_depth_overflow]) result

    (** The global advance of the text.
      * Basically it is a vector such that if you add it to the position of
      * text object, you get the position of the next character you would
      * draw. *)
    val advance : t -> OgamlMath.Vector2f.t

    (** Returns a rectangle containing all the text. *)
    val boundaries : t -> OgamlMath.FloatRect.t

  end

  (** The type of pre-rendered texts. *)
  type t

  (** Creates a drawable text from the given string. *)
  val create :
    text : string ->
    position : OgamlMath.Vector2f.t ->
    font : Font.t ->
    ?color : Color.t ->
    size : int ->
    ?bold : bool ->
    unit -> t

  (** Draws text on the screen. *)
  val draw :
    (module RenderTarget.T with type t = 'a) ->
    ?parameters : DrawParameter.t ->
    text : t ->
    target : 'a ->
    unit -> 
    (unit, [> `Font_texture_size_overflow | `Font_texture_depth_overflow]) result

  (** The global advance of the text.
    * Basically it is a vector such that if you add it to the position of
    * text object, you get the position of the next character you would draw. *)
  val advance : t -> OgamlMath.Vector2f.t

  (** Returns a rectangle containing all the text. *)
  val boundaries : t -> OgamlMath.FloatRect.t

  (*** Vertex array access *)

  (** Outputs text vertices to a vertex array source.
    * 
    * This outputs triangles with UV coordinates, color
    * and position attributes.
    *
    * Use DrawMode.Triangles with this source and bind the
    * correct font before use. *)
  val to_source : t -> VertexArray.SimpleVertex.T.s VertexArray.Source.t -> 
    (unit, [> `Missing_attribute of string]) result

  (** Outputs text vertices to a vertex array source by mapping its vertices.
    *
    * See $to_source$ for more information. *)
  val map_to_source : t -> 
                      (VertexArray.SimpleVertex.T.s VertexArray.Vertex.t -> 'b VertexArray.Vertex.t) -> 
                      'b VertexArray.Source.t ->
                      (unit, [> `Missing_attribute of string]) result
end


(** Getting real-time mouse information *)
module Mouse : sig

  (** This module allows real-time access to the mouse,
    * to check if a button is currently pressed for example. *)

  (*** Accessing position *)
  (** Returns the position of the cursor relatively to the screen.
    * @see:OgamlMath.Vector2i *)
  val position : unit -> OgamlMath.Vector2i.t

  (** Returns the position of the cursor relatively to a window.
    * @see:OgamlGraphics.Window
    * @see:OgamlMath.Vector2i *)
  val relative_position : Window.t -> OgamlMath.Vector2i.t

  (*** Setting position *)
  (** Sets the position of the cursor relatively to the screen
    * @see:OgamlMath.Vector2i *)
  val set_position : OgamlMath.Vector2i.t -> unit

  (** Sets the position of the cursor relatively to a window
    * @see:OgamlGraphics.Window
    * @see:OgamlMath.Vector2i *)
  val set_relative_position : Window.t -> OgamlMath.Vector2i.t -> unit

  (*** Accessing button information *)
  (** Check whether a given mouse button is currently held down
    * @see:OgamlCore.Button *)
  val is_pressed : OgamlCore.Button.t -> bool

end


(** Getting real-time keyboard information *)
module Keyboard : sig

  (** This module allows real-time access to the keyboard,
    * to check if a key is currently pressed for example. *)

  (*** Polling keyboard *)
  (** $is_pressed key$ will return $true$ iff $key$ is currently pressed
    * @see:OgamlCore.Keycode *)
  val is_pressed : OgamlCore.Keycode.t -> bool

  (*** Accessing modifiers information *)
  (** $true$ iff the shift modifier is active *)
  val is_shift_down : unit -> bool

  (** $true$ iff the control modifier (or cmd on OSX) is active *)
  val is_ctrl_down : unit -> bool

  (** $true$ iff the alt modifier is active *)
  val is_alt_down : unit -> bool

end


