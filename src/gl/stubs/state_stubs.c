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


// INPUT   nothing
// OUTPUT  the current GL version
CAMLprim value
caml_gl_version(value unit)
{
  CAMLparam0();
  CAMLreturn(caml_copy_string((char*)glGetString(GL_VERSION)));
}


// INPUT   nothing
// OUTPUT  the current GLSL version
CAMLprim value
caml_glsl_version(value unit)
{
  CAMLparam0();
  CAMLreturn(caml_copy_string((char*)glGetString(GL_SHADING_LANGUAGE_VERSION)));
}


// INPUT   nothing
// OUTPUT  the maximal number of textures
CAMLprim value
caml_max_textures(value unit)
{
  CAMLparam0();
  int res;
  glGetIntegerv(GL_MAX_TEXTURE_UNITS, &res);
  CAMLreturn(Val_int(res));
}
