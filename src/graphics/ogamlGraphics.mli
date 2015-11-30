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

    (** Polygon drawing modes *)
    type t =
      | DrawVertices (* Draws only vertices *)
      | DrawLines (* Draws only lines *)
      | DrawFill (* Draws full polygons *)

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

  (** Creates a set of draw parameters
    * @see:OgamlGraphics.DrawParameter.CullingMode
    * @see:OgamlGraphics.DrawParameter.PolygonMode
    * @see:OgamlGraphics.DrawParameter.BlendMode *)
  val make : ?culling:CullingMode.t ->
             ?polygon:PolygonMode.t ->
             ?depth_test:bool ->
             ?blend_mode:BlendMode.t ->
             unit -> t

end


(** Encapsulates data for context creation *)
module ContextSettings : sig

  (** This module encapsulates the settings used to create a GL context *)

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

  (** This module encapsulates a copy of the internal GL state.
    * This allows efficient optimizations of state changes *)

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


(** High-level wrapper around GL textures *)
module Texture : sig

  (** This module provides wrappers around different kinds
    * of OpenGL textures *)

  (** Represents a simple 2D texture *)
  module Texture2D : sig

    (** This modules provides an abstraction of openGL 2D textures
      * that can be used for 2D rendering (with sprites) or
      * 3D rendering when passed to a GLSL program. *)

    (** Type of a 2D texture *)
    type t

    (** Creates a texture from a state and a source (a file or an image)
      * @see:OgamlGraphics.State *)
    val create : State.t -> [< `File of string | `Image of Image.t ] -> t

    (** Returns the size of a texture *)
    val size : t -> (int * int)

  end

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

  (** Compiles a program from a vertex source and a fragment source.
    * The source must begin with a version assigment $#version xxx$ *)
  val from_source : vertex_source:src -> fragment_source:src -> t

  (** Compiles a program from a state (gotten from a window) and
    * a list of sources paired with their required GLSL version.
    * The function will chose the best source for the current context.
    * @see:OgamlGraphics.State *)
  val from_source_list : State.t
                        -> vertex_source:(int * src) list
                        -> fragment_source:(int * src) list -> t

  (** Compiles a program from a vertex source and a fragment source.
    * The source should not begin with a $#version xxx$ assignment,
    * as the function will preprocess the sources and prepend the
    * best version declaration.
    * @see:OgamlGraphics.State *)
  val from_source_pp : State.t
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
    * The uniform should be refered to as $name$ in a GLSL program.
    * @see:OgamlMath.Vector3f *)
  val vector3f : string -> OgamlMath.Vector3f.t -> t -> t

  (** See vector3f @see:OgamlMath.Vector2f *)
  val vector2f : string -> OgamlMath.Vector2f.t -> t -> t

  (** See vector3f @see:OgamlMath.Vector3i *)
  val vector3i : string -> OgamlMath.Vector3i.t -> t -> t

  (** See vector3f @see:OgamlMath.Vector2i *)
  val vector2i : string -> OgamlMath.Vector2i.t -> t -> t

  (** See vector3f *)
  val int : string -> int -> t -> t

  (** See vector3f *)
  val float : string -> float -> t -> t

  (** See vector3f @see:OgamlMath.Matrix3D *)
  val matrix3D : string -> OgamlMath.Matrix3D.t -> t -> t

  (** See vector3f @see:OgamlGraphics.Color *)
  val color : string -> Color.t -> t -> t

  (** See vector3f @see:OgamlGraphics.Texture.Texture2D *)
  val texture2D : string -> Texture.Texture2D.t -> t -> t

end


