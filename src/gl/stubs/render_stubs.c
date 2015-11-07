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


GLenum Cull_val(value mode)
{
  switch(Int_val(mode))
  {
    case 0:
      return -1;

    case 1:
      return GL_CCW;

    case 2:
      return GL_CW;

    default:
      caml_failwith("Caml variant error in Cull_val(1)");
  }
}


GLenum Polygon_val(value mode)
{
  switch(Int_val(mode))
  {
    case 0:
      return GL_POINT;

    case 1:
      return GL_LINE;

    case 2:
      return GL_FILL;

    default:
      caml_failwith("Caml variant error in Polygon_val(1)");
  }
}


// INPUT   three booleans (color, depth, stencil)
// OUTPUT  nothing, clears the corresponding buffers
CAMLprim value
caml_gl_clear(value c, value d, value s)
{
  CAMLparam3(c,d,s);

  GLbitfield mask = 0;
  if (c == Val_true) mask |= GL_COLOR_BUFFER_BIT ;
  if (d == Val_true) mask |= GL_DEPTH_BUFFER_BIT ;
  if (s == Val_true) mask |= GL_STENCIL_BUFFER_BIT ;

  glClear(mask);

  CAMLreturn(Val_unit);
}


// INPUT   four values r g b a
// OUTPUT  nothing, sets the clear color
CAMLprim value
caml_clear_color(value r, value g, value b, value a)
{
  CAMLparam4(r,g,b,a);

  glClearColor(
    Double_val(r),
    Double_val(g),
    Double_val(b),
    Double_val(a)
  );

  CAMLreturn(Val_unit);
}


int culling = 0;

// INPUT   a culling mode
// OUTPUT  nothing, sets the culling mode
CAMLprim value
caml_culling_mode(value mode)
{
  CAMLparam1(mode);

  if(culling == 0) 
  {
    glEnable(GL_BACK);
    culling = 1;
  }
  GLenum val = Cull_val(mode);
  if(val != -1)
  {
    glEnable(GL_CULL_FACE);
    glFrontFace(val);
  }

  CAMLreturn(Val_unit);
}


// INPUT   a polygon mode
// OUTPUT  nothing, sets the polygon mode
CAMLprim value
caml_polygon_mode(value mode)
{
  CAMLparam1(mode);

  glPolygonMode(GL_FRONT_AND_BACK, Polygon_val(mode));

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


// INPUT   nothing
// OUTPUT  the maximal number of textures
CAMLprim value
caml_max_textures(value unit)
{
  CAMLparam0();
  int res;
  glGetIntegerv(GL_MAX_COMBINED_TEXTURE_IMAGE_UNITS, &res);
  CAMLreturn(Val_int(res));
}


