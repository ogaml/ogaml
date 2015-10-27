#define GL_GLEXT_PROTOTYPES
#if defined(__APPLE__)
  #include <OpenGL/gl.h>
#else
  #include <GL/gl.h>
#endif
#include <caml/bigarray.h>
#include "../../utils/stubs.h"


CAMLprim value
caml_gl_uniform1f(value loc, value v)
{
  CAMLparam2(loc,v);
  glUniform1f((GLuint)Int_val(loc),Double_val(v));
  CAMLreturn(Val_unit);
}


CAMLprim value
caml_gl_uniform2f(value loc, value v1, value v2)
{
  CAMLparam3(loc,v1,v2);
  glUniform2f((GLuint)Int_val(loc),Double_val(v1),Double_val(v2));
  CAMLreturn(Val_unit);
}


CAMLprim value
caml_gl_uniform3f(value loc, value v1, value v2, value v3)
{
  CAMLparam4(loc,v1,v2,v3);
  glUniform3f((GLuint)Int_val(loc),Double_val(v1),Double_val(v2),Double_val(v3));
  CAMLreturn(Val_unit);
}


CAMLprim value
caml_gl_uniform4f(value loc, value v1, value v2, value v3, value v4)
{
  CAMLparam5(loc,v1,v2,v3,v4);
  glUniform4f((GLuint)Int_val(loc),Double_val(v1),Double_val(v2),Double_val(v3),Double_val(v4));
  CAMLreturn(Val_unit);
}


CAMLprim value
caml_gl_uniform1i(value loc, value v)
{
  CAMLparam2(loc,v);
  glUniform1i((GLuint)Int_val(loc),Int_val(v));
  CAMLreturn(Val_unit);
}


CAMLprim value
caml_gl_uniform2i(value loc, value v1, value v2)
{
  CAMLparam3(loc,v1,v2);
  glUniform2i((GLuint)Int_val(loc),Int_val(v1),Int_val(v2));
  CAMLreturn(Val_unit);
}


CAMLprim value
caml_gl_uniform3i(value loc, value v1, value v2, value v3)
{
  CAMLparam4(loc,v1,v2,v3);
  glUniform3i((GLuint)Int_val(loc),Int_val(v1),Int_val(v2),Int_val(v3));
  CAMLreturn(Val_unit);
}


CAMLprim value
caml_gl_uniform4i(value loc, value v1, value v2, value v3, value v4)
{
  CAMLparam5(loc,v1,v2,v3,v4);
  glUniform4i((GLuint)Int_val(loc),Int_val(v1),Int_val(v2),Int_val(v3),Int_val(v4));
  CAMLreturn(Val_unit);
}


CAMLprim value
caml_gl_uniform1ui(value loc, value v)
{
  CAMLparam2(loc,v);
  glUniform1ui((GLuint)Int_val(loc),Int_val(v));
  CAMLreturn(Val_unit);
}


CAMLprim value
caml_gl_uniform2ui(value loc, value v1, value v2)
{
  CAMLparam3(loc,v1,v2);
  glUniform2ui((GLuint)Int_val(loc),Int_val(v1),Int_val(v2));
  CAMLreturn(Val_unit);
}


CAMLprim value
caml_gl_uniform3ui(value loc, value v1, value v2, value v3)
{
  CAMLparam4(loc,v1,v2,v3);
  glUniform3ui((GLuint)Int_val(loc),Int_val(v1),Int_val(v2),Int_val(v3));
  CAMLreturn(Val_unit);
}


CAMLprim value
caml_gl_uniform4ui(value loc, value v1, value v2, value v3, value v4)
{
  CAMLparam5(loc,v1,v2,v3,v4);
  glUniform4ui((GLuint)Int_val(loc),Int_val(v1),Int_val(v2),Int_val(v3),Int_val(v4));
  CAMLreturn(Val_unit);
}


CAMLprim value
caml_gl_uniform_mat2(value loc, value dat)
{
  CAMLparam2(loc,dat);
  glUniformMatrix2fv((GLuint)Int_val(loc), 1, GL_FALSE, (GLfloat*)Caml_ba_data_val(dat));
  CAMLreturn(Val_unit);
}


CAMLprim value
caml_gl_uniform_mat3(value loc, value dat)
{
  CAMLparam2(loc,dat);
  glUniformMatrix3fv((GLuint)Int_val(loc), 1, GL_FALSE, (GLfloat*)Caml_ba_data_val(dat));
  CAMLreturn(Val_unit);
}


CAMLprim value
caml_gl_uniform_mat4(value loc, value dat)
{
  CAMLparam2(loc,dat);
  glUniformMatrix4fv((GLuint)Int_val(loc), 1, GL_FALSE, (GLfloat*)Caml_ba_data_val(dat));
  CAMLreturn(Val_unit);
}


CAMLprim value
caml_gl_uniform_mat23(value loc, value dat)
{
  CAMLparam2(loc,dat);
  glUniformMatrix2x3fv((GLuint)Int_val(loc), 1, GL_FALSE, (GLfloat*)Caml_ba_data_val(dat));
  CAMLreturn(Val_unit);
}


CAMLprim value
caml_gl_uniform_mat32(value loc, value dat)
{
  CAMLparam2(loc,dat);
  glUniformMatrix3x2fv((GLuint)Int_val(loc), 1, GL_FALSE, (GLfloat*)Caml_ba_data_val(dat));
  CAMLreturn(Val_unit);
}


CAMLprim value
caml_gl_uniform_mat24(value loc, value dat)
{
  CAMLparam2(loc,dat);
  glUniformMatrix2x4fv((GLuint)Int_val(loc), 1, GL_FALSE, (GLfloat*)Caml_ba_data_val(dat));
  CAMLreturn(Val_unit);
}


CAMLprim value
caml_gl_uniform_mat42(value loc, value dat)
{
  CAMLparam2(loc,dat);
  glUniformMatrix4x2fv((GLuint)Int_val(loc), 1, GL_FALSE, (GLfloat*)Caml_ba_data_val(dat));
  CAMLreturn(Val_unit);
}


CAMLprim value
caml_gl_uniform_mat34(value loc, value dat)
{
  CAMLparam2(loc,dat);
  glUniformMatrix3x4fv((GLuint)Int_val(loc), 1, GL_FALSE, (GLfloat*)Caml_ba_data_val(dat));
  CAMLreturn(Val_unit);
}


CAMLprim value
caml_gl_uniform_mat43(value loc, value dat)
{
  CAMLparam2(loc,dat);
  glUniformMatrix4x3fv((GLuint)Int_val(loc), 1, GL_FALSE, (GLfloat*)Caml_ba_data_val(dat));
  CAMLreturn(Val_unit);
}


