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

type face = 
  | Back
  | Front
  | Both

type orientation =
  | CW
  | CCW

type polygon = 
  | Point
  | Line
  | Fill

external abstract_set_clear_color : float -> float -> float -> unit = "caml_gl_clear_color"

external enable  : capability list -> unit = "caml_gl_enable_list"

external disable : capability list -> unit = "caml_gl_disable_list"

external set_culling : face -> unit = "caml_gl_cull_face"

external set_front_face : orientation -> unit = "caml_gl_front_face"

external set_polygon_mode : face -> polygon -> unit = "caml_gl_polygon_mode"

external version : unit -> string = "caml_gl_version"

external glsl_version : unit -> string = "caml_glsl_version"

let set_clear_color c = Color.(
  let c = rgb c in
  RGB.(abstract_set_clear_color c.r c.g c.b))

