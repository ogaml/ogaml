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
#include "types_stubs.h"


// INPUT   a shader type
// OUTPUT  a new shader id
CAMLprim value
caml_create_shader(value type)
{
  CAMLparam1(type);
  CAMLreturn((value) glCreateShader(Shader_val(type)));
}


// INPUT   a shader
// OUTPUT  deletes the shader
CAMLprim value
caml_delete_shader(value shader)
{
  CAMLparam1(shader);
  glDeleteShader(shader);
  CAMLreturn(Val_unit);
}



// INPUT   a shader
// OUTPUT  true iff it is valid
CAMLprim value
caml_valid_shader(value shader)
{
  CAMLparam1(shader);
  CAMLreturn(Val_bool((GLuint)shader != 0));
}

// INPUT   a shader id, a source
// OUTPUT  nothing, changes the source code of the shader
CAMLprim value
caml_source_shader(value id, value src)
{
  CAMLparam2(src, id);
  
  const GLchar* tmp_src = String_val(src);
  const GLint tmp_len  = -1;
  glShaderSource((GLuint)id, 1, &tmp_src, &tmp_len);

  CAMLreturn(Val_unit);
}


// INPUT   a shader id
// OUTPUT  nothing, compiles the shader
CAMLprim value
caml_compile_shader(value id)
{
  CAMLparam1(id);

  glCompileShader((GLuint)id);

  CAMLreturn(Val_unit);
}


// INPUT   a shader id
// OUTPUT  true iff the shader successfully compiled
CAMLprim value
caml_shader_status(value id)
{
  CAMLparam1(id);
  
  GLint tmp;
  glGetShaderiv((GLuint)id, GL_COMPILE_STATUS, &tmp);

  if(tmp == GL_FALSE) 
    CAMLreturn(Val_false);
  else
    CAMLreturn(Val_true);
}


// INPUT   : a shader id
// OUTPUT  : the log of the shader
CAMLprim value
caml_shader_log(value id)
{
  CAMLparam1(id);
  CAMLlocal1(res);

  GLint tmp;
  glGetShaderiv((GLuint)id, GL_INFO_LOG_LENGTH, &tmp);

  GLsizei maxl = tmp;
  GLsizei len[1] = {0};
  GLchar* log = malloc(tmp * sizeof(GLchar));
  glGetShaderInfoLog((GLuint)id, maxl, len, log);

  res = caml_copy_string(log);

  free(log);

  CAMLreturn(res);
}



