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
  val hsv : t -> HSV.t

  (** Converts a color to RGB
    * @see:OgamlGraphics.Color.RGB *)
  val rgb : t -> RGB.t

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

  end

  (** Depth testing functions enumeration *)
  module DepthTest : sig

    (** This module consists of one enumeration of openGL depth functions *)

    (** Depth testing functions *)
    type t = 
      | None (* No testing, test always passes *)
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
             ?blend_mode:BlendMode.t ->
             ?viewport:Viewport.t ->
             ?antialiasing:bool ->
             unit -> t

end


(** Encapsulates data about an OpenGL internal state *)
module State : sig

  (** This module encapsulates a copy of the internal GL state.
    * This allows efficient optimizations of state changes.
    *
    * To get an instance of a State.t, create a context (via a window) and
    * use Window.state *)

  (** Raised when trying to perform an invalid state change 
    * (for example, binding a texture to an invalid texture unit) *)
  exception Invalid_state of string

  (** Type of a GL state *)
  type t

  (** Returns the GL version supported by this state in (major, minor) format *)
  val version : t -> (int * int)

  (** Returns true iff the given GL version in (major, minor) format
    * is supported by the given state *)
  val is_version_supported : t -> (int * int) -> bool

  (** Returns the GLSL version supported by this state *)
  val glsl_version : t -> int

  (** Returns true iff the given GLSL version is supported by this state *)
  val is_glsl_version_supported : t -> int -> bool

  (** Asserts that no openGL error occured internally. Used for debugging and testing. *)
  val assert_no_error : t -> unit

  (** Returns the number of available texture units *)
  val max_textures : t -> int

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

    (** Type of a render target *)
    type t

    (** Returns the size of a render target *)
    val size : t -> OgamlMath.Vector2i.t

    (** Returns the internal context associated to a render target *)
    val state : t -> State.t

    (** Clears a render target *)
    val clear : ?color:Color.t option -> ?depth:bool -> ?stencil:bool -> t -> unit

    (** Binds a render target for drawing. System-only function, usually done
      * automatically. *)
    val bind : t -> DrawParameter.t -> unit

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

  (** Depth Renderbuffer *)
  module DepthBuffer : sig

    (** Type of a depth renderbuffer *)
    type t

    (** Creates a depth renderbuffer from a context and a size *)
    val create : (module RenderTarget.T with type t = 'a) -> 'a -> OgamlMath.Vector2i.t -> t

    (** DepthBuffer implements the interface DepthAttachable *)
    val to_depth_attachment : t -> Attachment.DepthAttachment.t

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

  (** Creates a framebuffer from a valid context *)
  val create : (module RenderTarget.T with type t = 'a) -> 'a -> t

  (** Returns the maximal number of color attachments for a framebuffer *)
  val max_color_attachments : t -> int

  (** Attaches a valid color attachment to a framebuffer *)
  val attach_color : (module Attachment.ColorAttachable with type t = 'a) 
                      -> t -> int -> 'a -> unit

  (** Attaches a valid depth attachment to a framebuffer *)
  val attach_depth : (module Attachment.DepthAttachable with type t = 'a)
                      -> t -> 'a -> unit

  (** Attaches a valid stencil attachment to a framebuffer *)
  val attach_stencil : (module Attachment.StencilAttachable with type t = 'a)
                      -> t -> 'a -> unit

  (** Attaches a valid depth and stencil attachment to a framebuffer *)
  val attach_depthstencil : (module Attachment.DepthStencilAttachable with type t = 'a)
                      -> t -> 'a -> unit

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
  val state : t -> State.t

  (** Clears the FBO *)
  val clear : ?color:Color.t option -> ?depth:bool -> ?stencil:bool -> t -> unit

  (** Binds the FBO for drawing. Internal use only. *)
  val bind : t -> DrawParameter.t -> unit

end



(** Image manipulation and creation *)
module Image : sig

  (** This module provides a safe way to load and access images stored in the RAM.
    * Images stored this way are uncompressed arrays of bytes and are therefore
    * not meant to be stored in large quantities. *)

  (** Raised when an error occur in this module *)
  exception Image_error of string

  (** Type of an image stored in the RAM *)
  type t

  (** Creates an image from a file, some RGBA-formatted data, or an empty one
    * filled with a default color
    *
    * Raises $Image_error$ if the loading fails 
    * @see:OgamlGraphics.Color *)
  val create : [`File of string | `Empty of OgamlMath.Vector2i.t * Color.t | `Data of OgamlMath.Vector2i.t * Bytes.t] -> t

  (** Return the size of an image *)
  val size : t -> OgamlMath.Vector2i.t

  (** Sets a pixel of an image
    * @see:OgamlGraphics.Color *)
  val set : t -> OgamlMath.Vector2i.t -> Color.t -> unit

  (** Gets the color of a pixel of an image
    * @see:OgamlGraphics.Color.RGB *)
  val get : t -> OgamlMath.Vector2i.t -> Color.RGB.t

  (** $blit src ~rect dest offset$ blits the subimage of $src$ defined by $rect$
    * on the image $dest$ at position $offset$ (relative to the top-left pixel).
    *
    * If $rect$ is not provided then the whole image $src$ is used.
    * @see:OgamlMath.IntRect @see:OgamlMath.Vector2i *)
  val blit : t -> ?rect:OgamlMath.IntRect.t -> t -> OgamlMath.Vector2i.t -> unit

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


  (** Raised if the creation of a texture fails *)
  exception Creation_error of string


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


  (** Represents a mipmap level of a 2D texture *)
  module Texture2DMipmap : sig

    (** Type of a 2D mipmap level *)
    type t

    (** Size of the mipmap level *)
    val size : t -> OgamlMath.Vector2i.t

    (** Writes an image to a sub-rectangle of a mipmap level.
      * Writes to the full mipmap level by default. *)
    val write : t -> ?rect:OgamlMath.IntRect.t -> Image.t -> unit

    (** Returns the level of a Texture2DMipmap.t *)
    val level : t -> int
 
    (** System only function, binds the original texture of the mipmap *)
    val bind : t -> int -> unit 

    (** Texture2DMipmap implements the interface ColorAttachable and
      * can be attached to an FBO. *)
    val to_color_attachment : t -> Attachment.ColorAttachment.t

  end


  (** Represents a simple 2D texture *)
  module Texture2D : sig

    (** This module provides an abstraction of OpenGL 2D textures
      * that can be used for 2D rendering (with sprites) or
      * 3D rendering when passed to a GLSL program. *)

    (** Type of a 2D texture *)
    type t

    (** Creates a texture from a source (a file or an image).
      * Generates all mipmaps by default. *)
    val create : (module RenderTarget.T with type t = 'a) -> 'a -> 
                 ?mipmaps:[`AllEmpty | `Empty of int | `AllGenerated | `Generated of int | `None] ->
                 [< `File of string | `Image of Image.t | `Empty of OgamlMath.Vector2i.t] -> t

    (** Returns the size of a texture *)
    val size : t -> OgamlMath.Vector2i.t

    (** Sets the minifying filter of a texture. Defaults as LinearMipmapLinear. *)
    val minify : t -> MinifyFilter.t -> unit

    (** Sets the magnifying filter of a texture. Defaults as Linear *)
    val magnify : t -> MagnifyFilter.t -> unit

    (** Sets the wrapping function of a texture. Defaults as ClampEdge.  *)
    val wrap : t -> WrapFunction.t -> unit
    
    (** Returns the number of mipmap levels of a texture *)
    val mipmap_levels : t -> int

    (** Returns a mipmap level of a texture.
      * Raises Invalid_argument if the requested level is out of bounds *)
    val mipmap : t -> int -> Texture2DMipmap.t

    (** System only function, binds a texture to a texture unit for drawing *)
    val bind : t -> int -> unit

    (** Texture2D implements the interface ColorAttachable and can be attached
      * to an FBO. Binds the mipmap level 0. *)
    val to_color_attachment : t -> Attachment.ColorAttachment.t

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
    val layer : t -> int -> Texture2DArrayLayerMipmap.t

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
    val mipmap : t -> int -> Texture2DArrayLayerMipmap.t

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

    (** Creates a texture array from a list of files, a list of images, or
      * creates an empty array of given dimensions.
      * Generates all mipmaps by default for every layer by default.
      *
      * Raises Creation_error if the list of images (or files) is empty, or
      * if all the images do not have the same dimensions. *)
    val create : (module RenderTarget.T with type t = 'a) -> 'a
                 -> ?mipmaps:[`AllEmpty | `Empty of int | `AllGenerated | `Generated of int | `None]
                 -> [< `File of string list | `Image of Image.t list | `Empty of OgamlMath.Vector3i.t] -> t

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
    val layer : t -> int -> Texture2DArrayLayer.t

    (** Returns a particular mipmap of a texture array. *)
    val mipmap : t -> int -> Texture2DArrayMipmap.t

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

  (** Raised when an error occur in this module *)
  exception Font_error of string

  (** Type of a font *)
  type t

  (** Type alias for a character given in ASCII or UTF-8 *)
  type code = [`Char of char | `Code of int]

  (** Loads a font from a file *)
  val load : string -> t

  (** $glyph state font code size bold$ returns the glyph
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
                t -> Texture.Texture2DArray.t

  (** Returns the index associated to a font size in the font's texture *)
  val size_index : t -> int -> int

end


(** High-level wrapper around GL shader programs *)
module Program : sig

  (** This module provides a high-level wrapper around GL shader programs
    * and can be used to compile shaders. *)

  (** Raised when the compilation of a program fails *)
  exception Compilation_error of string

  (** Raised when the linking of a program fails *)
  exception Linking_error of string

  (** Raised when trying to compile a program with a version
    * that is not supported by the current context *)
  exception Invalid_version of string

  (** Type of a program *)
  type t

  (** Type of a source, from a file or from a string *)
  type src = [`File of string | `String of string]

  (** Compiles a program from a rendering context, a vertex source 
    * and a fragment source.
    * The source must begin with a version assigment $#version xxx$ *)
  val from_source : (module RenderTarget.T with type t = 'a) -> target:'a -> 
                    vertex_source:src -> fragment_source:src -> t

  (** Compiles a program from a rendering context and
    * a list of sources paired with their required GLSL version.
    * The function will chose the best source for the current context.
    * @see:OgamlGraphics.State *)
  val from_source_list : (module RenderTarget.T with type t = 'a) -> target:'a 
                        -> vertex_source:(int * src) list
                        -> fragment_source:(int * src) list -> t

  (** Compiles a program from a rendering context and a source.
    * The source should not begin with a $#version xxx$ assignment,
    * as the function will preprocess the sources and prepend the
    * best version declaration.
    * @see:OgamlGraphics.State *)
  val from_source_pp : (module RenderTarget.T with type t = 'a) -> target:'a 
                      -> vertex_source:src
                      -> fragment_source:src -> t

end


(** Encapsulates a group of uniforms for rendering *)
module Uniform : sig

  (** This module encapsulates a set of uniforms that
    * can be passed to GLSL programs *)

  (** Raised when trying to draw using a program
    * that requires a uniform not provided in the set *)
  exception Unknown_uniform of string

  (** Raised when the type of a uniform is not matching
    * the type required by the GLSL program *)
  exception Invalid_uniform of string

  (** Type of a set of uniforms *)
  type t

  (** Empty set of uniforms *)
  val empty : t

  (** $vector3f name vec set$ adds the uniform $vec$ to $set$.
    * the uniform should be refered to as $name$ in a glsl program.
    * Type : vec3.
    * @see:OgamlMath.Vector3f *)
  val vector3f : string -> OgamlMath.Vector3f.t -> t -> t

  (** See vector3f. Type : vec2. @see:OgamlMath.Vector2f *)
  val vector2f : string -> OgamlMath.Vector2f.t -> t -> t

  (** See vector3f. Type : vec3i. @see:OgamlMath.Vector3i *)
  val vector3i : string -> OgamlMath.Vector3i.t -> t -> t

  (** See vector3f. Type : vec2i. @see:OgamlMath.Vector2i *)
  val vector2i : string -> OgamlMath.Vector2i.t -> t -> t

  (** See vector3f. Type : int. *)
  val int : string -> int -> t -> t

  (** See vector3f. Type : float. *)
  val float : string -> float -> t -> t

  (** See vector3f. Type : mat3. @see:OgamlMath.Matrix3D *)
  val matrix3D : string -> OgamlMath.Matrix3D.t -> t -> t

  (** See vector3f. Type : mat2. @see:OgamlMath.Matrix2D *)
  val matrix2D : string -> OgamlMath.Matrix2D.t -> t -> t

  (** See vector3f. Type : vec4. @see:OgamlGraphics.Color *)
  val color : string -> Color.t -> t -> t

  (** See vector3f. Type : sampler2D.
   *
    * The optional parameter $tex_unit$ corresponds to the texture
    * unit that is used to bind this texture and defaults to $0$.
    * See $State.max_textures$ for the number of available units.
    * @see:OgamlGraphics.Texture.Texture2D *)
  val texture2D : string -> ?tex_unit:int -> Texture.Texture2D.t -> t -> t

end


(** High-level window wrapper for rendering and event management *)
module Window : sig

  (** This module provides a high-level wrapper around the low-level
    * window interface of OgamlCore and also provides drawing functions.
    *
    * Windows encapsulate a copy of the GL state that can be retrieved
    * to obtain information about the GL context. *)

  (*** Window creation *)
  (** The type of a window *)
  type t

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
    ?settings:OgamlCore.ContextSettings.t -> unit -> t

  (** Returns the settings used at the creation of the window *)
  val settings : t -> OgamlCore.ContextSettings.t

  (** Returns the internal GL state of the window
    * @see:OgamlGraphics.State *)
  val state : t -> State.t

  (** Changes the title of the window. *)
  val set_title : t -> string -> unit

  (** Closes a window, but does not free the memory.
    * This should prevent segfaults when calling functions on this window. *)
  val close : t -> unit

  (** Frees the window and the memory *)
  val destroy : t -> unit

  (** Resizes the window.
    * @see:OgamlMath.Vector2i *)
  val resize : t -> OgamlMath.Vector2i.t -> unit

  (** Toggles the full screen mode of a window. *)
  val toggle_fullscreen : t -> unit

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
    * Clears the depth buffer and the stencil buffer by default. *)
  val clear : ?color:Color.t option -> ?depth:bool -> ?stencil:bool -> t -> unit

  (** Show or hide the cursor *)
  val show_cursor : t -> bool -> unit

  (** Binds the window for drawing. This function is for internal use only. *)
  val bind : t -> DrawParameter.t -> unit

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

  (** $rebuild array src offset$ rebuilds $array$ starting from
    * the index at position $offset$ using $src$.
    *
    * The index array is modified in-place and is resized as needed.
    * @see:OgamlGraphics.IndexArray.Source *)
  val rebuild : dynamic t -> Source.t -> int -> unit

  (** Returns the length of an index array *)
  val length : 'a t -> int

end


(** High-level wrapper around OpenGL vertex arrays *)
module VertexArray : sig

  (** This modules provides a high-level and safe access to
    * openGL vertex arrays. Vertex arrays are used to store
    * vertices on the GPU and can be used to render 3D models. *)

  (** Raised when trying to rebuild a vertex array from an invalid source *)
  exception Invalid_source of string

  (** Raised if a vertex passed to a source has a wrong type *)
  exception Invalid_vertex of string

  (** Raised if an attribute defined in a GLSL program does not
    * have a type matching the vertex's *)
  exception Invalid_attribute of string

  (** Raised when trying to draw with a vertex array containing an
    * attribute that has not been declared in the GLSL program *)
  exception Missing_attribute of string

  (** Raised when trying to draw an invalid slice of a vertex array *)
  exception Out_of_bounds of string


  (** Represents a vertex *)
  module Vertex : sig

    (** This module encapsulates vertices that can be passed to
      * a source *)

    (** Type of a vertex *)
    type t

    (** Creates a vertex containing various optional attributes
      * @see:OgamlMath.Vector3f
      * @see:OgamlMath.Vector2f
      * @see:OgamlGraphics.Color *)
    val create : ?position:OgamlMath.Vector3f.t ->
                 ?texcoord:OgamlMath.Vector2f.t ->
                 ?normal:OgamlMath.Vector3f.t   ->
                 ?color:Color.t -> unit -> t

    (** Returns the (optional) position of a vertex *)
    val position : t -> OgamlMath.Vector3f.t option

    (** Returns the (optional) texture coordinates of a vertex *)
    val texcoord : t -> OgamlMath.Vector2f.t option

    (** Returns the (optional) normal of a vertex *)
    val normal : t -> OgamlMath.Vector3f.t option

    (** Returns the (optional) color of a vertex *)
    val color : t -> Color.t option

  end

  (** Represents a source of vertices *)
  module Source : sig

    (** This module provides a way to store vertices in a source
      * before creating a vertex array.
      *
      * Note that a source is a mutable structure, therefore
      * add and (<<) will directly modify the source.
      *
      * Sources are redimensionned as needed when adding vertices. *)

    (** Type of a source *)
    type t

    (** Creates an empty source of a given initial size. The source will
      * be redimensionned as needed.
      *
      * The optional arguments specify whether a source should expect vertices
      * having the corrsponding attributes, and the name of the attribute
      * in the GLSL program that will be used *)
    val empty : ?position:string ->
                ?normal  :string ->
                ?texcoord:string ->
                ?color   :string ->
                size:int -> unit -> t

    (** Returns true iff the source contains (and requests) vertices with
      * a position attribute *)
    val requires_position : t -> bool

    (** See requires_position *)
    val requires_normal   : t -> bool

    (** See requires_position *)
    val requires_uv : t -> bool

    (** See requires_position *)
    val requires_color : t -> bool

    (** Adds a vertex to a source. Resizes the source if needed.
      * @see:OgamlGraphics.VertexArray.Vertex *)
    val add : t -> Vertex.t -> unit

    (** Syntaxic sugar for sequences of additions. @see:OgamlGraphics.VertexArray.Vertex
      *
      * $source << vertex1 << vertex2 << vertex3$ *)
    val (<<) : t -> Vertex.t -> t

    (** Returns the length of a source *)
    val length : t -> int

    (** $append s1 s2$ appends the source $s2$ at the end of the source $s1$ (in place),
      * and returns $s1$.
      * If the attribute names are different, the names in the source $s1$ are used.
      * Raises Invalid_source if types are incompatible. *)
    val append : t -> t -> t

    (** $iter src f$ iterates through all the vertices of $src$ *)
    val iter : t -> (Vertex.t -> unit) -> unit

    (** $map src f$ returns the source obtained by the mapping of all the
      * vertices of $src$ by $f$.
      *
      * The resulting source is assumed to have the same attributes as
      * $src$. Use $iter$ or $mapto$ to use different attributes *)
    val map : t -> (Vertex.t -> Vertex.t) -> t

    (** $mapto src f dest$ appends the mapping of the vetices of $src$
      * by $f$ to $dest$ *)
    val mapto : t -> (Vertex.t -> Vertex.t) -> t -> unit

  end

  (** Phantom type for static arrays *)
  type static

  (** Phantom type for dynamic arrays *)
  type dynamic

  (** Type of a vertex array (static or dynamic) *)
  type 'a t

  type debug_times = {
    mutable param_bind_t : float;
    mutable program_bind_t : float;
    mutable uniform_bind_t : float;
    mutable vao_bind_t : float;
    mutable draw_t : float
  }

  val debug_t : debug_times

  (** Creates a static array from a source. A static array is faster
    * but cannot be modified later. @see:OgamlGraphics.VertexArray.Source *)
  val static : (module RenderTarget.T with type t = 'a) -> 'a -> Source.t -> static t

  (** Creates a dynamic vertex array that can be modified later.
    * @see:OgamlGraphics.VertexArray.Source *)
  val dynamic : (module RenderTarget.T with type t = 'a) -> 'a -> Source.t -> dynamic t

  (** $rebuild array src offset$ rebuilds $array$ starting from
    * the vertex at position $offset$ using $src$.
    *
    * The vertex array is modified in-place and is resized as needed.
    * @see:OgamlGraphics.VertexArray.Source *)
  val rebuild : dynamic t -> Source.t -> int -> unit

  (** Returns the length of a vertex array *)
  val length : 'a t -> int

  (** Draws the slice starting at $start$ of length $length$ of a vertex array on a
    * window using the given parameters.
    *
    * $start$ defaults to 0
    *
    * if $length$ is not provided, then the whole vertex array (starting from $start$) is drawn
    *
    * $uniform$ should provide the uniforms required by $program$ (defaults to empty)
    *
    * $parameters$ defaults to $DrawParameter.make ()$
    *
    * $mode$ defaults to $DrawMode.Triangles$
    *
    * @see:OgamlGraphics.IndexArray @see:OgamlGraphics.Window
    * @see:OgamlGraphics.Program @see:OgamlGraphics.Uniform
    * @see:OgamlGraphics.DrawParameter @see:OgamlGraphics.DrawMode *)
  val draw :
    (module RenderTarget.T with type t = 'a) ->
    vertices   : 'b t ->
    target     : 'a ->
    ?indices   : 'c IndexArray.t ->
    program    : Program.t ->
    ?uniform    : Uniform.t ->
    ?parameters : DrawParameter.t ->
    ?start     : int ->
    ?length    : int ->
    ?mode      : DrawMode.t ->
    unit -> unit

end


(** Customisable, high-level vertex arrays *)
module VertexMap : sig

  (** This modules provides a high-level and safe access to
    * openGL vertex arrays.
    * Vertex maps are less safe and optimized than vertex arrays,
    * but can store any kind of data (especially integers).
    * You should use the module VertexArray when possible. *)

  (** Raised when trying to rebuild a vertex map from an invalid source *)
  exception Invalid_source of string

  (** Raised if a vertex passed to a source has a wrong type *)
  exception Invalid_vertex of string

  (** Raised if an attribute defined in a GLSL program does not
    * have a type matching the vertex's *)
  exception Invalid_attribute of string

  (** Raised when trying to draw with a vertex map containing an
    * attribute that has not been declared in the GLSL program *)
  exception Missing_attribute of string

  (** Raised when trying to draw an invalid slice of a vertex map *)
  exception Out_of_bounds of string


  (** Represents a vertex *)
  module Vertex : sig

    (** This module encapsulates vertices that can be passed to
      * a source. A vertex is an immutable collection of
      * attributes. *)

    (** Type of a vertex attribute *)
    type data = 
      | Vector3f of OgamlMath.Vector3f.t
      | Vector2f of OgamlMath.Vector2f.t
      | Vector3i of OgamlMath.Vector3i.t
      | Vector2i of OgamlMath.Vector2i.t
      | Int   of int
      | Float of float
      | Color of Color.t

    (** Type of a vertex *)
    type t

    (** Empty vertex *)
    val empty : t

    (** Adds a vector3f to a vertex. The given name must match
      * the name of the vec3 attribute in the GLSL program
      * @see:OgamlMath.Vector3f *)
    val vector3f : string -> OgamlMath.Vector3f.t -> t -> t

    (** Adds a vector2f to a vertex. The given name must match
      * the name of the vec2 attribute in the GLSL program
      * @see:OgamlMath.Vector2f *)
    val vector2f : string -> OgamlMath.Vector2f.t -> t -> t

    (** Adds a vector3i to a vertex. The given name must match
      * the name of the ivec3 attribute in the GLSL program
      * @see:OgamlMath.Vector3i *)
    val vector3i : string -> OgamlMath.Vector3i.t -> t -> t

    (** Adds a vector2i to a vertex. The given name must match
      * the name of the ivec2 attribute in the GLSL program
      * @see:OgamlMath.Vector2i *)
    val vector2i : string -> OgamlMath.Vector2i.t -> t -> t

    (** Adds an integer to a vertex. The given name must match
      * the name of the int attribute in the GLSL program *)
    val int : string -> int -> t -> t

    (** Adds a float to a vertex. The given name must match
      * the name of the float attribute in the GLSL program *)
    val float : string -> float -> t -> t

    (** Adds a color to a vertex. The given name must match
      * the name of the vec4 attribute in the GLSL program
      * @see:OgamlGraphics.Color *)
    val color : string -> Color.t -> t -> t

    (** Adds any data to a vertex. The given name must match
      * the name of the corresponding attribute in the GLSL
      * program *)
    val data : string -> data -> t -> t

    (** Returns the value of a vertex attribute.
      * Raises $Invalid_attribute$ if the attribute is unbound *)
    val attribute : t -> string -> data

  end


  (** Represents a source of vertices *)
  module Source : sig

    (** This module provides a way to store vertices in a source
      * before creating a vertex map.
      *
      * Note that a source is a mutable structure, therefore
      * add and (<<) will directly modify the source.
      *
      * Sources are redimensionned as needed when adding vertices. *)

    (** Type of a source *)
    type t

    (** Creates an empty source of a given initial size. The source will
      * be redimensionned as needed.
      *
      * The type of the vertices stored by the source will be defined
      * by the first stored vertex. *)
    val empty : unit -> t

    (** Adds a vertex to a source. Resizes the source if needed.
      * @see:OgamlGraphics.VertexMap.Vertex *)
    val add : t -> Vertex.t -> unit

    (** Syntaxic sugar for sequences of additions. @see:OgamlGraphics.VertexMap.Vertex
      *
      * $source << vertex1 << vertex2 << vertex3$ *)
    val (<<) : t -> Vertex.t -> t

    (** Returns the length of a source *)
    val length : t -> int

    (** $append s1 s2$ appends the source $s2$ at the end of the source $s1$ (in place),
      * and returns $s1$.
      * Raises Invalid_source if types are incompatible. *)
    val append : t -> t -> t

    (** $iter src f$ iterates through all the vertices of $src$ *)
    val iter : t -> (Vertex.t -> unit) -> unit

    (** $map src f$ returns the source obtained by the mapping of all the
      * vertices of $src$ by $f$. *)
    val map : t -> (Vertex.t -> Vertex.t) -> t

    (** $mapto src f dest$ appends the mapping of the vetices of $src$
      * by $f$ to $dest$ *)
    val mapto : t -> (Vertex.t -> Vertex.t) -> t -> unit

    (** $from_array src$ creates a vertex map source equivalent to the
      * vertex array source $src$ *)
    val from_array : VertexArray.Source.t -> t

    (** $from_array src dest$ appends the vertex array source $src$ to the
      * vertex map source $dest$ *)
    val from_array_to : VertexArray.Source.t -> t -> unit

    (** $map_array src f$ creates a new vertex map source by mapping all the
      * vertices of the vertex array source $src$ by $f$ *)
    val map_array : VertexArray.Source.t -> (VertexArray.Vertex.t -> Vertex.t) -> t

    (** $map_array_to src f dest$ maps by $f$ and appends all the
      * vertices of the vertex array source $src$ to the vertex map source $dest$ *)
    val map_array_to : VertexArray.Source.t -> (VertexArray.Vertex.t -> Vertex.t) -> t -> unit

  end


  (** Phantom type for static maps *)
  type static

  (** Phantom type for dynamic maps *)
  type dynamic

  (** Type of a vertex map (static or dynamic) *)
  type 'a t

  (** Creates a static map from a source. A static map is faster
    * but cannot be modified later. @see:OgamlGraphics.VertexMap.Source *)
  val static : (module RenderTarget.T with type t = 'a) -> 'a -> Source.t -> static t

  (** Creates a dynamic vertex map that can be modified later.
    * @see:OgamlGraphics.VertexMap.Source *)
  val dynamic : (module RenderTarget.T with type t = 'a) -> 'a -> Source.t -> dynamic t

  (** $rebuild map src offset$ rebuilds $map$ starting from
    * the vertex at position $offset$ using $src$.
    *
    * The vertex map is modified in-place and is resized as needed.
    * @see:OgamlGraphics.VertexMap.Source *)
  val rebuild : dynamic t -> Source.t -> int -> unit

  (** Returns the length of a vertex map *)
  val length : 'a t -> int

  (** Draws the slice starting at $start$ of length $length$ of a vertex map on a
    * window using the given parameters.
    *
    * $start$ defaults to 0
    *
    * if $length$ is not provided, then the whole vertex map (starting from $start$) is drawn
    *
    * $uniform$ should provide the uniforms required by $program$ (defaults to empty)
    *
    * $parameters$ defaults to $DrawParameter.make ()$
    *
    * $mode$ defaults to $DrawMode.Triangles$
    *
    * @see:OgamlGraphics.IndexArray @see:OgamlGraphics.Window
    * @see:OgamlGraphics.Program @see:OgamlGraphics.Uniform
    * @see:OgamlGraphics.DrawParameter @see:OgamlGraphics.DrawMode *)
  val draw :
    (module RenderTarget.T with type t = 'a) ->
    vertices   : 'b t ->
    target     : 'a ->
    ?indices   : 'c IndexArray.t ->
    program    : Program.t ->
    ?uniform    : Uniform.t ->
    ?parameters : DrawParameter.t ->
    ?start      : int ->
    ?length     : int ->
    ?mode       : DrawMode.t ->
    unit -> unit

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


  (** Raised if an OBJ file is ill-formed or if a model has a wrong type *)
  exception Error of string

  (** Type of a model *)
  type t

  (*** Model creation *)

  (** Empty model *)
  val empty : t

  (** Returns the model associated to an OBJ file *)
  val from_obj : string -> t

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
  val source : t -> ?index_source:IndexArray.Source.t ->
                    vertex_source:VertexArray.Source.t -> unit -> unit


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
  val to_source : t -> VertexArray.Source.t -> unit

  (** Outputs a shape to a vertex array source by mapping its vertices.
    *
    * See $to_source$ for more information. *)
  val map_to_source : t -> 
                      (VertexArray.Vertex.t -> VertexArray.Vertex.t) -> 
                      VertexArray.Source.t -> unit

  (** Outputs a shape to a vertex map source by mapping its vertices.
    *
    * See $to_source$ for more information. *)
  val map_to_custom_source : t -> 
                      (VertexArray.Vertex.t -> VertexMap.Vertex.t) -> 
                      VertexMap.Source.t -> unit


end


(** Creation and manipulation of 2D sprites *)
module Sprite : sig

  (** Type of sprites *)
  type t

type debug_times = {
  mutable size_get_t : float;
  mutable uniform_create_t : float;
  mutable source_alloc_t : float;
  mutable vertices_create_t : float;
  mutable vao_create_t : float;
  mutable draw_t : float;
}

val debug_t : debug_times


  (** Creates a sprite. *)
  val create :
    texture   : Texture.Texture2D.t ->
    ?subrect  : OgamlMath.IntRect.t ->
    ?origin   : OgamlMath.Vector2f.t ->
    ?position : OgamlMath.Vector2f.t ->
    ?scale    : OgamlMath.Vector2f.t ->
    ?size     : OgamlMath.Vector2f.t ->
    ?rotation : float ->
    unit -> t

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

  (** Returns the scale of the sprite. *)
  val get_scale : t -> OgamlMath.Vector2f.t

  (*** Vertex array access *)

  (** Outputs a sprite to a vertex array source.
    * 
    * This outputs two triangles with UV coordinates
    * and position attributes.
    *
    * Use DrawMode.Triangles with this source. *)
  val to_source : t -> VertexArray.Source.t -> unit

  (** Outputs a sprite to a vertex array source by mapping its vertices.
    *
    * See $to_source$ for more information. *)
  val map_to_source : t -> 
                      (VertexArray.Vertex.t -> VertexArray.Vertex.t) -> 
                      VertexArray.Source.t -> unit

  (** Outputs a sprite to a vertex map source by mapping its vertices.
    *
    * See $to_source$ for more information. *)
  val map_to_custom_source : t -> 
                      (VertexArray.Vertex.t -> VertexMap.Vertex.t) -> 
                      VertexMap.Source.t -> unit

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
      unit -> unit

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
    bold : bool ->
    unit -> t

  (** Draws text on the screen. *)
  val draw :
    (module RenderTarget.T with type t = 'a) ->
    ?parameters : DrawParameter.t ->
    text : t ->
    target : 'a ->
    unit -> unit

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
  val to_source : t -> VertexArray.Source.t -> unit

  (** Outputs text vertices to a vertex array source by mapping its vertices.
    *
    * See $to_source$ for more information. *)
  val map_to_source : t -> 
                      (VertexArray.Vertex.t -> VertexArray.Vertex.t) -> 
                      VertexArray.Source.t -> unit

  (** Outputs text vertices to a vertex map source by mapping its vertices.
    *
    * See $to_source$ for more information. *)
  val map_to_custom_source : t -> 
                      (VertexArray.Vertex.t -> VertexMap.Vertex.t) -> 
                      VertexMap.Source.t -> unit


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


