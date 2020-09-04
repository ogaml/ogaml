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
#include <string.h>
#include "utils.h"
#include "types_stubs.h"

#define TEX(_a) (*(GLuint*) Data_custom_val(_a))

#define RBO(_a) (*(GLuint*) Data_custom_val(_a))

#define FBO(_a) (*(GLuint*) Data_custom_val(_a))


void finalise_fbo(value v)
{
  glDeleteFramebuffers(1,&FBO(v));
}

int compare_fbo(value v1, value v2)
{
  GLuint i1 = FBO(v1);
  GLuint i2 = FBO(v2);
  if(i1 < i2) return -1;
  else if(i1 == i2) return 0;
  else return 1;
}

intnat hash_fbo(value v)
{
  GLuint i = FBO(v);
  return i;
}

static struct custom_operations fbo_custom_ops = {
  "fbo gc handling",
  finalise_fbo,
  compare_fbo,
  hash_fbo,
  custom_serialize_default,
  custom_deserialize_default
};


// INPUT   nothing
// OUTPUT  an FBO name
CAMLprim value
caml_create_fbo(value unit)
{
  CAMLparam0();
  CAMLlocal1(v);

  GLuint buf[1];
  glGenFramebuffers(1, buf);
  v = caml_alloc_custom( &fbo_custom_ops, sizeof(GLuint), 0, 1);
  memcpy( Data_custom_val(v), buf, sizeof(GLuint) );

  CAMLreturn(v);
}


// INPUT   : an FBO name
// OUTPUT  : nothing, binds the FBO
CAMLprim value
caml_bind_fbo(value buf)
{
  CAMLparam1(buf);
  if(buf == Val_none)
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
  else {
    glBindFramebuffer(GL_FRAMEBUFFER, FBO(Some_val(buf)));
  }
  CAMLreturn(Val_unit);
}


// INPUT   : an FBO name
// OUTPUT  : nothing, deletes the FBO
CAMLprim value
caml_destroy_fbo(value buf)
{
  CAMLparam1(buf);
  glDeleteFramebuffers(1, &FBO(buf));
  CAMLreturn(Val_unit);
}


// INPUT   : an attachment point, a texture, a layer, a mipmap level
// OUTPUT  : nothing, attaches the texture to the currently bound FBO
CAMLprim value
caml_fbo_texture_layer(value atc, value tex, value layer, value level)
{
  CAMLparam4(atc,tex,layer,level);
  glFramebufferTextureLayer(GL_FRAMEBUFFER, Attachment_val(atc), TEX(tex), Int_val(level), Int_val(layer));
  CAMLreturn(Val_unit);
}


// INPUT   : an attachment point, a texture, a mipmap level
// OUTPUT  : nothing, attaches the texture to the currently bound FBO
CAMLprim value
caml_fbo_texture2D(value atc, value tex, value level)
{
  CAMLparam3(atc,tex,level);
  glFramebufferTexture2D(GL_FRAMEBUFFER, Attachment_val(atc), GL_TEXTURE_2D, TEX(tex), Int_val(level));
  CAMLreturn(Val_unit);
}


// INPUT   : an attachment point, a texture, a layer, a mipmap level
// OUTPUT  : nothing, attaches the texture to the currently bound FBO
CAMLprim value
caml_fbo_texture3D(value atc, value tex, value layer, value level)
{
  CAMLparam4(atc,tex,layer,level);
  glFramebufferTexture3D(GL_FRAMEBUFFER, Attachment_val(atc), GL_TEXTURE_3D, TEX(tex), Int_val(level), Int_val(layer));
  CAMLreturn(Val_unit);
}


// INPUT   : an attachment point, an RBO
// OUTPUT  : nothing, attaches the RBO to the currently bound FBO
CAMLprim value
caml_fbo_renderbuffer(value atc, value rbo)
{
  CAMLparam2(atc,rbo);
  glFramebufferRenderbuffer(GL_FRAMEBUFFER, Attachment_val(atc), GL_RENDERBUFFER, RBO(rbo));
  CAMLreturn(Val_unit);
}


CAMLprim value
caml_fbo_drawbuffers(value nbufs, value val_bufs)
{
  CAMLparam2(nbufs, val_bufs);

  int i;
  GLenum bufs[Int_val(nbufs)];

  for(i = 0; i < Int_val(nbufs); i++)
  {
    bufs[i] = FBOOutputBuffer_val(Field(val_bufs, i));
  }

  glDrawBuffers(Int_val(nbufs), bufs);
  
  CAMLreturn(Val_unit);
}


CAMLprim value
caml_fbo_drawwindowbuffers(value nbufs, value val_bufs)
{
  CAMLparam2(nbufs, val_bufs);

  int i;
  GLenum bufs[Int_val(nbufs)];

  for(i = 0; i < Int_val(nbufs); i++)
  {
    bufs[i] = WindowOutputBuffer_val(Field(val_bufs, i));
  }

  glDrawBuffers(Int_val(nbufs), bufs);
  
  CAMLreturn(Val_unit);
}
