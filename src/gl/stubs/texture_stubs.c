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


// INPUT   some pixel data, width, height
// OUTPUT  a texture 
CAMLprim value
caml_gl_create_texture(value data, value width, value height)
{
  CAMLparam3(data, width, height);

  GLuint textureID;
  glGenTextures(1, &textureID);
  
  glBindTexture(GL_TEXTURE_2D, textureID);
  
  glTexImage2D(GL_TEXTURE_2D, 
                           0, 
                     GL_RGBA, 
              Int_val(width), 
             Int_val(height), 
                           0, 
                     GL_RGBA, 
            GL_UNSIGNED_BYTE, 
            String_val(data));
  
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);

  glBindTexture(GL_TEXTURE_2D, 0);

  CAMLreturn((value)textureID);
}


// INPUT   a texture id option
// OUTPUT  nothing, binds the texture
CAMLprim value
caml_gl_bind_texture(value opt)
{
  CAMLparam1(opt);

  if(opt == Val_none)
    glBindTexture(GL_TEXTURE_2D, 0);
  else
    glBindTexture(GL_TEXTURE_2D, (GLuint)Some_val(opt));

  CAMLreturn(Val_unit);
}


// INPUT   an int (texture location)
// OUTPUT  nothing, activates the texture location
CAMLprim value
caml_gl_active_texture(value loc)
{
  CAMLparam1(loc);

  glActiveTexture(GL_TEXTURE0 + Int_val(loc));

  CAMLreturn(Val_unit);
}


// INPUT   a texture ID
// OUTPUT  nothing, deletes the texture
CAMLprim value
caml_gl_delete_texture(value id)
{
  CAMLparam1(id);

  GLuint tmp = (GLuint)id;
  glDeleteTextures(1, &tmp);

  CAMLreturn(Val_unit);
}

