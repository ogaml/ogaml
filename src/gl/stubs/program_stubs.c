#define GL_GLEXT_PROTOTYPES
#include <GL/gl.h>
#include "../../utils/stubs.h"


// INPUT   nothing
// OUTPUT  a new gl program
CAMLprim value
caml_gl_create_program(value unit)
{
  CAMLparam0();
  CAMLreturn((value)glCreateProgram());
}


// INPUT   a program and a shader
// OUTPUT  nothing, attaches the shader
CAMLprim value
caml_gl_attach_shader(value sh, value prog)
{
  CAMLparam2(sh, prog);
  glAttachShader((GLuint)prog, (GLuint)sh);
  CAMLreturn(Val_unit);
}


// INPUT   a program and an attribute name
// OUTPUT  returns the location of the attribute
CAMLprim value
caml_gl_attrib_location(value prog, value str)
{
  CAMLparam2(prog, str);
  CAMLreturn(Val_int(glGetAttribLocation((GLuint)prog,String_val(str))));
}


// INPUT   a program and a uniform name
// OUTPUT  returns the location of the uniform
CAMLprim value
caml_gl_uniform_location(value prog, value str)
{
  CAMLparam2(prog, str);
  CAMLreturn(Val_int(glGetUniformLocation((GLuint)prog,String_val(str))));
}


// INPUT   a program
// OUTPUT  nothing, links the program
CAMLprim value
caml_gl_link_program(value prog)
{
  CAMLparam1(prog);
  glLinkProgram((GLuint)prog);
  CAMLreturn(Val_unit);
}


// INPUT   a program option
// OUTPUT  nothing, uses the program (if provided)
CAMLprim value
caml_gl_use_program(value prog)
{
  CAMLparam1(prog);
  if(prog == Val_none)
    glUseProgram(0);
  else
    glUseProgram((GLuint)Some_val(prog));
  CAMLreturn(Val_unit);
}


