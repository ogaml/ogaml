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
// OUTPUT  : a fragment shader id
CAMLprim value
caml_gl_create_fragment_shader(value unit)
{
  CAMLparam0();
  CAMLreturn((value) glCreateShader(GL_FRAGMENT_SHADER));
}


// INPUT   : nothing
// OUTPUT  : a vertex shader id
CAMLprim value
caml_gl_create_vertex_shader(value unit)
{
  CAMLparam0();
  CAMLreturn((value) glCreateShader(GL_VERTEX_SHADER));
}


// INPUT   : a shader id, a source
// OUTPUT  : nothing, changes the source code of the shader
CAMLprim value
caml_gl_source_shader(value src, value id)
{
  CAMLparam2(src, id);
  const GLchar* tmp_src = String_val(src);
  const GLint tmp_len  = -1;
  glShaderSource((GLuint)id, 1, &tmp_src, &tmp_len);
  CAMLreturn(Val_unit);
}


// INPUT   : a shader id
// OUTPUT  : nothing, compiles the shader
CAMLprim value
caml_gl_compile_shader(value id)
{
  CAMLparam1(id);
  glCompileShader((GLuint)id);
  CAMLreturn(Val_unit);
}


// INPUT   : a shader id
// OUTPUT  : the log of the shader and the size of the log
CAMLprim value
caml_gl_shader_infolog(value id)
{
  CAMLparam1(id);
  CAMLlocal1(res);

  GLsizei maxl = 1024;
  GLsizei len[1] = {0};
  GLchar  log[1024] = "";
  glGetShaderInfoLog((GLuint)id, maxl, len, log);

  res = caml_alloc(2, 0);
  Store_field(res, 0, caml_copy_string(log));
  Store_field(res, 1, Val_int(len[0]));

  CAMLreturn(res);
}


// INPUT   a shader id
// OUTPUT  true iff the shader compiled successfully 
CAMLprim value
caml_gl_shader_compiled(value id)
{
  CAMLparam1(id);
  CAMLlocal1(ret);

  GLint res;
  glGetShaderiv((GLuint)id, GL_COMPILE_STATUS, &res);

  if(res == GL_FALSE)
    ret = Val_false;
  else
    ret = Val_true;

  CAMLreturn(ret);
}

