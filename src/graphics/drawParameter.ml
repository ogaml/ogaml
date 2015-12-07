
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

end


type t = {
  culling : CullingMode.t;
  polygon : PolygonMode.t;
  depth   : bool;
  blend   : BlendMode.t;
  viewport: Viewport.t
}

let make ?culling:(culling = CullingMode.CullNone)
         ?polygon:(polygon = PolygonMode.DrawFill) 
         ?depth_test:(depth_test = false)
         ?blend_mode:(blend_mode = BlendMode.default)
         ?viewport:(viewport = Viewport.Full)
         () = 
  { culling; polygon; depth = depth_test; blend = blend_mode; viewport}

let culling t = t.culling

let polygon t = t.polygon

let depth_test t = t.depth

let blend_mode t = t.blend

let viewport t = t.viewport
