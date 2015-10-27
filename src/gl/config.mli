type capability = 
    | ClipDistance of int
    | Blend
    | ColorLogicOp
    | CullFace
    | DebugOutput
    | DebugOutputSynchronous
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
    | PrimitiveRestartFixedIndex
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

type face = 
  | Back
  | Front
  | Both

type orientation =
  | CW
  | CCW

val enable : capability list -> unit

val disable : capability list -> unit

val set_culling : face -> unit

val set_front : orientation -> unit

val set_color : float -> float -> float -> unit

(* temp *)
val clear : unit -> unit

