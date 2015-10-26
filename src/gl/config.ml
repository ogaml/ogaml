type capability = 
  | AlphaTest
  | AutoNormal
  | Blend
  | ClipPlane of int
  | ColorLogicOp
  | ColorMaterial
  | ColorSum
  | ColorTable
  | Convolution1D
  | Convolution2D
  | CullFace
  | DepthTest
  | Dither
  | Fog
  | Histogram
  | IndexLogicOp
  | Light of int
  | Lighting
  | LineSmooth
  | LineStipple
  | Map1Color4
  | Map1Index
  | Map1Normal
  | Map1TextureCoord1
  | Map1TextureCoord2
  | Map1TextureCoord3
  | Map1TextureCoord4
  | Map1Vertex3
  | Map1Vertex4
  | Map2Color4
  | Map2Index
  | Map2Normal
  | Map2TextureCoord1
  | Map2TextureCoord2
  | Map2TextureCoord3
  | Map2TextureCoord4
  | Map2Vertex3
  | Map2Vertex4
  | Minmax
  | Multisample
  | Normalize
  | PointSmooth
  | PointSprite
  | PolygonOffsetFill
  | PolygonOffsetLine
  | PolygonOffsetPoint
  | PolygonSmooth
  | PolygonStipple
  | PostColorMatrixColorTable
  | PostConvolutionColorTable
  | RescaleNormal
  | SampleAlphaToCoverage
  | SampleAlphaToOne
  | SampleCoverage
  | Separable2D
  | ScissorTest
  | StencilTest
  | Texture1D
  | Texture2D
  | Texture3D
  | TextureCubeMap
  | TextureGenQ
  | TextureGenR
  | TextureGenS
  | TextureGenT
  | VertexProgramPointSize
  | VertexProgramTwoSide

external enable : capability list -> unit = "caml_gl_enable_list"

external disable : capability list -> unit = "caml_gl_disable_list"
