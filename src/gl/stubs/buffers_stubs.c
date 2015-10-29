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


// INPUT   : nothing
// OUTPUT  : a buffer name
CAMLprim value
caml_gl_gen_buffers(value unit)
{
  CAMLparam0();

  GLuint buf[1];
  glGenBuffers(1, buf);

  CAMLreturn(Val_int(buf[0]));
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
    glBindBuffer(GL_ARRAY_BUFFER, (GLuint)Int_val(Some_val(buf)));
  CAMLreturn(Val_unit);
}


// INPUT   : a buffer name
// OUTPUT  : nothing, deletes the buffer
CAMLprim value
caml_gl_delete_buffer(value buf)
{
  CAMLparam1(buf);
  GLuint tmp = (GLuint)Int_val(buf);
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


// INPUT   : nothing
// OUTPUT  : a vertex array name
CAMLprim value
caml_gl_gen_vertex_array(value unit)
{
  CAMLparam0();

  GLuint buf[1];
  glGenVertexArrays(1, buf);

  CAMLreturn(Val_int(buf[0]));
}


// INPUT   : a vertex array name
// OUTPUT  : nothing, binds the vertex array
CAMLprim value
caml_gl_bind_vertex_array(value buf)
{
  CAMLparam1(buf);
  if(buf == Val_none)
    glBindVertexArray(0);
  else
    glBindVertexArray((GLuint)Int_val(Some_val(buf)));
  CAMLreturn(Val_unit);
}


// INPUT   : a vertex array name
// OUTPUT  : nothing, deletes the vertex array
CAMLprim value
caml_gl_delete_vertex_array(value buf)
{
  CAMLparam1(buf);
  GLuint tmp = (GLuint)Int_val(buf);
  glDeleteVertexArrays(1, &tmp);
  CAMLreturn(Val_unit);
}


// INPUT   an attribute location
// OUTPUT  nothing, enables the attribute
CAMLprim value
caml_gl_enable_vaa(value loc)
{
  CAMLparam1(loc);
  glEnableVertexAttribArray((GLuint)Int_val(loc));
  CAMLreturn(Val_unit);
}


// INPUT   an attribute location, its size, its type, 
//           the "normalize" boolean, the couple (stride, offset)
// OUTPUT  nothing, sets the attribute pointer
CAMLprim value
caml_gl_vertex_attrib_pointer(value loc, value size, value type, value norm, value pair)
{
  CAMLparam5(loc, size, type, norm, pair);

  GLuint glloc  = (GLuint)Int_val(loc);
  GLint  glsize = Int_val(size);
  GLenum gltype = 0;
  GLboolean glnorm = GL_FALSE; 
  GLsizei stride = Int_val(Field(pair,0));
  GLvoid* offset = (GLvoid*)Int_val(Field(pair,1));

  switch(Int_val(type))
  {
    case 0: gltype = GL_BYTE          ; break;
    case 1: gltype = GL_UNSIGNED_BYTE ; break;
    case 2: gltype = GL_SHORT         ; break;
    case 3: gltype = GL_UNSIGNED_SHORT; break;
    case 4: gltype = GL_INT           ; break;
    case 5: gltype = GL_UNSIGNED_INT  ; break;
    case 6: gltype = GL_FLOAT         ; break;
    case 7: gltype = GL_DOUBLE        ; break;
    default: caml_failwith("caml variant error : vertex_attrib_pointer");
  }
  
  if(Bool_val(norm))
    glnorm = GL_TRUE;

  glVertexAttribPointer(glloc, glsize, gltype, glnorm, stride, offset);

  CAMLreturn(Val_unit);
}


// INPUT   an attribute location, its size, its type, 
//           the couple (stride, offset)
// OUTPUT  nothing, sets the integer attribute pointer
CAMLprim value
caml_gl_vertex_attrib_ipointer(value loc, value size, value type, value pair)
{
  CAMLparam4(loc, size, type, pair);

  GLuint glloc  = (GLuint)Int_val(loc);
  GLint  glsize = Int_val(size);
  GLenum gltype = 0;
  GLsizei stride = Int_val(Field(pair,0));
  GLvoid* offset = (GLvoid*)Int_val(Field(pair,1));

  switch(Int_val(type))
  {
    case 0: gltype = GL_BYTE          ; break;
    case 1: gltype = GL_UNSIGNED_BYTE ; break;
    case 2: gltype = GL_SHORT         ; break;
    case 3: gltype = GL_UNSIGNED_SHORT; break;
    case 4: gltype = GL_INT           ; break;
    case 5: gltype = GL_UNSIGNED_INT  ; break;
    default: caml_failwith("caml variant error : vertex_attrib_ipointer");
  }

  glVertexAttribIPointer(glloc, glsize, gltype, stride, offset);

  CAMLreturn(Val_unit);
}


// INPUT   an attribute location, a divisor
// OUTPUT  nothing, sets the attribute divisor
CAMLprim value
caml_gl_vertex_attrib_divisor(value loc, value div)
{
  CAMLparam2(loc,div);
  glVertexAttribDivisor((GLuint)Int_val(loc), (GLuint)Int_val(div));
  CAMLreturn(Val_unit);
}


// INPUT   a shape, two indices (start, end)
// OUTPUT  nothing, draws the current array
CAMLprim value
caml_gl_draw_arrays(value sh, value start, value end)
{
  CAMLparam3(sh,start,end);
  GLenum type = 0;

  switch(Int_val(sh))
  {
    case 0 : type = GL_POINTS; break;
    case 1 : type = GL_LINE_STRIP; break;
    case 2 : type = GL_LINE_LOOP; break;
    case 3 : type = GL_LINES; break;
    case 4 : type = GL_LINE_STRIP_ADJACENCY; break;
    case 5 : type = GL_LINES_ADJACENCY; break;
    case 6 : type = GL_TRIANGLE_STRIP; break;
    case 7 : type = GL_TRIANGLE_FAN; break;
    case 8 : type = GL_TRIANGLES; break;
    case 9 : type = GL_TRIANGLE_STRIP_ADJACENCY; break;
    case 10: type = GL_TRIANGLES_ADJACENCY; break;
    case 11: type = GL_PATCHES; break;
    default: caml_failwith("caml variant error : gl_draw_arrays");
  }

  glDrawArrays(type, (GLint)Int_val(start), (GLint)Int_val(end));

  CAMLreturn(Val_unit);
}


// INPUT   3 boolean : color bit, depth bit, stencil bit
// OUTPUT  clear the corresponding bits
CAMLprim value
caml_gl_clear(value c, value d, value s)
{
  CAMLparam3(c,d,s);

  GLbitfield tmp = 0;
  if(Bool_val(c)) tmp |= GL_COLOR_BUFFER_BIT;
  if(Bool_val(d)) tmp |= GL_DEPTH_BUFFER_BIT;
  if(Bool_val(s)) tmp |= GL_STENCIL_BUFFER_BIT;
  glClear(tmp);

  CAMLreturn(Val_unit);
}



