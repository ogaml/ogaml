type capability = 
  | ClipDistance of int
  | Blend
  | ColorLogicOp
  | CullFace
  | DepthClamp
  | DepthTest
  | Dither
  | FramebufferSRGB
  | LineSmooth
  | Multisample
  | PolygonOffsetFill
  | PolygonOffsetLine
  | PolygonOffsetPoint
  | PolygonSmooth
  | PrimitiveRestart
  | RasterizerDiscard
  | SampleAlphaToCoverage
  | SampleAlphaToOne
  | SampleCoverage
  | SampleShading
  | SampleMask
  | ScissorTest
  | StencilTest
  | TextureCubeMapSeamless
  | ProgramPointSize

val enable : capability list -> unit

val disable : capability list -> unit

type face = 
  | Back
  | Front
  | Both

val set_culling : face -> unit

type orientation =
  | CW
  | CCW

val set_front_face : orientation -> unit

type polygon = 
  | Point
  | Line
  | Fill

val set_polygon_mode : face -> polygon -> unit

val set_clear_color : float -> float -> float -> unit

val version : unit -> string

val glsl_version : unit -> string

