open Bigarray


val clear : color:bool -> depth:bool -> stencil:bool -> unit


module Data : sig

  type ('a, 'b) t = ('a, 'b, c_layout) Array1.t

  type ft = (float, float32_elt) t

  type it = (int32, int32_elt) t

  val create : int -> ('a, 'b) kind -> ('a, 'b) t

  val create_float : int -> ft

  val of_array : ('a, 'b) kind -> 'a array -> ('a, 'b) t

  val of_float_array : float array -> ft

  val size : ('a, 'b) t -> int

end


module VBO : sig

  type t

  val create : unit -> t

  val build : ('a, 'b) Data.t -> t

  val bind : t option -> unit

  val delete : t -> unit

  val set : t -> ('a, 'b) Data.t -> unit

end


module VAO : sig

  type t

  type types =
    | Byte
    | UByte
    | Short
    | UShort
    | Int
    | UInt
    | Float
    | Double

  type shape = 
    | Points
    | LineStrip
    | LineLoop
    | Lines
    | LineStripAdjacency
    | LinesAdjacency
    | TriangleStrip
    | TriangleFan
    | Triangles
    | TriangleStripAdjacency
    | TrianglesAdjacency
    | Patches

  val create : unit -> t

  val bind : t option -> unit

  val delete : t -> unit

  val enable_attrib : Program.attribute -> unit

  val set_attrib : 
      ?normalize:bool ->
      ?integer  :bool ->
      ?stride   :int  ->
      ?divisor  :int  ->
      attribute:Program.attribute ->
      size :int   ->
      kind :types ->
      offset:int  -> unit -> unit

  val draw : shape -> int -> int -> unit

end 


