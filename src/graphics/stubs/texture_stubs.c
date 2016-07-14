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


#define TEX(_a) (*(GLuint*) Data_custom_val(_a))

#define MLvar_Minify  (254173077)

#define MLvar_Magnify (-1011094397)

#define MLvar_Wrap (1940966357)

void finalise_tex(value v)
{
  glDeleteTextures(1,&TEX(v));
}


int compare_tex(value v1, value v2)
{
  GLuint i1 = TEX(v1);
  GLuint i2 = TEX(v2);
  if(i1 < i2) return -1;
  else if(i1 == i2) return 0;
  else return 1;
}

intnat hash_tex(value v)
{
  GLuint i = TEX(v);
  return i;
}

static struct custom_operations tex_custom_ops = {
  .identifier  = "texture GC handling",
  .finalize    =  finalise_tex,
  .compare     =  compare_tex,
  .hash        =  hash_tex,
  .serialize   =  custom_serialize_default,
  .deserialize =  custom_deserialize_default
};




// INPUT   nothing
// OUTPUT  a fresh texture id
CAMLprim value
caml_create_texture(value unit)
{
  CAMLparam0();
  CAMLlocal1(v);

  GLuint buf[1];
  glGenTextures(1, buf);
  v = caml_alloc_custom( &tex_custom_ops, sizeof(GLuint), 0, 1);
  memcpy( Data_custom_val(v), buf, sizeof(GLuint) );

  CAMLreturn(v);
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
    glBindTexture(Target_val(point), TEX(Some_val(tex_opt)));

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


// INPUT   a texture target, a level, a pixel format, a size, a texture format, some data
// OUTPUT  nothing, binds an image to the current texture2D
CAMLprim value
caml_tex_image_2D_native(value target, value lvl, value fmt, value size, value tfmt, value data)
{
  CAMLparam5(target, fmt, size, tfmt, data);
  CAMLxparam1(lvl);

  glTexImage2D(Target_val(target),
               Int_val(lvl),
               TextureFormat_val(tfmt),
               Int_val(Field(size,0)),
               Int_val(Field(size,1)),
               0,
               PixelFormat_val(fmt),
               GL_UNSIGNED_BYTE,
               (data == Val_none)? NULL : String_val(Some_val(data)));

  CAMLreturn(Val_unit);
}

CAMLprim value
caml_tex_image_2D_bytecode(value *argv, int argn) 
{
  return caml_tex_image_2D_native(argv[0], argv[1], argv[2], argv[3], argv[4], argv[5]);
}


// INPUT   a texture target, a level, an offset, a size, a pixel format, some data
// OUTPUT  nothing, binds an subimage to the current texture2D
CAMLprim value
caml_tex_subimage_2D_native(value target, value lvl, value off, value size, value fmt, value data)
{
  CAMLparam5(target, lvl, off, size, fmt);
  CAMLxparam1(data);

  glTexSubImage2D(Target_val(target),
                  Int_val(lvl),
                  Int_val(Field(off,0)),
                  Int_val(Field(off,1)),
                  Int_val(Field(size,0)),
                  Int_val(Field(size,1)),
                  PixelFormat_val(fmt),
                  GL_UNSIGNED_BYTE,
                  (data == Val_none)? NULL : String_val(Some_val(data)));

  CAMLreturn(Val_unit);
}

CAMLprim value
caml_tex_subimage_2D_bytecode(value *argv, int argn) 
{
  return caml_tex_subimage_2D_native(argv[0], argv[1], argv[2], argv[3], argv[4], argv[5]);
}


// INPUT   a texture target, a number of mipmaps, a texture format, a texture size
// OUTPUT  nothing, allocates the space for a texture2D
CAMLprim value
caml_tex_storage_2D(value target, value lvls, value tfmt, value size)
{
  CAMLparam4(target,lvls,tfmt,size);

  glTexStorage2D(Target_val(target), 
                 Int_val(lvls), 
                 TextureFormat_val(tfmt),
                 Int_val(Field(size,0)),
                 Int_val(Field(size,1)));

  CAMLreturn(Val_unit);
}


// INPUT   a texture target, a level, a pixel format, a size, a texture format, some data
// OUTPUT  nothing, binds an image to the current texture3D
CAMLprim value
caml_tex_image_3D_native(value target, value lvl, value fmt, value size, value tfmt, value data)
{
  CAMLparam5(target, fmt, size, tfmt, data);
  CAMLxparam1(lvl);

  glTexImage3D(Target_val(target),
               Int_val(lvl),
               TextureFormat_val(tfmt),
               Int_val(Field(size,0)),
               Int_val(Field(size,1)),
               Int_val(Field(size,2)),
               0,
               PixelFormat_val(fmt),
               GL_UNSIGNED_BYTE,
               (data == Val_none)? NULL : String_val(Some_val(data)));

  CAMLreturn(Val_unit);
}

CAMLprim value
caml_tex_image_3D_bytecode(value *argv, int argn) 
{
  return caml_tex_image_3D_native(argv[0], argv[1], argv[2], argv[3], argv[4], argv[5]);
}


// INPUT   a texture target, a level, an offset, a size, a pixel format, some data
// OUTPUT  nothing, binds an subimage to the current texture3D
CAMLprim value
caml_tex_subimage_3D_native(value target, value lvl, value off, value size, value fmt, value data)
{
  CAMLparam5(target, lvl, off, size, fmt);
  CAMLxparam1(data);

  glTexSubImage3D(Target_val(target),
                  Int_val(lvl),
                  Int_val(Field(off,0)),
                  Int_val(Field(off,1)),
                  Int_val(Field(off,2)),
                  Int_val(Field(size,0)),
                  Int_val(Field(size,1)),
                  Int_val(Field(size,2)),
                  PixelFormat_val(fmt),
                  GL_UNSIGNED_BYTE,
                  (data == Val_none)? NULL : String_val(Some_val(data)));

  CAMLreturn(Val_unit);
}

CAMLprim value
caml_tex_subimage_3D_bytecode(value *argv, int argn) 
{
  return caml_tex_subimage_3D_native(argv[0], argv[1], argv[2], argv[3], argv[4], argv[5]);
}


// INPUT   a texture target, a number of mipmaps, a texture format, a texture size
// OUTPUT  nothing, allocates the space for a texture3D
CAMLprim value
caml_tex_storage_3D(value target, value lvls, value tfmt, value size)
{
  CAMLparam4(target,lvls,tfmt,size);

  glTexStorage3D(Target_val(target), 
                 Int_val(lvls), 
                 TextureFormat_val(tfmt),
                 Int_val(Field(size,0)),
                 Int_val(Field(size,1)),
                 Int_val(Field(size,2)));

  CAMLreturn(Val_unit);
}



// INPUT   a variant containing the texture type and a min/mag filter
// OUTPUT  nothing, sets the texture parameter
CAMLprim value
caml_tex_parameter(value typ, value loc)
{
  CAMLparam2(typ, loc);

  if(Field(loc, 0) == MLvar_Magnify)
    glTexParameteri(Target_val(typ), GL_TEXTURE_MAG_FILTER, Magnify_val(Field(loc, 1)));
  else if(Field(loc, 0) == MLvar_Minify)
    glTexParameteri(Target_val(typ), GL_TEXTURE_MIN_FILTER, Minify_val(Field(loc, 1)));
  else if(Field(loc, 0) == MLvar_Wrap) {
    glTexParameteri(Target_val(typ), GL_TEXTURE_WRAP_S, Wrap_val(Field(loc, 1)));
    glTexParameteri(Target_val(typ), GL_TEXTURE_WRAP_R, Wrap_val(Field(loc, 1)));
    glTexParameteri(Target_val(typ), GL_TEXTURE_WRAP_T, Wrap_val(Field(loc, 1)));
  }
  else {
    caml_failwith("Caml polymorphic variant error in tex_parameter_2D(1)");
  }

  CAMLreturn(Val_unit);
}


// INPUT   a texture ID
// OUTPUT  nothing, deletes the texture
CAMLprim value
caml_destroy_texture(value id)
{
  CAMLparam1(id);

  glDeleteTextures(1, &TEX(id));

  CAMLreturn(Val_unit);
}
