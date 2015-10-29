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
    case 0  : return GL_BLEND;
    case 1  : return GL_COLOR_LOGIC_OP;
    case 2  : return GL_CULL_FACE;
    case 3  : return GL_DEPTH_CLAMP;
    case 4  : return GL_DEPTH_TEST;
    case 5  : return GL_DITHER;
    case 6  : return GL_FRAMEBUFFER_SRGB;
    case 7  : return GL_LINE_SMOOTH;
    case 8 : return GL_MULTISAMPLE;
    case 9 : return GL_POLYGON_OFFSET_FILL;
    case 10 : return GL_POLYGON_OFFSET_LINE;
    case 11 : return GL_POLYGON_OFFSET_POINT;
    case 12 : return GL_POLYGON_SMOOTH;
    case 13 : return GL_PRIMITIVE_RESTART;
    case 14 : return GL_RASTERIZER_DISCARD;
    case 15 : return GL_SAMPLE_ALPHA_TO_COVERAGE;
    case 16 : return GL_SAMPLE_ALPHA_TO_ONE;
    case 17 : return GL_SAMPLE_COVERAGE;
    case 18 : return GL_SAMPLE_SHADING;
    case 19 : return GL_SAMPLE_MASK;
    case 20 : return GL_SCISSOR_TEST;
    case 21 : return GL_STENCIL_TEST;
    case 22 : return GL_TEXTURE_CUBE_MAP_SEAMLESS;
    case 23 : return GL_PROGRAM_POINT_SIZE;
    default : caml_failwith("variant error : gl_config_stubs");
  }
}


// Maps the GL config variant to the parametric capabilities
GLenum map_caml_tag(int v, int arg)
{
  switch(v)
  {
    case 0 : return (GL_CLIP_DISTANCE0 + arg);
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


// INPUT   nothing
// OUTPUT  the current GL version
CAMLprim value
caml_gl_version(value unit)
{
  CAMLparam0();
  CAMLreturn(caml_copy_string(glGetString(GL_VERSION)));
}


// INPUT   nothing
// OUTPUT  the current GLSL version
CAMLprim value
caml_glsl_version(value unit)
{
  CAMLparam0();
  CAMLreturn(caml_copy_string(glGetString(GL_SHADING_LANGUAGE_VERSION)));
}


// temp
CAMLprim value
caml_gl_clear(value unit)
{
  CAMLparam0();
  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
  CAMLreturn(Val_unit);
}


