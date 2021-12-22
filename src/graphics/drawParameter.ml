
(** Backface culling enumeration *)
module CullingMode = struct

  type t = 
    | CullNone
    | CullClockwise
    | CullCounterClockwise

end

(** Polygon drawing mode enumeration *)
module PolygonMode = struct

  type t = 
    | DrawVertices
    | DrawLines
    | DrawFill

end

module Viewport = struct

  type t = 
    | Full
    | Relative of OgamlMath.FloatRect.t
    | Absolute of OgamlMath.IntRect.t

end

module BlendMode = struct

  module Factor = struct

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

  module Equation = struct 

    type t = 
      | None
      | Add of Factor.t * Factor.t
      | Sub of Factor.t * Factor.t

  end

  type t = {color : Equation.t; alpha : Equation.t}

  let default = {
    color = Equation.None;
    alpha = Equation.None
  }
  
  let alpha = {
    color = Equation.Add (Factor.SrcAlpha, Factor.OneMinusSrcAlpha);
    alpha = Equation.Add (Factor.SrcAlpha, Factor.OneMinusSrcAlpha)
  }

  let additive = {
    color = Equation.Add (Factor.One,Factor.One);
    alpha = Equation.Add (Factor.One,Factor.One)
  }

  let soft_additive = {
    color = Equation.Add (Factor.OneMinusDestColor,Factor.One);
    alpha = Equation.Add (Factor.OneMinusDestColor,Factor.One)
  }

  let premultiplied_alpha = {
    color = Equation.Add (Factor.One, Factor.OneMinusSrcAlpha);
    alpha = Equation.Add (Factor.One, Factor.Zero)
  }

end


module DepthTest = struct

  type t = 
    | None
    | Always
    | Never
    | Less
    | Greater
    | Equal
    | LEqual
    | GEqual
    | NEqual

end


module Query = struct

  module LL = struct

    type gl_query

    (* Query creation is delayed to ensure the context is initialized before
     * generating query objects *)
    type t = {
      mutable query : gl_query option;
      target : GLTypes.Query.t
    }

    external create : unit -> gl_query = "caml_create_query"

    external begin_query : GLTypes.Query.t -> gl_query -> unit = "caml_begin_query"

    external end_query : GLTypes.Query.t -> unit = "caml_end_query"

    external get_query_result : gl_query -> int = "caml_get_query_result"

    external get_query_result_no_wait : gl_query -> int = "caml_get_query_result_no_wait"

    let begin_ t =
      let query =
        match t.query with
        | Some q -> q
        | None ->
          let q = create () in
          t.query <- Some q;
          q
      in
      begin_query t.target query

    let end_ t =
      end_query t.target

    let get ~wait t =
      match t.query with
      | Some query ->
        if wait then
          get_query_result query
        else
          get_query_result_no_wait query
      | None -> 0

  end

  module SamplesPassed = struct
    
    type t = LL.t

    let create () = {LL.query = None; target = GLTypes.Query.SamplesPassed}

    let get ?(wait=true) t =
      LL.get ~wait t

  end

  module AnySamplesPassed = struct
    
    type t = LL.t

    let create () = {LL.query = None; target = GLTypes.Query.AnySamplesPassed}

    let get ?(wait=true) t =
      LL.get ~wait t = 1

  end

  module PrimitivesGenerated = struct
    
    type t = LL.t

    let create () = {LL.query = None; target = GLTypes.Query.PrimitivesGenerated}

    let get ?(wait=true) t =
      LL.get ~wait t

  end

  module TimeElapsed = struct
    
    type t = LL.t

    let create () = {LL.query = None; target = GLTypes.Query.TimeElapsed}

    let get ?(wait=true) t =
      float (LL.get ~wait t) /. 1000000000.

  end

end


type t = {
  culling : CullingMode.t;
  polygon : PolygonMode.t;
  depth   : DepthTest.t;
  depth_write : bool;
  color_write : bool * bool * bool * bool;
  blend   : BlendMode.t;
  viewport: Viewport.t;
  aa      : bool;
  samples : Query.SamplesPassed.t option;
  any_samples : Query.AnySamplesPassed.t option;
  primitives : Query.PrimitivesGenerated.t option;
  time : Query.TimeElapsed.t option;
  polygon_offset : (float * float) option
}

let make ?culling:(culling = CullingMode.CullNone)
         ?polygon:(polygon = PolygonMode.DrawFill) 
         ?depth_test:(depth_test = DepthTest.Less)
         ?depth_write:(depth_write = true)
         ?color_write:(color_write = (true, true, true, true))
         ?blend_mode:(blend_mode = BlendMode.default)
         ?viewport:(viewport = Viewport.Full)
         ?antialiasing:(antialiasing = true)
         ?samples_query:samples
         ?any_samples_query:any_samples
         ?primitives_query:primitives
         ?time_query:time
         ?polygon_offset
         () = 
  { culling; polygon; depth = depth_test; depth_write; color_write;
  blend = blend_mode; viewport; aa = antialiasing;
  samples; any_samples; primitives; time; polygon_offset}

let culling t = t.culling

let polygon t = t.polygon

let depth_test t = t.depth

let depth_write t = t.depth_write

let color_write t = t.color_write

let blend_mode t = t.blend

let viewport t = t.viewport

let antialiasing t = t.aa

let samples_query t = t.samples

let any_samples_query t = t.any_samples

let primitives_query t = t.primitives

let time_query t = t.time

let polygon_offset t = t.polygon_offset
