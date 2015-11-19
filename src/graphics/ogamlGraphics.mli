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

  (** Clamps a color w.r.t RGB.clamp and HSV.clamp *)
  val clamp : t -> t

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
      | CullNone (* Culls no face *)
      | CullClockwise (* Culls all faces displayed in CW order from the camera POV *)
      | CullCounterClockwise (* Same with CCW *)

  end

  (** Polygon modes enumeration *)
  module PolygonMode : sig

    (** This module consists of only one type enumerating OpenGL polygon modes *)
    type t = 
      | DrawVertices (* Draws only vertices *)
      | DrawLines (* Draws only lines *)
      | DrawFill (* Draws full polygons *)

  end

  (** Creates a set of draw parameters 
    * @see:OgamlGraphics.DrawParameter.CullingMode
    * @see:OgamlGraphics.DrawParameter.PolygonMode *)
  val make : ?culling:CullingMode.t -> 
             ?polygon:PolygonMode.t ->
             ?depth_test:bool ->
             unit -> t

end


(** Image manipulation and creation *)
module Image : sig

  (** This module provides a safe way to load and access images stored in the RAM.
    * Images stored this way are uncompressed arrays of bytes and are therefore 
    * not meant to be stored in large quantities. *)

  (** Type of an image stored in the RAM *)
  type t

  (** Creates an image from a file, or an empty image with a given size filled with a default color
    * @see:OgamlGraphics.Color *)
  val create : [`File of string | `Empty of int * int * Color.t] -> t

  (** Return the size of an image *)
  val size : t -> (int * int)

  (** Sets a pixel of an image
    * @see:OgamlGraphics.Color *)
  val set : t -> int -> int -> Color.t -> unit

  (** Gets the color of a pixel of an image 
    * @see:OgamlGraphics.Color.RGB *)
  val get : t -> int -> int -> Color.RGB.t

end


(** High-level wrapper around OpenGL index arrays *)
module IndexArray : sig

  (** This modules provides a high-level and safe access to
    * openGL index arrays. Index arrays can be passed to 3D rendering
    * primitives and are used to render 3D models more efficiently. *)

  (** Raised when trying to access a destroyed buffer *)
  exception Invalid_buffer of string

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

  end

  (** Phantom type for static index arrays *)
  type static

  (** Phantom type for dynamic index arrays *)
  type dynamic

  (** Type of an index array (static or dynamic) *)
  type 'a t 

  (** Creates a static index array. A static array is faster but can not be modified after creation.
    * @see:OgamlGraphics.Source *)
  val static : Source.t -> static t

  (** Creates a dynamic index array that can be modified after creation.
    * @see:OgamlGraphics.Source *)
  val dynamic : Source.t -> dynamic t

  (** Rebuilds a dynamic index array from a source
    * @see:OgamlGraphics.Source *)
  val rebuild : dynamic t -> Source.t -> dynamic t

  (** Returns the length of an index array *)
  val length : 'a t -> int

  (** Destroys and free an index array from the memory *)
  val destroy : 'a t -> unit

end


