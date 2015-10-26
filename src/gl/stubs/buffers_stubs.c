#define GL_GLEXT_PROTOTYPES
#include <GL/gl.h>
#include <caml/bigarray.h>
#include "../../utils/stubs.h"


// INPUT   : nothing
// OUTPUT  : a buffer name
CAMLprim value
caml_gl_gen_buffers(value unit)
{
  CAMLparam0();

  GLuint buf[1];
  glGenBuffers(1, buf);

  CAMLreturn((value)buf[0]);
}


// INPUT   : a buffer name
// OUTPUT  : nothing, binds the buffer
CAMLprim value
caml_gl_bind_buffer(value buf)
{
  CAMLparam1(buf);
  if(buf == Val_none)
    glBindBuffer(GL_ARRAY_BUFFER, 0);
  else
    glBindBuffer(GL_ARRAY_BUFFER, (GLuint)Some_val(buf));
  CAMLreturn(Val_unit);
}


// INPUT   : a buffer name
// OUTPUT  : nothing, deletes the buffer
CAMLprim value
caml_gl_delete_buffer(value buf)
{
  CAMLparam1(buf);
  GLuint tmp = (GLuint)buf;
  glDeleteBuffers(1, &tmp);
  CAMLreturn(Val_unit);
}


// INPUT   : some data, the length of the data in bytes
// OUTPUT  : nothing, updates the bound buffer with the data
CAMLprim value
caml_gl_buffer_data(value data, value len)
{
  CAMLparam2(data, len);
  const GLvoid* c_dat = Caml_ba_data_val(data);
  glBufferData(GL_ARRAY_BUFFER, Int_val(len), c_dat, GL_STATIC_DRAW);
  CAMLreturn(Val_unit);
}


