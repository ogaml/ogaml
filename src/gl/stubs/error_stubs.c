#define GL_GLEXT_PROTOTYPES
#include <GL/gl.h>
#include <caml/bigarray.h>
#include "../../utils/stubs.h"


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

    case GL_STACK_UNDERFLOW :
      res = Val_some(Val_int(5));
      break;

    case GL_STACK_OVERFLOW :
      res = Val_some(Val_int(6));
      break;

    default:
      res = Val_none;
      break;

  }

  CAMLreturn(res);
}
