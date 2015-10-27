#define GL_GLEXT_PROTOTYPES
#if defined(__APPLE__)
  #include <OpenGL/gl3.h>
  #ifndef GL_TESS_CONTROL_SHADER
      #define GL_TESS_CONTROL_SHADER 0x00008e88
  #endif
  #ifndef GL_TESS_EVALUATION_SHADER
      #define GL_TESS_EVALUATION_SHADER 0x00008e87
  #endif
  #ifndef GL_PATCHES
      #define GL_PATCHES 0x0000000e
  #endif
#else
  #include <GL/gl.h>
#endif
#include <caml/bigarray.h>
#include "../../utils/stubs.h"


// Maps the GL config variant to the capabilities
GLenum map_caml_long(int v) 
{
  switch(v)
  {
    case 0  : return GL_ALPHA_TEST;
    case 1  : return GL_AUTO_NORMAL;
    case 2  : return GL_BLEND;
    case 3  : return GL_COLOR_LOGIC_OP;
    case 4  : return GL_COLOR_MATERIAL;
    case 5  : return GL_COLOR_SUM;
    case 6  : return GL_COLOR_TABLE;
    case 7  : return GL_CONVOLUTION_1D;
    case 8  : return GL_CONVOLUTION_2D;
    case 9  : return GL_CULL_FACE;
    case 10 : return GL_DEPTH_TEST;
    case 11 : return GL_DITHER;
    case 12 : return GL_FOG;
    case 13 : return GL_HISTOGRAM;
    case 14 : return GL_INDEX_LOGIC_OP;
    case 15 : return GL_LIGHTING;
    case 16 : return GL_LINE_SMOOTH;
    case 17 : return GL_LINE_STIPPLE;
    case 18 : return GL_MAP1_COLOR_4;
    case 19 : return GL_MAP1_INDEX;
    case 20 : return GL_MAP1_NORMAL;
    case 21 : return GL_MAP1_TEXTURE_COORD_1;
    case 22 : return GL_MAP1_TEXTURE_COORD_2;
    case 23 : return GL_MAP1_TEXTURE_COORD_3;
    case 24 : return GL_MAP1_TEXTURE_COORD_4;
    case 25 : return GL_MAP1_VERTEX_3;
    case 26 : return GL_MAP1_VERTEX_4;
    case 27 : return GL_MAP2_COLOR_4;
    case 28 : return GL_MAP2_INDEX;
    case 29 : return GL_MAP2_NORMAL;
    case 30 : return GL_MAP2_TEXTURE_COORD_1;
    case 31 : return GL_MAP2_TEXTURE_COORD_2;
    case 32 : return GL_MAP2_TEXTURE_COORD_3;
    case 33 : return GL_MAP2_TEXTURE_COORD_4;
    case 34 : return GL_MAP2_VERTEX_3;
    case 35 : return GL_MAP2_VERTEX_4;
    case 36 : return GL_MINMAX;
    case 37 : return GL_MULTISAMPLE;
    case 38 : return GL_NORMALIZE;
    case 39 : return GL_POINT_SMOOTH;
    case 40 : return GL_POINT_SPRITE;
    case 41 : return GL_POLYGON_OFFSET_FILL;
    case 42 : return GL_POLYGON_OFFSET_LINE;
    case 43 : return GL_POLYGON_OFFSET_POINT;
    case 44 : return GL_POLYGON_SMOOTH;
    case 45 : return GL_POLYGON_STIPPLE;
    case 46 : return GL_POST_COLOR_MATRIX_COLOR_TABLE;
    case 47 : return GL_POST_CONVOLUTION_COLOR_TABLE;
    case 48 : return GL_RESCALE_NORMAL;
    case 49 : return GL_SAMPLE_ALPHA_TO_COVERAGE;
    case 50 : return GL_SAMPLE_ALPHA_TO_ONE;
    case 51 : return GL_SAMPLE_COVERAGE;
    case 52 : return GL_SEPARABLE_2D;
    case 53 : return GL_SCISSOR_TEST;
    case 54 : return GL_STENCIL_TEST;
    case 55 : return GL_TEXTURE_1D;
    case 56 : return GL_TEXTURE_2D;
    case 57 : return GL_TEXTURE_3D;
    case 58 : return GL_TEXTURE_CUBE_MAP;
    case 59 : return GL_TEXTURE_GEN_Q;
    case 60 : return GL_TEXTURE_GEN_R;
    case 61 : return GL_TEXTURE_GEN_S;
    case 62 : return GL_TEXTURE_GEN_T;
    case 63 : return GL_VERTEX_PROGRAM_POINT_SIZE;
    case 64 : return GL_VERTEX_PROGRAM_TWO_SIDE;
    default : caml_failwith("variant error : gl_config_stubs");
  }
}


