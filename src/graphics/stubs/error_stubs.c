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

#include <stdio.h>


// INPUT   : nothing
// OUTPUT  : an error, if there is one on the stack
CAMLprim value
caml_gl_get_error(value unit)
{
  CAMLparam0();
  CAMLlocal1(res);

  switch(glGetError()) {

    case GL_NO_ERROR :
      res = Val_none;
      break;

    case GL_INVALID_ENUM :
      res = Val_some(Val_int(0));
      break;

    case GL_INVALID_VALUE :
      res = Val_some(Val_int(1));
      break;

    case GL_INVALID_OPERATION :
      res = Val_some(Val_int(2));
      break;

    case GL_INVALID_FRAMEBUFFER_OPERATION :
      res = Val_some(Val_int(3));
      break;

    case GL_OUT_OF_MEMORY :
      res = Val_some(Val_int(4));
      break;

    default:
      printf("Warning, ignored GL error\n");
      res = Val_none;
      break;

  }

  CAMLreturn(res);
}