(** High-level window wrapper for rendering and event management *)
module Window : sig

  (** This module provides a high-level wrapper around the low-level
    * window interface of OgamlCore and also provides drawing functions.
    *
    * Windows encapsulate a copy of the GL state that can be retrieved
    * to obtain information about the GL context. *)

  (*** Error Handling *)
  (** Raised if a uniform variable is missing when calling draw *)
  exception Missing_uniform of string

  (** Raised when calling draw if a uniform variable has an incorrect type *)
  exception Invalid_uniform of string

  (*** Window creation *)
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

  (** Clears the window *)
  val clear : t -> unit

  (** Returns the internal GL state of the window
    * @see:OgamlGraphics.State *)
  val state : t -> State.t

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

  end

  (** Phantom type for static index arrays *)
  type static

  (** Phantom type for dynamic index arrays *)
  type dynamic

  (** Type of an index array (static or dynamic) *)
  type 'a t

  (** Creates a static index array. A static array is faster but can not be modified after creation.
    * @see:OgamlGraphics.IndexArray.Source *)
  val static : Source.t -> static t

  (** Creates a dynamic index array that can be modified after creation.
    * @see:OgamlGraphics.IndexArray.Source *)
  val dynamic : Source.t -> dynamic t

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

    (** Adds a vertex to a source. Resizes the source if needed.
      * @see:OgamlGraphics.VertexArray.Vertex *)
    val add : t -> Vertex.t -> unit

    (** Syntaxic sugar for sequences of additions. @see:OgamlGraphics.VertexArray.Vertex
      *
      * $source << vertex1 << vertex2 << vertex3$ *)
    val (<<) : t -> Vertex.t -> t

    (** Returns the length of a source *)
    val length : t -> int

  end

  (** Phantom type for static arrays *)
  type static

  (** Phantom type for dynamic arrays *)
  type dynamic

  (** Type of a vertex array (static or dynamic) *)
  type 'a t

  (** Creates a static array from a source. A static array is faster
    * but cannot be modified later. @see:OgamlGraphics.VertexArray.Source *)
  val static : Source.t -> static t

  (** Creates a dynamic vertex array that can be modified later.
    * @see:OgamlGraphics.VertexArray.Source *)
  val dynamic : Source.t -> dynamic t

  (** $rebuild array src offset$ rebuilds $array$ starting from
    * the vertex at position $offset$ using $src$.
    *
    * The vertex array is modified in-place and is resized as needed.
    * @see:OgamlGraphics.VertexArray.Source *)
  val rebuild : dynamic t -> Source.t -> int -> unit

  (** Returns the length of a vertex array *)
  val length : 'a t -> int

  (** Draws a vertex array using the given program, uniforms, draw parameters, and an optional index array.
    * @see:OgamlGraphics.IndexArray @see:OgamlGraphics.Window
    * @see:OgamlGraphics.Program @see:OgamlGraphics.Uniform
    * @see:OgamlGraphics.DrawParameter @see:OgamlGraphics.DrawMode *)
  val draw :
    vertices   : 'a t ->
    window     : Window.t ->
    ?indices   : 'b IndexArray.t ->
    program    : Program.t ->
    uniform    : Uniform.t ->
    parameters : DrawParameter.t ->
    mode       : DrawMode.t ->
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

  (** Represents a vertex *)
  module Vertex : sig

    (** This module encapsulates vertices that can be passed to
      * a source. A vertex is an immutable collection of
      * attributes. *)

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

  end

  (** Phantom type for static maps *)
  type static

  (** Phantom type for dynamic maps *)
  type dynamic

  (** Type of a vertex map (static or dynamic) *)
  type 'a t

  (** Creates a static map from a source. A static map is faster
    * but cannot be modified later. @see:OgamlGraphics.VertexMap.Source *)
  val static : Source.t -> static t

  (** Creates a dynamic vertex map that can be modified later.
    * @see:OgamlGraphics.VertexMap.Source *)
  val dynamic : Source.t -> dynamic t

  (** $rebuild map src offset$ rebuilds $map$ starting from
    * the vertex at position $offset$ using $src$.
    *
    * The vertex map is modified in-place and is resized as needed.
    * @see:OgamlGraphics.VertexMap.Source *)
  val rebuild : dynamic t -> Source.t -> int -> unit

  (** Returns the length of a vertex map *)
  val length : 'a t -> int

  (** Draws a vertex map using the given program, uniforms, draw parameters, and an optional index array.
    * @see:OgamlGraphics.IndexArray @see:OgamlGraphics.Window
    * @see:OgamlGraphics.Program @see:OgamlGraphics.Uniform
    * @see:OgamlGraphics.DrawParameter @see:OgamlGraphics.DrawMode *)
  val draw :
    vertices   : 'a t ->
    window     : Window.t ->
    ?indices   : 'b IndexArray.t ->
    program    : Program.t ->
    uniform    : Uniform.t ->
    parameters : DrawParameter.t ->
    mode       : DrawMode.t ->
    unit -> unit