// Maps the GL config variant to the parametric capabilities
GLenum map_caml_tag(int v, int arg)
{
  switch(v)
  {
    case 0 : return (GL_CLIP_PLANE0 + arg);
    case 1 : return (GL_LIGHT0 + arg);
    default : caml_failwith("variant error : gl_config_stubs");
  }
}


// INPUT   a list of capabilities
// OUTPUT  nothing, enables the capabilities
CAMLprim value
caml_gl_enable_list(value list)
{
  CAMLparam1(list);
  CAMLlocal2(hd,tl);

  tl = list;
  while(tl != Val_emptylist) 
  {
    hd = Field(tl, 0);
    tl = Field(tl, 1);

    if(Is_long(hd))
      glEnable(map_caml_long(Int_val(hd)));
    else
      glEnable(map_caml_tag(Tag_val(hd), Int_val(Field(hd,0))));
  }

  CAMLreturn(Val_unit);
}


// INPUT   a list of capabilities
// OUTPUT  nothing, disables the capabilities
CAMLprim value
caml_gl_disable_list(value list)
{
  CAMLparam1(list);
  CAMLlocal2(hd,tl);

  tl = list;
  while(tl != Val_emptylist) 
  {
    hd = Field(tl, 0);
    tl = Field(tl, 1);

    if(Is_long(hd))
      glDisable(map_caml_long(Int_val(hd)));
    else
      glDisable(map_caml_tag(Tag_val(hd), Int_val(Field(hd,0))));
  }

  CAMLreturn(Val_unit);
}


// INPUT   a face 
// OUTPUT  nothing, sets the face culling
CAMLprim value
caml_gl_cull_face(value face)
{
  CAMLparam1(face);
  switch(Int_val(face))
  {
    case 0: glCullFace(GL_BACK); break;
    case 1: glCullFace(GL_FRONT); break;
    case 2: glCullFace(GL_FRONT_AND_BACK); break;
    default: caml_failwith("caml variant error gl_cull_face");
  }
  CAMLreturn(Val_unit);
}


// INPUT   an orientation
// OUTPUT  nothing, sets the front face orientation
CAMLprim value
caml_gl_front_face(value orient)
{
  CAMLparam1(orient);
  switch(Int_val(orient))
  {
    case 0: glFrontFace(GL_CW); break;
    case 1: glFrontFace(GL_CCW); break;
    default: caml_failwith("caml variant error gl_front_face");
  }
  CAMLreturn(Val_unit);
}


// INPUT   three values r g b in [0;1]
// OUTPUT  nothing, sets the clear color
CAMLprim value
caml_gl_clear_color(value r, value g, value b)
{
  CAMLparam3(r,g,b);
  glClearColor(Double_val(r), Double_val(g), Double_val(b), 1.0);
  CAMLreturn(Val_unit);
}


// temp
CAMLprim value
caml_gl_clear(value unit)
{
  CAMLparam0();
  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
  CAMLreturn(Val_unit);
}


