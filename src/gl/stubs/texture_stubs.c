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


#define MLvar_Minify  (254173077)

#define MLvar_Magnify (-1011094397)


GLenum Target_val(value target)
{
  switch(target)
  {
    case 0:
      return GL_TEXTURE_1D;

    case 1:
      return GL_TEXTURE_2D;

    case 2:
      return GL_TEXTURE_3D;

    default:
      caml_failwith("Caml variant error in Target_val(1)");
  }
}


GLenum Magnify_val(value mag)
{
  switch(mag)
  {
    case 0:
      return GL_NEAREST;

    case 1:
      return GL_LINEAR;

    default:
      caml_failwith("Caml variant error in Magnify_val(1)");
  }
}


GLenum Minify_val(value min)
{
  switch(min)
  {
    case 0:
      return GL_NEAREST;

    case 1:
      return GL_LINEAR;

    case 2:
      return GL_NEAREST_MIPMAP_NEAREST;

    case 3:
      return GL_LINEAR_MIPMAP_NEAREST;

    default:
      caml_failwith("Caml variant error in Minify_val(1)");
  }
}


GLenum TextureFormat_val(value fmt)
{
  switch(fmt)
  {
    case 0:
      return GL_RGB;

    case 1:
      return GL_RGBA;

    case 2:
      return GL_DEPTH_COMPONENT;

    case 3:
      return GL_DEPTH_STENCIL;

    default:
      caml_failwith("Caml variant error in TextureFormat_val(1)");
  }
}


GLenum PixelFormat_val(value fmt)
{
  switch(fmt)
  {
    case 0:
      return GL_R;

    case 1:
      return GL_RG;

    case 2:
      return GL_RGB;

    case 3:
      return GL_BGR;

    case 4:
      return GL_RGBA;

    case 5:
      return GL_BGRA;

    case 6:
      return GL_DEPTH_COMPONENT;

    case 7:
      return GL_DEPTH_STENCIL;

    default:
      caml_failwith("Caml variant error in TextureFormat_val(1)");
  }
}


// INPUT   nothing
// OUTPUT  a fresh texture id
CAMLprim value
caml_create_texture(value unit)
{
  CAMLparam0();

  GLuint textureID;
  glGenTextures(1, &textureID);

  CAMLreturn((value)textureID);
}


// INPUT   a binding point and a texture id option
// OUTPUT  nothing, binds the texture
CAMLprim value
caml_bind_texture(value point, value tex_opt)
{
  CAMLparam2(point, tex_opt);

  if(tex_opt == Val_none)
    glBindTexture(Target_val(point), 0);
  else
    glBindTexture(Target_val(point), (GLuint)Some_val(tex_opt));

  CAMLreturn(Val_unit);
}


// INPUT   an int (texture location)
// OUTPUT  nothing, activates the texture location
CAMLprim value
caml_activate_texture(value loc)
{
  CAMLparam1(loc);

  glActiveTexture(GL_TEXTURE0 + Int_val(loc));

  CAMLreturn(Val_unit);
}


// INPUT   a texture target, a pixel format, a size, a texture format, some data
// OUTPUT  nothing, binds an image to the current texture2D
CAMLprim value
caml_tex_image_2D(value target, value fmt, value size, value tfmt, value data)
{
  CAMLparam5(target, fmt, size, tfmt, data);

  glTexImage2D(Target_val(target), 
               0, 
               TextureFormat_val(tfmt),
               Int_val(Field(size,0)),
               Int_val(Field(size,1)),
               0, 
               PixelFormat_val(fmt),
               GL_UNSIGNED_BYTE,
               String_val(data));

  CAMLreturn(Val_unit);
}


// INPUT   a variant containing the min/mag filter
// OUTPUT  nothing, sets the texture2D parameter
CAMLprim value
caml_tex_parameter_2D(value loc)
{
  CAMLparam1(loc);

  if(loc == MLvar_Magnify)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, Magnify_val(Field(loc,0)));
  else if(loc == MLvar_Minify)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, Minify_val(Field(loc,0)));
  else 
    caml_failwith("Caml polymorphic variant error in tex_parameter_2D(1)");

  CAMLreturn(Val_unit);
}


// INPUT   a texture ID
// OUTPUT  nothing, deletes the texture
CAMLprim value
caml_destroy_texture(value id)
{
  CAMLparam1(id);

  GLuint tmp = (GLuint)id;
  glDeleteTextures(1, &tmp);

  CAMLreturn(Val_unit);
}