end


(** Creation, loading and manipulation of 3D models *)
module Model : sig

  (** This module provides helpers to manipulate and load
    * 3D models in the RAM.
    *
    * Models stored in that form are not RAM-friendly, and
    * should not be stored in large numbers. Use vertex arrays
    * instead. *)

  (** Raised when trying to put a model in a vertex source
    * and the model is missing an attribute required by the source *)
  exception Invalid_model of string

  (** Raised when trying to parse an invalid obj file *)
  exception Bad_format of string

  (** Type of a model *)
  type t

  (** Type of a vertex location in a model *)
  type vertex

  (** Type of a normal location in a model *)
  type normal

  (** Type of an uv location in a model *)
  type uv

  (** Type of a point location in a model *)
  type point

  (** Type of a color location in a model *)
  type color

  (** Creates an empty model *)
  val empty : unit -> t

  (** Creates a model from an OBJ file or string *)
  val from_obj : [`File of string | `String of string] -> t

  (** Scales a model (in place) *)
  val scale : t -> float -> unit

  (** Translates a model @see:OgamlMath.Vector3f *)
  val translate : t -> OgamlMath.Vector3f.t -> unit

  (** Adds a vertex to a model @see:OgamlMath.Vector3f
    * and returns its location *)
  val add_vertex : t -> OgamlMath.Vector3f.t -> vertex

  (** Adds a normal to a model @see:OgamlMath.Vector3f
    * and returns its location *)
  val add_normal : t -> OgamlMath.Vector3f.t -> normal

  (** Adds some UV coordinates to a model @see:OgamlMath.Vector2f
    * and returns its location *)
  val add_uv : t -> OgamlMath.Vector2f.t -> uv

  (** Adds a color to a model @see:OgamlGraphics.Color
    * and returns its location *)
  val add_color : t -> Color.t -> color

  (** Adds a point formed by a position location and optional parameters
    * to a model and returns its location *)
  val make_point : t -> vertex -> normal option -> uv option -> color option -> point

  (** Similar to make_point but also adds the corresponding
    * parameters to the model, and returns the point location
    * @see:OgamlMath.Vector3f
    * @see:OgamlMath.Vector2f
    * @see:OgamlGraphics.Color *)
  val add_point : t -> vertex:OgamlMath.Vector3f.t ->
                      ?normal:OgamlMath.Vector3f.t ->
                      ?uv:OgamlMath.Vector2f.t ->
                      ?color:Color.t -> unit -> point

  (** Constructs a face from three point locations *)
  val make_face : t -> (point * point * point) -> unit

  (** (Re-)computes the normals of a model. If $smooth$ is $true$,
    * then the normals are computed per-vertex instead of per-face *)
  val compute_normals : ?smooth:bool -> t -> unit

  (** Appends a model to a vertex source. Uses indexing if an index source is provided.
    * Use Triangles as DrawMode with this source.
    * @see:OgamlGraphics.IndexArray.Source
    * @see:OgamlGraphics.VertexArray.Source *)
  val source : t -> ?index_source:IndexArray.Source.t ->
                    vertex_source:VertexArray.Source.t -> unit -> unit

end


