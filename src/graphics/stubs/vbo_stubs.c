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

#define BUFFER(_a) (*(GLuint*) Data_custom_val(_a))


GLenum VBOKind_val(value kind) 
{
  switch(Int_val(kind))
  {
    case 0:
      return GL_STATIC_DRAW;

    case 1:
      return GL_DYNAMIC_DRAW;

    default:
      caml_failwith("Caml variant error in VBOKind_val(1)");
  }
}


void finalise_buffer(value v)
{
  glDeleteBuffers(1,&BUFFER(v));
}

int compare_buffer(value v1, value v2)
{
  GLuint i1 = BUFFER(v1);
  GLuint i2 = BUFFER(v2);
  if(i1 < i2) return -1;
  else if(i1 == i2) return 0;
  else return 1;
}

intnat hash_buffer(value v)
{
  GLuint i = BUFFER(v);
  return i;
}

static struct custom_operations buffer_custom_ops = {
  identifier: "buffer gc handling",
  finalize:    finalise_buffer,
  compare:     compare_buffer,
  hash:        hash_buffer,
  serialize:   custom_serialize_default,
  deserialize: custom_deserialize_default
};


// INPUT   nothing
// OUTPUT  a buffer name
CAMLprim value
caml_create_buffer(value unit)
{
  CAMLparam0();
  CAMLlocal1(v);

  GLuint buf[1];
  glGenBuffers(1, buf);
  v = caml_alloc_custom( &buffer_custom_ops, sizeof(GLuint), 0, 1);
  memcpy( Data_custom_val(v), buf, sizeof(GLuint) );

  CAMLreturn(v);
}


// INPUT   a buffer name
// OUTPUT  nothing, binds the buffer
CAMLprim value
caml_bind_vbo(value buf)
{
  CAMLparam1(buf);
  if(buf == Val_none)
    glBindBuffer(GL_ARRAY_BUFFER, 0);
  else
    glBindBuffer(GL_ARRAY_BUFFER, BUFFER(Some_val(buf)));
  CAMLreturn(Val_unit);
}


// INPUT   a buffer name
// OUTPUT  nothing, deletes the buffer
CAMLprim value
caml_destroy_buffer(value buf)
{
  CAMLparam1(buf);
  glDeleteBuffers(1, &BUFFER(buf));
  CAMLreturn(Val_unit);
}


// INPUT   a length, some data (option), a mode
// OUTPUT  nothing, updates the bound buffer with the data 
CAMLprim value
caml_vbo_data(value len, value opt, value mode)
{
  CAMLparam3(len, opt, mode);
  if(opt == Val_none)
    glBufferData(GL_ARRAY_BUFFER, Int_val(len), NULL, VBOKind_val(mode));
  else {
    const GLvoid* c_dat = Caml_ba_data_val(Field(Some_val(opt),0));
    glBufferData(GL_ARRAY_BUFFER, Int_val(len), c_dat, VBOKind_val(mode));
  }
  CAMLreturn(Val_unit);
}


// INPUT   an offset, a length, some data
// OUTPUT  nothing, updates a sub-buffer with the data
CAMLprim value
caml_vbo_subdata(value off, value len, value data)
{
  CAMLparam3(off, len, data);
  const GLvoid* c_dat = Caml_ba_data_val(Field(data,0));
  glBufferSubData(GL_ARRAY_BUFFER, Int_val(off), Int_val(len), c_dat);
  CAMLreturn(Val_unit);
}


// INPUT   two buffers, two offsets, a length
// OUTPUT  nothing, copy length bytes from the first buffer to the second one
CAMLprim value
caml_vbo_copy_subdata(value bufr, value bufw, value offr, value offw, value length)
{
  CAMLparam5(bufr, bufw, offr, offw, length);

  glBindBuffer(GL_COPY_READ_BUFFER , BUFFER(bufr));
  glBindBuffer(GL_COPY_WRITE_BUFFER, BUFFER(bufw));

  glCopyBufferSubData(GL_COPY_READ_BUFFER, GL_COPY_WRITE_BUFFER, Int_val(offr), Int_val(offw), Int_val(length));

  glBindBuffer(GL_COPY_READ_BUFFER , 0);
  glBindBuffer(GL_COPY_WRITE_BUFFER, 0);

  CAMLreturn(Val_unit);
}


