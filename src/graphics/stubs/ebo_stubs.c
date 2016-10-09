#define GL_GLEXT_PROTOTYPES
#if defined(_WIN32)
  #include <windows.h>
  #include <gl/glew.h>
#endif
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
#include "utils.h"
#include "types_stubs.h"

#define BUFFER(_a) (*(GLuint*) Data_custom_val(_a))

// INPUT   a buffer name
// OUTPUT  nothing, binds the buffer
CAMLprim value
caml_bind_ebo(value buf)
{
  CAMLparam1(buf);
  if(buf == Val_none)
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
  else
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, BUFFER(Some_val(buf)));
  CAMLreturn(Val_unit);
}


// INPUT   a length, some data (option), a mode
// OUTPUT  nothing, updates the bound buffer with the data 
CAMLprim value
caml_ebo_data(value len, value opt, value mode)
{
  CAMLparam3(len, opt, mode);
  if(opt == Val_none)
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, Int_val(len), NULL, EBOKind_val(mode));
  else {
    const GLvoid* c_dat = Caml_ba_data_val(Field(Some_val(opt),0));
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, Int_val(len), c_dat, EBOKind_val(mode));
  }
  CAMLreturn(Val_unit);
}


// INPUT   an offset, a length, some data
// OUTPUT  nothing, updates a sub-buffer with the data
CAMLprim value
caml_ebo_subdata(value off, value len, value data)
{
  CAMLparam3(off, len, data);
  const GLvoid* c_dat = Caml_ba_data_val(Field(data,0));
  glBufferSubData(GL_ELEMENT_ARRAY_BUFFER, Int_val(off), Int_val(len), c_dat);
  CAMLreturn(Val_unit);
}
