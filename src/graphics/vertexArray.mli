
module Vertex : sig

  type 'a t


  module AttributeType : sig

    type 'a s

    val int : int s

    val vector2i : OgamlMath.Vector2i.t s

    val vector3i : OgamlMath.Vector3i.t s

    val float : float s

    val vector2f : OgamlMath.Vector2f.t s

    val vector3f : OgamlMath.Vector3f.t s

    val color : Color.t s

  end


  module Attribute : sig

    type ('a, 'b) s

    val set : 'b t -> ('a, 'b) s -> 'a -> unit

    val get : 'b t -> ('a, 'b) s -> ('a, [> `Unbound_attribute of string]) result

    val name : ('a, 'b) s -> string

    val divisor : ('a, 'b) s -> int

    val atype : ('a, 'b) s -> 'a AttributeType.s

  end


  module type VERTEX = sig

    type s

    val attribute : string -> ?divisor:int -> 'a AttributeType.s ->
      (('a, s) Attribute.s, [> `Sealed_vertex | `Duplicate_attribute]) result

    val seal : unit -> (unit, [> `Sealed_vertex]) result

    val create : unit -> (s t, [> `Unsealed_vertex]) result

    val copy : s t -> s t

  end


  val make : unit -> (module VERTEX)

end


module SimpleVertex : sig

  module T : Vertex.VERTEX

  val create : 
    ?position:OgamlMath.Vector3f.t ->
    ?color:Color.t ->
    ?uv:OgamlMath.Vector2f.t ->
    ?normal:OgamlMath.Vector3f.t -> unit -> T.s Vertex.t

  val position : (OgamlMath.Vector3f.t, T.s) Vertex.Attribute.s

  val color : (Color.t, T.s) Vertex.Attribute.s

  val uv : (OgamlMath.Vector2f.t, T.s) Vertex.Attribute.s

  val normal : (OgamlMath.Vector3f.t, T.s) Vertex.Attribute.s

end


module Source : sig

  type 'a t

  val empty : ?size:int -> unit -> 'a t

  val add : 'a t -> 'a Vertex.t -> (unit, [> `Missing_attribute of string]) result

  val (<<) : 'a t -> 'a Vertex.t -> ('a t, [> `Missing_attribute of string]) result

  val (<<<) : ('a t, [> `Missing_attribute of string] as 'b) result -> 'a Vertex.t -> 
    ('a t, 'b) result

  val length : 'a t -> int

  val clear : 'a t -> unit

  val append : 'a t -> 'a t -> (unit, [> `Incompatible_fields]) result

  val iter : 'a t -> ?start:int -> ?length:int -> ('a Vertex.t -> unit) -> unit

  val map : 'a t -> ?start:int -> ?length:int -> ('a Vertex.t -> 'b Vertex.t) -> 
    ('b t, [> `Missing_attribute of string]) result

  val map_to : 'a t -> ?start:int -> ?length:int -> ('a Vertex.t -> 'b Vertex.t) -> 'b t -> 
    (unit, [> `Missing_attribute of string]) result

end


module Buffer : sig

  type static
  
  type dynamic
 
  type ('a, 'b) t 

  type unpacked
  
  val static : (module RenderTarget.T with type t = 'a) 
                -> 'a -> 'b Source.t -> (static, 'b) t
  
  val dynamic : (module RenderTarget.T with type t = 'a) 
                 -> 'a -> 'b Source.t -> (dynamic, 'b) t
 
  val length : (_, _) t -> int

  val blit    : (module RenderTarget.T with type t = 'a) ->
                 'a -> (dynamic, 'b) t ->
                 ?first:int -> ?length:int ->
                 'b Source.t -> 
                 (unit, [> `Invalid_start | `Invalid_length | `Incompatible_sources]) result

  val unpack : (_, _) t -> unpacked

end

type t

val create : (module RenderTarget.T with type t = 'a) -> 'a -> Buffer.unpacked list -> t

(* Number of vertices in the array (0 if all the data is instanced) *)
val length : t -> int

(* Maximal number of drawable instances. None if non-instanced *)
val max_instances : t -> int option

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
                 | `Too_many_textures
                 | `Duplicate_draw_buffer
                 | `Too_many_draw_buffers
                 | `Invalid_color_buffer]) result