(** High-level wrapper around OpenGL vertex arrays *)
module VertexArray : sig

  (** This modules provides a high-level and safe access to
    * openGL vertex arrays. Vertex arrays are used to store
    * vertices on the GPU and can be used to render 3D models. *)

  (** Raised when trying to access a destroyed array *)
  exception Invalid_buffer of string

  (** Raised if a vertex passed to a source has a wrong type *)
  exception Invalid_vertex of string

  (** Raised if an attribute defined in a GLSL program does not 
    * have a type matching the vertex's *)
  exception Invalid_attribute of string

  (** Raised when trying to draw with a vertex array containing an
    * attribute that has not been declared in the GLSL program *)
  exception Missing_attribute of string

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

    val add : t -> Vertex.t -> unit

    val (<<) : t -> Vertex.t -> t

    val length : t -> int

  end

  type static

  type dynamic

  type 'a t 

  val static : Source.t -> static t

  val dynamic : Source.t -> dynamic t

  val rebuild : dynamic t -> Source.t -> dynamic t

  val length : 'a t -> int

  val destroy : 'a t -> unit

end


(** Creation, loading and manipulation of 3D models *)
module Model : sig

  exception Invalid_model of string

  exception Bad_format of string

  type t

  type vertex

  type normal

  type uv

  type point

  type color

  val empty : unit -> t

  val from_obj : [`File of string | `String of string] -> t

  val scale : t -> float -> unit

  val translate : t -> OgamlMath.Vector3f.t -> unit

  val add_vertex : t -> OgamlMath.Vector3f.t -> vertex

  val add_normal : t -> OgamlMath.Vector3f.t -> normal

  val add_uv : t -> OgamlMath.Vector2f.t -> uv

  val add_color : t -> Color.t -> color

  val make_point : t -> vertex -> normal option -> uv option -> color option -> point

  val add_point : t -> vertex:OgamlMath.Vector3f.t ->
                      ?normal:OgamlMath.Vector3f.t ->
                      ?uv:OgamlMath.Vector2f.t -> 
                      ?color:Color.t -> unit -> point

  val make_face : t -> (point * point * point) -> unit

  val compute_normals : ?smooth:bool -> t -> unit

  val source : t -> ?index_source:IndexArray.Source.t ->
                    vertex_source:VertexArray.Source.t -> unit -> unit

end


(** Creation of basic polygons and polyhedra *)
module Poly : sig

  val cube : VertexArray.Source.t -> OgamlMath.Vector3f.t ->
             OgamlMath.Vector3f.t -> VertexArray.Source.t

  val axis : VertexArray.Source.t -> OgamlMath.Vector3f.t ->
             OgamlMath.Vector3f.t -> VertexArray.Source.t

end


(** Encapsulates data for context creation *)
module ContextSettings : sig

  (** Type of the settings structure *)
  type t

  (** Creates new settings using the following parameters : 
    *
    *   $color$ - background color used when clearing (defaults to opaque black) 
    *
    *   $clear_color$ - whether to clear the color buffer or not when calling clear (defaults to true) 
    *
    *   $depth$ - whether to clear the depth buffer or not when calling clear (defaults to true) 
    *
    *   $stencil$ - whether to clear the stencil buffer or not when calling clear (defaults to false) 
    *
    * @see:OgamlGraphics.Color
    *)
  val create : ?color:Color.t -> ?clear_color:bool -> 
               ?depth:bool -> ?stencil:bool -> unit -> t

end


(** Encapsulates data about an OpenGL internal state *)
module State : sig

  exception Invalid_texture_unit of int

  type t

  val version : t -> (int * int)

  val is_version_supported : t -> (int * int) -> bool

  val glsl_version : t -> int

  val is_glsl_version_supported : t -> int -> bool

  val culling_mode : t -> DrawParameter.CullingMode.t

  val polygon_mode : t -> DrawParameter.PolygonMode.t

  val depth_test : t -> bool

  val clear_color : t -> Color.t

end


(** High-level wrapper around GL shader programs *)
module Program : sig

  exception Compilation_error of string

  exception Linking_error of string

  exception Invalid_version of string

  type t

  type src = [`File of string | `String of string]

  val from_source : vertex_source:src -> fragment_source:src -> t

  val from_source_list : State.t 
                        -> vertex_source:(int * src) list  
                        -> fragment_source:(int * src) list -> t 

  val from_source_pp : State.t 
                      -> vertex_source:src
                      -> fragment_source:src -> t

end


(** High-level wrapper around GL textures *)
module Texture : sig

  (** Represents a simple 2D texture *)
  module Texture2D : sig

    type t

    val create : State.t -> [< `File of string | `Image of Image.t ] -> t

    val size : t -> (int * int)

  end

end


(** Encapsulates a group of uniforms for rendering *)
module Uniform : sig

  exception Unknown_uniform of string

  exception Invalid_uniform of string

  type t

  val empty : t

  val vector3f : string -> OgamlMath.Vector3f.t -> t -> t

  val vector2f : string -> OgamlMath.Vector2f.t -> t -> t

  val vector3i : string -> OgamlMath.Vector3i.t -> t -> t

  val vector2i : string -> OgamlMath.Vector2i.t -> t -> t

  val int : string -> int -> t -> t

  val float : string -> float -> t -> t

  val matrix3D : string -> OgamlMath.Matrix3D.t -> t -> t

  val color : string -> Color.t -> t -> t

  val texture2D : string -> Texture.Texture2D.t -> t -> t

end


(** High-level window wrapper for rendering and event management *)
module Window : sig

  (*** Error Handling *)
  (** Raised if a uniform variable is missing when calling draw *)
  exception Missing_uniform of string

  (** Raised when calling draw if a uniform variable has an incorrect type *)
  exception Invalid_uniform of string

  (** The type of a window *)
  type t

  (** Creates a window of size $width$ x $height$. 
    * This window will create its openGL context following the specified settings.
    * @see:OgamlGraphics.ContextSettings *)
  val create : width:int -> height:int -> settings:ContextSettings.t -> t

  (** Closes a window, but does not free the memory. 
    * This should prevent segfaults when calling functions on this window. *)
  val close : t -> unit

  (** Frees the window and the memory *)
  val destroy : t -> unit

  (*** Information About Windows *)
  (** Returns in pixel the width and height of the window 
    * (it only takes into account the size of the content where you can draw, *ie* the useful information). *)
  val size : t -> (int * int)

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

  (** Draws a vertex array using with the given program, uniforms, draw parameters, and an optional index array.
    * @see:OgamlGraphics.IndexArray @see:OgamlGraphics.VertexArray
    * @see:OgamlGraphics.Program @see:OgamlGraphics.Uniform 
    * @see:OgamlGraphics.DrawParameter @see:OgamlGraphics.DrawMode *)
  val draw : 
    window     : t -> 
    ?indices   : 'a IndexArray.t ->
    vertices   : 'b VertexArray.t -> 
    program    : Program.t -> 
    uniform    : Uniform.t ->
    parameters : DrawParameter.t ->
    mode       : DrawMode.t ->
    unit -> unit

  (** Clears the window *)
  val clear : t -> unit

  (** Returns the internal GL state of the window 
    * @see:OgamlGraphics.State *)
  val state : t -> State.t

end


(** Getting real-time mouse information *)
module Mouse : sig

  (*** Accessing position *)
  (** Returns the position of the cursor relatively to the screen.
    *
    * $let (x,y) = position ()$ assigns the number of pixels from the left of 
    * the screen to the cursor in $x$ and the number of pixels from the top in $y$
  *)
  val position : unit -> (int * int)

  (** Returns the position of the cursor relatively to a window.
    * @see:OgamlGraphics.Window *)
  val relative_position : Window.t -> (int * int)

  (*** Setting position *)
  (** Sets the position of the cursor relatively to the screen *)
  val set_position : (int * int) -> unit

  (** Sets the position of the cursor relatively to a window 
    * @see:OgamlGraphics.Window *)
  val set_relative_position : Window.t -> (int * int) -> unit

  (*** Accessing button information *)
  (** Check whether a given mouse button is currently held down
    * @see:OgamlCore.Button *)
  val is_pressed : OgamlCore.Button.t -> bool

end


(** Getting real-time keyboard information *)
module Keyboard : sig

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



