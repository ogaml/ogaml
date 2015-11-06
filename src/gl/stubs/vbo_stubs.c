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


GLenum VBOKind_val(value kind) 
{
  switch(Int_val(kind))
  {
    case 0:
      return GL_STATIC_DRAW;

    case 1:
      return GL_DYNAMIC_DRAW;

    default:
      caml_failwith("Caml variant error in VBOKind_val(1)");
  }
}


// INPUT   nothing
// OUTPUT  a buffer name
CAMLprim value
caml_create_buffer(value unit)
{
  CAMLparam0();

  GLuint buf[1];
  glGenBuffers(1, buf);

  CAMLreturn((value)buf[0]);
}


// INPUT   a buffer name
// OUTPUT  nothing, binds the buffer
CAMLprim value
caml_bind_vbo(value buf)
{
  CAMLparam1(buf);
  if(buf == Val_none)
    glBindBuffer(GL_ARRAY_BUFFER, 0);
  else
    glBindBuffer(GL_ARRAY_BUFFER, (GLuint)(Some_val(buf)));
  CAMLreturn(Val_unit);
}


// INPUT   a buffer name
// OUTPUT  nothing, deletes the buffer
CAMLprim value
caml_destroy_buffer(value buf)
{
  CAMLparam1(buf);
  GLuint tmp = (GLuint)buf;
  glDeleteBuffers(1, &tmp);
  CAMLreturn(Val_unit);
}


// INPUT   a length, some data (option), a mode
// OUTPUT  nothing, updates the bound buffer with the data 
CAMLprim value
caml_vbo_data(value len, value opt, value mode)
{
  CAMLparam3(len, opt, mode);
  if(opt == Val_none)
    glBufferData(GL_ARRAY_BUFFER, Int_val(len), NULL, VBOKind_val(mode));
  else {
    const GLvoid* c_dat = Caml_ba_data_val(Some_val(opt));
    glBufferData(GL_ARRAY_BUFFER, Int_val(len), c_dat, VBOKind_val(mode));
  }
  CAMLreturn(Val_unit);
}


// INPUT   an offset, a length, some data
// OUTPUT  nothing, updates a sub-buffer with the data
CAMLprim value
caml_vbo_subdata(value off, value len, value data)
{
  CAMLparam3(off, len, data);
  const GLvoid* c_dat = Caml_ba_data_val(data);
  glBufferSubData(GL_ARRAY_BUFFER, Int_val(off), Int_val(len), c_dat);
}
