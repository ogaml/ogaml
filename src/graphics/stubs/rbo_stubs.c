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
#include <string.h>
#include "utils.h"
#include "types_stubs.h"

#define RBO(_a) (*(GLuint*) Data_custom_val(_a))


void finalise_rbo(value v)
{
  glDeleteRenderbuffers(1,&RBO(v));
}

int compare_rbo(value v1, value v2)
{
  GLuint i1 = RBO(v1);
  GLuint i2 = RBO(v2);
  if(i1 < i2) return -1;
  else if(i1 == i2) return 0;
  else return 1;
}

intnat hash_rbo(value v)
{
  GLuint i = RBO(v);
  return i;
}

static struct custom_operations rbo_custom_ops = {
  .identifier  = "rbo gc handling",
  .finalize    =  finalise_rbo,
  .compare     =  compare_rbo,
  .hash        =  hash_rbo,
  .serialize   =  custom_serialize_default,
  .deserialize =  custom_deserialize_default
};


// INPUT   nothing
// OUTPUT  an RBO name
CAMLprim value
caml_create_rbo(value unit)
{
  CAMLparam0();
  CAMLlocal1(v);

  GLuint buf[1];
  glGenRenderbuffers(1, buf);
  v = caml_alloc_custom( &rbo_custom_ops, sizeof(GLuint), 0, 1);
  memcpy( Data_custom_val(v), buf, sizeof(GLuint) );

  CAMLreturn(v);
}


// INPUT   : an RBO name
// OUTPUT  : nothing, binds the RBO
CAMLprim value
caml_bind_rbo(value buf)
{
  CAMLparam1(buf);
  if(buf == Val_none)
    glBindRenderbuffer(GL_RENDERBUFFER, 0);
  else {
    glBindRenderbuffer(GL_RENDERBUFFER, RBO(Some_val(buf)));
  }
  CAMLreturn(Val_unit);
}


// INPUT   : an RBO name
// OUTPUT  : nothing, deletes the RBO
CAMLprim value
caml_destroy_rbo(value buf)
{
  CAMLparam1(buf);
  glDeleteRenderbuffers(1, &RBO(buf));
  CAMLreturn(Val_unit);
}


// INPUT   : an internal format, width, height
// OUTPUT  : nothing, creates a storage for the bound RBO
CAMLprim value
caml_rbo_storage(value format, value width, value height)
{
  CAMLparam3(format,width,height);

  glRenderbufferStorage(GL_RENDERBUFFER, 
                        TextureFormat_val(format), 
                        Int_val(width), 
                        Int_val(height));

  CAMLreturn(Val_unit);
}