(** Creation of basic polygons and polyhedra *)
module Poly : sig

  (** This module provides helper functions that construct
    * various polygons and polyhedra *)

  (** $cube source corner size$ appends to $source$ some CCW-oriented
    * triangles forming a cube whose bottom-left-back vertex is $corner$ and of
    * a given $size$. Use Triangles as DrawMode with this source.
    * @see:OgamlGraphics.VertexArray.Source
    * @see:OgamlMath.Vector3f *)
  val cube : VertexArray.Source.t -> OgamlMath.Vector3f.t ->
             OgamlMath.Vector3f.t -> VertexArray.Source.t

  (** $axis source min max$ appends to $source$ 3 axis going
    * from $min.x$ to $max.x$, $min.y$ to $max.y$ and $min.z$ to $max.z$.
    * Use Lines as DrawMode with this source.
    * @see:OgamlGraphics.VertexArray.Source
    * @see:OgamlMath.Vector3f *)
  val axis : VertexArray.Source.t -> OgamlMath.Vector3f.t ->
             OgamlMath.Vector3f.t -> VertexArray.Source.t

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
    ?position     : OgamlMath.Vector2i.t ->
    ?scale        : OgamlMath.Vector2f.t ->
    ?rotation     : float ->
    ?thickness    : float ->
    ?border_color : Color.t ->
    unit -> t

  (** Creates a rectangle.
    * Its origin is positioned with respect to the top-left corner. *)
  val create_rectangle :
    position      : OgamlMath.Vector2i.t ->
    size          : OgamlMath.Vector2i.t ->
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
    position      : OgamlMath.Vector2i.t ->
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
    ?top      : OgamlMath.Vector2i.t ->
    tip       : OgamlMath.Vector2i.t ->
    ?position : OgamlMath.Vector2i.t ->
    ?origin   : OgamlMath.Vector2f.t ->
    ?rotation : float ->
    unit -> t

  (** Draws a shape. *)
  val draw : window:Window.t -> shape:t -> unit

  (** Sets the position of the origin in the window. *)
  val set_position : t -> OgamlMath.Vector2i.t -> unit

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
  val translate : t -> OgamlMath.Vector2i.t -> unit

  (** Rotates the shape by the given angle. *)
  val rotate : t -> float -> unit

  (** Scales the shape. *)
  val scale : t -> OgamlMath.Vector2f.t -> unit

  (** Returns the position of the origin in window coordinates. *)
  val get_position : t -> OgamlMath.Vector2i.t

  (** Returns the position of the origin with respect to the first point of the
    * shape. *)
  val get_origin : t -> OgamlMath.Vector2f.t

  (** Returns the angle of rotation of the shape. *)
  val get_rotation : t -> float

  (** Returns the scale of the shape. *)
  val get_scale : t -> OgamlMath.Vector2f.t

  (** Returns the thickness of the outline. *)
  val get_thickness : t -> float

  (** Returns the filling color of the shape. *)
  val get_color : t -> Color.t

end

(** Creation and manipulation of 2D sprites *)
module Sprite : sig

  (** Type of sprites *)
  type t

  (** Creates a sprite. *)
  val create :
    texture   : Texture.Texture2D.t ->
    ?origin   : OgamlMath.Vector2f.t ->
    ?position : OgamlMath.Vector2i.t ->
    ?scale    : OgamlMath.Vector2f.t ->
    ?rotation : float ->
    unit -> t

  (** Draws a sprite. *)
  val draw : window:Window.t -> sprite:t -> unit

  (** Sets the position of the origin of the sprite in the window. *)
  val set_position : t -> OgamlMath.Vector2i.t -> unit

  (** Sets the position of the origin with respect to the top-left corner of the
    * sprite. The origin is the center of all transformations. *)
  val set_origin : t -> OgamlMath.Vector2f.t -> unit

  (** Sets the angle of rotation of the sprite. *)
  val set_rotation : t -> float -> unit

  (** Sets the scale of the sprite. *)
  val set_scale : t -> OgamlMath.Vector2f.t -> unit

  (** Translates the sprite by the given vector. *)
  val translate : t -> OgamlMath.Vector2i.t -> unit

  (** Rotates the sprite by the given angle. *)
  val rotate : t -> float -> unit

  (** Scales the sprite. *)
  val scale : t -> OgamlMath.Vector2f.t -> unit

  (** Returns the position of the origin in window coordinates. *)
  val get_position : t -> OgamlMath.Vector2i.t

  (** Returns the position of the origin with respect to the first point of the
    * sprite. *)
  val get_origin : t -> OgamlMath.Vector2f.t

  (** Returns the angle of rotation of the sprite. *)
  val get_rotation : t -> float

  (** Returns the scale of the sprite. *)
  val get_scale : t -> OgamlMath.Vector2f.t

end



(** Getting real-time mouse information *)
module Mouse : sig

  (** This module allows real-time access to the mouse,
    * to check if a button is currently pressed for example. *)

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
