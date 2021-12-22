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
#include <string.h>
#include "utils.h"
#include "types_stubs.h"

#define PROGRAM(_a) (*(GLuint*) Data_custom_val(_a))


void finalise_program(value v)
{
  glDeleteProgram(PROGRAM(v));
}

int compare_program(value v1, value v2)
{
  GLuint i1 = PROGRAM(v1);
  GLuint i2 = PROGRAM(v2);
  if(i1 < i2) return -1;
  else if(i1 == i2) return 0;
  else return 1;
}

intnat hash_program(value v)
{
  GLuint i = PROGRAM(v);
  return i;
}

static struct custom_operations program_custom_ops = {
  "program gc handling",
  finalise_program,
  compare_program,
  hash_program,
  custom_serialize_default,
  custom_deserialize_default
};


// INPUT   nothing
// OUTPUT  a new gl program
CAMLprim value
caml_create_program(value unit)
{
  CAMLparam0();
  CAMLlocal1(v);

  GLuint prog = glCreateProgram();
  v = caml_alloc_custom( &program_custom_ops, sizeof(GLuint), 0, 1);
  memcpy( Data_custom_val(v), &prog, sizeof(GLuint) );

  CAMLreturn(v);
}


// INPUT   a program
// OUTPUT  deletes the program
CAMLprim value
caml_delete_program(value prog)
{
  CAMLparam1(prog);
  glDeleteProgram(PROGRAM(prog));
  CAMLreturn(Val_unit);
}


// INPUT   a program
// OUTPUT  true iff it is valid
CAMLprim value
caml_valid_program(value prog)
{
  CAMLparam1(prog);
  CAMLreturn(Val_bool(PROGRAM(prog) != 0));
}


// INPUT   a program and a shader
// OUTPUT  nothing, attaches the shader
CAMLprim value
caml_attach_shader(value prog, value sh)
{
  CAMLparam2(sh, prog);

  glAttachShader(PROGRAM(prog), (GLuint)sh);

  CAMLreturn(Val_unit);
}


// INPUT   a program and a shader
// OUTPUT  nothing, detaches the shader
CAMLprim value
caml_detach_shader(value prog, value sh)
{
  CAMLparam2(sh, prog);

  glDetachShader(PROGRAM(prog), (GLuint)sh);

  CAMLreturn(Val_unit);
}


// INPUT   a program and an attribute name
// OUTPUT  returns the location of the attribute
CAMLprim value
caml_attrib_location(value prog, value str)
{
  CAMLparam2(prog, str);
  CAMLreturn(Val_int(glGetAttribLocation(PROGRAM(prog),String_val(str))));
}


// INPUT   a program
// OUTPUT  returns the number of active uniforms
CAMLprim value
caml_uniform_count(value prog)
{
  CAMLparam1(prog);
  GLint tmp;
  glGetProgramiv(PROGRAM(prog), GL_ACTIVE_UNIFORMS, &tmp);
  CAMLreturn(Val_int(tmp));
}


// INPUT   a program
// OUTPUT  returns the number of active attributes
CAMLprim value
caml_attribute_count(value prog)
{
  CAMLparam1(prog);
  GLint tmp;
  glGetProgramiv(PROGRAM(prog), GL_ACTIVE_ATTRIBUTES, &tmp);
  CAMLreturn(Val_int(tmp));
}


// INPUT   a program and a uniform name
// OUTPUT  returns the location of the uniform
CAMLprim value
caml_uniform_location(value prog, value str)
{
  CAMLparam2(prog, str);
  CAMLreturn(Val_int(glGetUniformLocation(PROGRAM(prog),String_val(str))));
}


// INPUT   a program
// OUTPUT  nothing, links the program
CAMLprim value
caml_link_program(value prog)
{
  CAMLparam1(prog);

  glLinkProgram(PROGRAM(prog));

  CAMLreturn(Val_unit);
}


// INPUT   a program
// OUTPUT  returns true iff the linking was successful
CAMLprim value
caml_program_status(value prog)
{
  CAMLparam1(prog);
  GLint tmp;
  glGetProgramiv(PROGRAM(prog), GL_LINK_STATUS, &tmp);
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
    glUseProgram(PROGRAM(Some_val(prog)));

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
  GLsizei maxl;
  GLsizei len[1] = {0};
  GLchar* log;

  glGetProgramiv(PROGRAM(id), GL_INFO_LOG_LENGTH, &tmp);

  maxl = tmp;
  log = malloc(tmp * sizeof(GLchar));

  glGetProgramInfoLog(PROGRAM(id), maxl, len, log);
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
  GLsizei maxl;
  GLsizei tmp_len;
  GLint   tmp_size;
  GLenum  tmp_type;
  GLchar* name;

  glGetProgramiv(PROGRAM(id), GL_ACTIVE_UNIFORM_MAX_LENGTH, &tmp);

  maxl = tmp;
  name = malloc(tmp * sizeof(GLchar));

  glGetActiveUniform(PROGRAM(id), Int_val(index), maxl, &tmp_len, &tmp_size, &tmp_type, name);

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
  GLsizei maxl;
  GLsizei tmp_len;
  GLint   tmp_size;
  GLenum  tmp_type;
  GLchar* name;

  glGetProgramiv(PROGRAM(id), GL_ACTIVE_ATTRIBUTE_MAX_LENGTH, &tmp);

  maxl = tmp;
  name = malloc(tmp * sizeof(GLchar));

  glGetActiveAttrib(PROGRAM(id), Int_val(index), maxl, &tmp_len, &tmp_size, &tmp_type, name);

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

  glGetActiveUniform(PROGRAM(id), Int_val(index), 0, &tmp_len, &tmp_size, &tmp_type, &tmp_name);

  CAMLreturn(Val_int(Val_attrib_type(tmp_type)));
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

  glGetActiveAttrib(PROGRAM(id), Int_val(index), 0, &tmp_len, &tmp_size, &tmp_type, &tmp_name);

  CAMLreturn(Val_int(Val_attrib_type(tmp_type)));
}


// INPUT   : a program id, a uniform index
// OUTPUT  : the size of the uniform
CAMLprim value
caml_uniform_size(value id, value index)
{
  CAMLparam2(id,index);
  CAMLlocal1(res);

  GLsizei tmp_len;
  GLint   tmp_size;
  GLenum  tmp_type;
  GLchar  tmp_name;

  glGetActiveUniform(PROGRAM(id), Int_val(index), 0, &tmp_len, &tmp_size, &tmp_type, &tmp_name);

  CAMLreturn(Val_int(tmp_size));
}
