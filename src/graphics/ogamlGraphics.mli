 
module Color : sig

  module RGB : sig

    type t = {r : float; g : float; b : float; a : float}

    val black : t

    val white : t

    val red : t

    val green : t

    val blue : t

    val yellow : t

    val magenta : t

    val cyan : t

    val transparent : t

    val clamp : t -> t

  end


  module HSV : sig

    type t = {h : float; s : float; v : float; a : float}

    val black : t

    val white : t

    val red : t

    val green : t

    val blue : t

    val yellow : t

    val magenta : t

    val cyan : t

    val transparent : t

    val clamp : t -> t

  end


  type t = [`HSV of HSV.t | `RGB of RGB.t]


  val rgb_to_hsv : RGB.t -> HSV.t

  val hsv_to_rgb : HSV.t -> RGB.t

  val hsv : t -> HSV.t

  val rgb : t -> RGB.t

  val clamp : t -> t

end


module DrawMode : sig

  type t =
    | TriangleStrip
    | TriangleFan
    | Triangles
    | Lines

end


module DrawParameter : sig

  type t

  module CullingMode : sig

    type t = 
      | CullNone
      | CullClockwise
      | CullCounterClockwise

  end

  module PolygonMode : sig

    type t = 
      | DrawVertices
      | DrawLines
      | DrawFill

  end

  val make : ?culling:CullingMode.t -> 
             ?polygon:PolygonMode.t ->
             ?depth_test:bool ->
             unit -> t

end


module Image : sig

  type t

  val create : [`File of string | `Empty of int * int * Color.t] -> t

  val size : t -> (int * int)

  val set : t -> int -> int -> Color.t -> unit

  val get : t -> int -> int -> Color.RGB.t

  val data : t -> Bytes.t

end


module IndexArray : sig

  exception Invalid_buffer of string

  module Source : sig

    type t

    val empty : int -> t

    val add : t -> int -> unit

    val (<<) : t -> int -> t

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


module VertexArray : sig

  exception Invalid_buffer of string

  exception Invalid_vertex of string

  exception Invalid_attribute of string

  exception Missing_attribute of string

  module Vertex : sig

    type t

    val create : ?position:OgamlMath.Vector3f.t ->
                ?texcoord:OgamlMath.Vector2f.t ->
                ?normal:OgamlMath.Vector3f.t   ->
                ?color:Color.t -> unit -> t

  end


  module Source : sig

    type t

    val empty : ?position:string -> 
                ?normal  :string -> 
                ?texcoord:string ->
                ?color   :string ->
                size:int -> unit -> t

    val requires_position : t -> bool

    val requires_normal   : t -> bool

    val requires_uv : t -> bool

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


module Poly : sig

  val cube : VertexArray.Source.t -> OgamlMath.Vector3f.t ->
             OgamlMath.Vector3f.t -> VertexArray.Source.t

  val axis : VertexArray.Source.t -> OgamlMath.Vector3f.t ->
             OgamlMath.Vector3f.t -> VertexArray.Source.t

end


module ContextSettings : sig

  type t

  val create : ?color:Color.t -> ?clear_color:bool -> 
               ?depth:bool -> ?stencil:bool -> unit -> t

end


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


module Texture : sig

  module Texture2D : sig

    type t

    val create : State.t -> [< `File of string | `Image of Image.t ] -> t

    val size : t -> (int * int)

  end

end


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


module Window : sig

  exception Missing_uniform of string

  exception Invalid_uniform of string

  type t

  val create : width:int -> height:int -> settings:ContextSettings.t -> t

  val close : t -> unit

  val destroy : t -> unit

  val size : t -> (int * int)

  val is_open : t -> bool

  val has_focus : t -> bool

  val poll_event : t -> OgamlCore.Event.t option

  val display : t -> unit

  val draw : 
    window     : t -> 
    ?indices   : 'a IndexArray.t ->
    vertices   : 'b VertexArray.t -> 
    program    : Program.t -> 
    uniform    : Uniform.t ->
    parameters : DrawParameter.t ->
    mode       : DrawMode.t ->
    unit -> unit

  val clear : t -> unit

  val state : t -> State.t

end


module Mouse : sig

  val position : unit -> (int * int)

  val relative_position : Window.t -> (int * int)

  val set_position : (int * int) -> unit

  val set_relative_position : Window.t -> (int * int) -> unit

  val is_pressed : OgamlCore.Button.t -> bool

end


module Keyboard : sig

  val is_pressed : OgamlCore.Keycode.t -> bool

  val is_shift_down : unit -> bool

  val is_ctrl_down : unit -> bool

  val is_alt_down : unit -> bool

end



