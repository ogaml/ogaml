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
#include "utils.h"


GLenum Floattype_val(value type)
{
  switch(Int_val(type))
  {
    case 0:
      return GL_BYTE;

    case 1:
      return GL_UNSIGNED_BYTE;

    case 2:
      return GL_SHORT;

    case 3:
      return GL_UNSIGNED_SHORT;

    case 4:
      return GL_INT;

    case 5:
      return GL_UNSIGNED_INT;

    case 6:
      return GL_FLOAT;

    case 7:
      return GL_DOUBLE;
  
    default:
      failwith("Caml variant error in Floattype_val(1)");
  }
}


GLenum Inttype_val(value type)
{
  switch(Int_val(type))
  {
    case 0:
      return GL_BYTE;

    case 1:
      return GL_UNSIGNED_BYTE;

    case 2:
      return GL_SHORT;

    case 3:
      return GL_UNSIGNED_SHORT;

    case 4:
      return GL_INT;

    case 5:
      return GL_UNSIGNED_INT;

    default:
      failwith("Caml variant error in Inttype_val(1)");
  }
}


GLenum Drawmode_val(value mode)
{
  switch(Int_val(mode))
  {
    case 0:
      return GL_TRIANGLE_STRIP;

    case 1:
      return GL_TRIANGLE_FAN;

    case 2:
      return GL_TRIANGLES;

    case 3:
      return GL_LINES;

    default:
      failwith("Caml variant error in Drawmode_val(1)");
  }
}


// INPUT   : nothing
// OUTPUT  : a vertex array name
CAMLprim value
caml_create_vao(value unit)
{
  CAMLparam0();

  GLuint buf[1];
  glGenVertexArrays(1, buf);

  CAMLreturn(buf[0]);
}


// INPUT   : a vertex array name
// OUTPUT  : nothing, binds the vertex array
CAMLprim value
caml_bind_vao(value buf)
{
  CAMLparam1(buf);
  if(buf == Val_none)
    glBindVertexArray(0);
  else
    glBindVertexArray((GLuint)Some_val(buf));
  CAMLreturn(Val_unit);
}


// INPUT   : a vertex array name
// OUTPUT  : nothing, deletes the vertex array
CAMLprim value
caml_destroy_vao(value buf)
{
  CAMLparam1(buf);
  GLuint tmp = (GLuint)buf;
  glDeleteVertexArrays(1, &tmp);
  CAMLreturn(Val_unit);
}


// INPUT   an attribute location
// OUTPUT  nothing, enables the attribute
CAMLprim value
caml_enable_attrib(value loc)
{
  CAMLparam1(loc);
  glEnableVertexAttribArray((GLuint)Int_val(loc));
  CAMLreturn(Val_unit);
}


// INPUT   an attribute location, its size, its type, 
//         an offset, a stride
// OUTPUT  nothing, sets the float attribute pointer
CAMLprim value
caml_attrib_float(value loc, value size, value type, value off, value stride)
{
  CAMLparam5(loc, size, type, off, stride);

  GLuint glloc  = (GLuint)Int_val(loc);
  GLint  glsize = Int_val(size);
  GLsizei glstride = Int_val(stride);
  GLvoid* gloffset = (GLvoid*)Int_val(off);

  glVertexAttribPointer(glloc, glsize, Floattype_val(type), GL_TRUE, glstride, gloffset);

  CAMLreturn(Val_unit);
}


// INPUT   an attribute location, its size, its type, 
//         an offset, a stride
// OUTPUT  nothing, sets the float attribute pointer
CAMLprim value
caml_attrib_int(value loc, value size, value type, value off, value stride)
{
  CAMLparam5(loc, size, type, off, stride);

  GLuint glloc  = (GLuint)Int_val(loc);
  GLint  glsize = Int_val(size);
  GLsizei glstride = Int_val(stride);
  GLvoid* gloffset = (GLvoid*)Int_val(off);

  glVertexAttribIPointer(glloc, glsize, Inttype_val(type), glstride, gloffset);

  CAMLreturn(Val_unit);
}


// INPUT   a draw mode, two indices (start, end)
// OUTPUT  nothing, draws the currently bound VAO
CAMLprim value
caml_draw_arrays(value mode, value start, value end)
{
  CAMLparam3(mode, start, end);

  glDrawArrays(Drawmode_val(mode), Int_val(start), Int_val(end));

  CAMLreturn(Val_unit);
}


// INPUT   a draw mode, a number of elements
// OUTPUT  nothing, draws the requested number of elements from
//         the currently bound EBO and VAO
CAMLprim value
caml_draw_elements(value mode, value nb)
{
  CAMLparam2(mode, nb);

  glDrawElements(Drawmode_val(mode), Int_val(nb), GL_UNSIGNED_INT, (void*)0);

  CAMLreturn(Val_unit);
}


