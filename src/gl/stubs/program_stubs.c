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
#include "../../utils/stubs.h"


GLenum Val_type(value type)
{
  switch(type)
  {
    case GL_FLOAT        : return 0;
    case GL_FLOAT_VEC2   : return 1;
    case GL_FLOAT_VEC3   : return 2;
    case GL_FLOAT_VEC4   : return 3;
    case GL_FLOAT_MAT2   : return 4;
    case GL_FLOAT_MAT2x3 : return 5;
    case GL_FLOAT_MAT2x4 : return 6;
    case GL_FLOAT_MAT3x2 : return 7;
    case GL_FLOAT_MAT3   : return 8;
    case GL_FLOAT_MAT3x4 : return 9;
    case GL_FLOAT_MAT4x2 : return 10;
    case GL_FLOAT_MAT4x3 : return 11;
    case GL_FLOAT_MAT4   : return 12;
    case GL_SAMPLER_1D   : return 13;
    case GL_SAMPLER_2D   : return 14;
    case GL_SAMPLER_3D   : return 15;
    default: caml_failwith("Caml variant error in Val_type(1)");
  }
}


// INPUT   nothing
// OUTPUT  a new gl program
CAMLprim value
caml_create_program(value unit)
{
  CAMLparam0();
  CAMLreturn((value)glCreateProgram());
}


// INPUT   a program and a shader
// OUTPUT  nothing, attaches the shader
CAMLprim value
caml_attach_shader(value prog, value sh)
{
  CAMLparam2(sh, prog);

  glAttachShader((GLuint)prog, (GLuint)sh);

  CAMLreturn(Val_unit);
}


// INPUT   a program and an attribute name
// OUTPUT  returns the location of the attribute
CAMLprim value
caml_attrib_location(value prog, value str)
{
  CAMLparam2(prog, str);
  CAMLreturn(Val_int(glGetAttribLocation((GLuint)prog,String_val(str))));
}


// INPUT   a program
// OUTPUT  returns the number of active uniforms
CAMLprim value
caml_uniform_count(value prog)
{
  CAMLparam1(prog);
  GLint tmp;
  glGetProgramiv((GLuint)prog, GL_ACTIVE_UNIFORMS, &tmp);
  CAMLreturn(Val_int(tmp));
}


// INPUT   a program 
// OUTPUT  returns the number of active attributes
CAMLprim value
caml_attribute_count(value prog)
{
  CAMLparam1(prog);
  GLint tmp;
  glGetProgramiv((GLuint)prog, GL_ACTIVE_ATTRIBUTES, &tmp);
  CAMLreturn(Val_int(tmp));
}


// INPUT   a program and a uniform name
// OUTPUT  returns the location of the uniform
CAMLprim value
caml_uniform_location(value prog, value str)
{
  CAMLparam2(prog, str);
  CAMLreturn(Val_int(glGetUniformLocation((GLuint)prog,String_val(str))));
}


// INPUT   a program
// OUTPUT  nothing, links the program
CAMLprim value
caml_link_program(value prog)
{
  CAMLparam1(prog);

  glLinkProgram((GLuint)prog);

  CAMLreturn(Val_unit);
}


// INPUT   a program 
// OUTPUT  returns true iff the linking was successful
CAMLprim value
caml_program_status(value prog)
{
  CAMLparam1(prog);
  GLint tmp;
  glGetProgramiv((GLuint)prog, GL_LINK_STATUS, &tmp);
  if(tmp == GL_FALSE)
    CAMLreturn(Val_false);
  else 
    CAMLreturn(Val_true);
}


// INPUT   a program option
// OUTPUT  nothing, uses the program (if provided)
CAMLprim value
caml_use_program(value prog)
{
  CAMLparam1(prog);

  if(prog == Val_none)
    glUseProgram(0);
  else
    glUseProgram((GLuint)Some_val(prog));

  CAMLreturn(Val_unit);
}


// INPUT   : a program id
// OUTPUT  : the log of the program
CAMLprim value
caml_program_log(value id)
{
  CAMLparam1(id);
  CAMLlocal1(res);

  GLint tmp;
  glGetProgramiv((GLuint)id, GL_INFO_LOG_LENGTH, &tmp);

  GLsizei maxl = tmp;
  GLsizei len[1] = {0};
  GLchar* log = malloc(tmp * sizeof(GLchar));
  glGetProgramInfoLog((GLuint)id, maxl, len, log);

  res = caml_copy_string(log);

  free(log);

  CAMLreturn(res);
}


// INPUT   : a program id, a uniform index
// OUTPUT  : the name of the uniform
CAMLprim value
caml_uniform_name(value id, value index)
{
  CAMLparam2(id,index);
  CAMLlocal1(res);

  GLint tmp;
  glGetProgramiv((GLuint)id, GL_ACTIVE_UNIFORM_MAX_LENGTH, &tmp);

  GLsizei maxl = tmp;
  GLsizei tmp_len;
  GLint   tmp_size;
  GLenum  tmp_type;
  GLchar* name = malloc(tmp * sizeof(GLchar));

  glGetActiveUniform((GLuint)id, Int_val(index), maxl, &tmp_len, &tmp_size, &tmp_type, name);

  res = caml_copy_string(name);

  free(name);

  CAMLreturn(res);
}


// INPUT   : a program id, an attribute index
// OUTPUT  : the name of the attribute 
CAMLprim value
caml_attribute_name(value id, value index)
{
  CAMLparam2(id,index);
  CAMLlocal1(res);

  GLint tmp;
  glGetProgramiv((GLuint)id, GL_ACTIVE_ATTRIBUTE_MAX_LENGTH, &tmp);

  GLsizei maxl = tmp;
  GLsizei tmp_len;
  GLint   tmp_size;
  GLenum  tmp_type;
  GLchar* name = malloc(tmp * sizeof(GLchar));

  glGetActiveAttrib((GLuint)id, Int_val(index), maxl, &tmp_len, &tmp_size, &tmp_type, name);

  res = caml_copy_string(name);

  free(name);

  CAMLreturn(res);
}


// INPUT   : a program id, a uniform index
// OUTPUT  : the type of the uniform
CAMLprim value
caml_uniform_type(value id, value index)
{
  CAMLparam2(id,index);
  CAMLlocal1(res);

  GLsizei tmp_len;
  GLint   tmp_size;
  GLenum  tmp_type;
  GLchar  tmp_name;

  glGetActiveUniform((GLuint)id, Int_val(index), 0, &tmp_len, &tmp_size, &tmp_type, &tmp_name);

  CAMLreturn(Val_type(tmp_type));
}


// INPUT   : a program id, an attribute index
// OUTPUT  : the type of the attribute
CAMLprim value
caml_attribute_type(value id, value index)
{
  CAMLparam2(id,index);
  CAMLlocal1(res);

  GLsizei tmp_len;
  GLint   tmp_size;
  GLenum  tmp_type;
  GLchar  tmp_name;

  glGetActiveAttrib((GLuint)id, Int_val(index), 0, &tmp_len, &tmp_size, &tmp_type, &tmp_name);

  CAMLreturn(Val_type(tmp_type));
}

