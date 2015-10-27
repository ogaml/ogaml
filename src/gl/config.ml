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

external enable  : capability list -> unit = "caml_gl_enable_list"

external disable : capability list -> unit = "caml_gl_disable_list"

external set_culling : face -> unit = "caml_gl_cull_face"

external set_front : orientation -> unit = "caml_gl_front_face"

external set_color : float -> float -> float -> unit = "caml_gl_clear_color"

external clear : unit -> unit = "caml_gl_clear"

