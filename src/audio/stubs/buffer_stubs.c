#include <string.h>
#if defined(__APPLE__)
  #include <OpenAl/al.h>
  #include <OpenAL/alc.h>
#else
  #include <AL/al.h>
  #include <AL/alc.h>
#endif
#include <caml/bigarray.h>
#include "utils.h"

#define BUFFER(_a) (*(ALuint*) Data_custom_val(_a))

void finalise_albuffer(value v)
{
  alDeleteBuffers(1,&BUFFER(v));
}

int compare_albuffer(value v1, value v2)
{
  ALuint i1 = BUFFER(v1);
  ALuint i2 = BUFFER(v2);
  if(i1 < i2) return -1;
  else if(i1 == i2) return 0;
  else return 1;
}

intnat hash_albuffer(value v)
{
  ALuint i = BUFFER(v);
  return i;
}

static struct custom_operations buffer_custom_ops = {
  "AL buffer gc handling",
  finalise_albuffer,
  compare_albuffer,
  hash_albuffer,
  custom_serialize_default,
  custom_deserialize_default
};

ALenum ALProperty_val(value v)
{
  switch(Int_val(v))
  {
    case 0:
      return AL_FREQUENCY;

    case 1:
      return AL_BITS;

    case 2:
      return AL_CHANNELS;

    case 3:
      return AL_SIZE;

    default:
      caml_failwith("Variant error in ALProperty_val (audio/buffer_stubs.c)");
  }
}

CAMLprim value
caml_al_create_buffer(value unit)
{
  CAMLparam0();

  CAMLlocal1(v);

  ALuint buf[1];
  alGenBuffers(1, buf);
  v = caml_alloc_custom( &buffer_custom_ops, sizeof(ALuint), 0, 1);
  memcpy( Data_custom_val(v), buf, sizeof(ALuint) );

  CAMLreturn(v);
}

CAMLprim value
caml_al_buffer_mono_data(value buf, value data, value size, value freq)
{
  CAMLparam4(buf,data,size,freq);

  const ALvoid* c_dat = Caml_ba_data_val(Field(data,0));
  alBufferData(BUFFER(buf), AL_FORMAT_MONO16, c_dat, Int_val(size) * 2, Int_val(freq));

  CAMLreturn(Val_unit);
}

CAMLprim value
caml_al_buffer_stereo_data(value buf, value data, value size, value freq)
{
  CAMLparam4(buf,data,size,freq);

  const ALvoid* c_dat = Caml_ba_data_val(Field(data,0));
  alBufferData(BUFFER(buf), AL_FORMAT_STEREO16, c_dat, Int_val(size) * 2, Int_val(freq));

  CAMLreturn(Val_unit);
}

CAMLprim value
caml_al_set_buffer_property(value buf, value prop, value v)
{
  CAMLparam3(buf,prop,v);

  alBufferi(BUFFER(buf), ALProperty_val(prop), Int_val(v));

  CAMLreturn(Val_unit);
}

CAMLprim value
caml_al_get_buffer_property(value buf, value prop)
{
  CAMLparam2(buf,prop);

  int cres;

  alGetBufferi(BUFFER(buf), ALProperty_val(prop), &cres);

  CAMLreturn(Val_int(cres));
}

CAMLprim value
caml_al_buffer_id(value b1)
{
  CAMLparam1(b1);
  ALuint i1 = BUFFER(b1);
  CAMLreturn(Val_int(i1));
}

