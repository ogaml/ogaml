#include <string.h>
#if defined(__APPLE__)
  #include <OpenAl/al.h>
  #include <OpenAL/alc.h>
#else
  #include <AL/al.h>
  #include <AL/alc.h>
#endif
#include "utils.h"

#define SOURCE(_a) (*(ALuint*) Data_custom_val(_a))

#define BUFFER(_a) (*(ALuint*) Data_custom_val(_a))

void finalise_source(value v)
{
  alDeleteSources(1,&SOURCE(v));
}

int compare_source(value v1, value v2)
{
  ALuint i1 = SOURCE(v1);
  ALuint i2 = SOURCE(v2);
  if(i1 < i2) return -1;
  else if(i1 == i2) return 0;
  else return 1;
}

intnat hash_source(value v)
{
  ALuint i = SOURCE(v);
  return i;
}

static struct custom_operations source_custom_ops = {
  "AL source gc handling",
  finalise_source,
  compare_source,
  hash_source,
  custom_serialize_default,
  custom_deserialize_default
};

static struct custom_operations buffer_custom_ops;

ALenum ALSourcePropertyf_val(value v)
{
  switch(Int_val(v))
  {
    case 0:
      return AL_PITCH;

    case 1:
      return AL_GAIN;

    case 2:
      return AL_MAX_DISTANCE;

    case 3:
      return AL_ROLLOFF_FACTOR;

    case 4:
      return AL_REFERENCE_DISTANCE;

    case 5:
      return AL_MIN_GAIN;

    case 6:
      return AL_MAX_GAIN;

    case 7:
      return AL_CONE_OUTER_GAIN;

    case 8:
      return AL_CONE_INNER_ANGLE;

    case 9:
      return AL_CONE_OUTER_ANGLE;

    case 10:
      return AL_SEC_OFFSET;

    case 11:
      return AL_SAMPLE_OFFSET;

    case 12:
      return AL_BYTE_OFFSET;

    default:
      caml_failwith("Variant error in ALSourcePropertyf_val (audio/source_stubs.c)");
  }
}

ALenum ALSourceProperty3f_val(value v)
{
  switch(Int_val(v))
  {
    case 0:
      return AL_POSITION;

    case 1:
      return AL_VELOCITY;

    case 2:
      return AL_DIRECTION;

    default:
      caml_failwith("Variant error in ALSourceProperty3f_val (audio/source_stubs.c)");
  }
}

ALenum ALSourcePropertyi_val(value v)
{
  switch(Int_val(v))
  {
    case 0:
      return AL_SOURCE_RELATIVE;

    case 1:
      return AL_SOURCE_TYPE;

    case 2:
      return AL_LOOPING;

    case 3:
      return AL_SOURCE_STATE;

    case 4:
      return AL_BUFFERS_QUEUED;

    case 5:
      return AL_BUFFERS_PROCESSED;

    default:
      caml_failwith("Variant error in ALSourcePropertyi_val (audio/source_stubs.c)");
  }
}

CAMLprim value
caml_al_create_source(value unit)
{
  CAMLparam0();

  CAMLlocal1(v);

  ALuint src[1];
  alGenSources(1, src);
  v = caml_alloc_custom( &source_custom_ops, sizeof(ALuint), 0, 1);
  memcpy( Data_custom_val(v), src, sizeof(ALuint) );

  CAMLreturn(v);
}

CAMLprim value
caml_al_set_source_f(value src, value prop, value v)
{
  CAMLparam3(src,prop,v);

  alSourcef(SOURCE(src), ALSourcePropertyf_val(prop), Double_val(v));

  CAMLreturn(Val_unit);
}

CAMLprim value
caml_al_set_source_3f(value src, value prop, value v)
{
  CAMLparam3(src,prop,v);

  alSource3f(SOURCE(src), ALSourceProperty3f_val(prop), 
             Double_val(Field(v,0)),
             Double_val(Field(v,1)),
             Double_val(Field(v,2)));

  CAMLreturn(Val_unit);
}

CAMLprim value
caml_al_set_source_i(value src, value prop, value v)
{
  CAMLparam3(src,prop,v);

  alSourcei(SOURCE(src), ALSourcePropertyi_val(prop), Int_val(v));

  CAMLreturn(Val_unit);
}

CAMLprim value
caml_al_set_buffer(value src, value buffer)
{
  CAMLparam2(src,buffer);

  alSourcei(SOURCE(src), AL_BUFFER, BUFFER(buffer));

  CAMLreturn(Val_unit);
}

CAMLprim value
caml_al_get_source_f(value src, value prop)
{
  CAMLparam2(src,prop);

  float cres;
  alGetSourcef(SOURCE(src), ALSourcePropertyf_val(prop), &cres);

  CAMLreturn(caml_copy_double(cres));
}

CAMLprim value
caml_al_get_source_3f(value src, value prop)
{
  CAMLparam2(src,prop);
  CAMLlocal1(res);

  float cres[3];
  alGetSource3f(SOURCE(src), ALSourceProperty3f_val(prop), &cres[0], &cres[1], &cres[2]);

  res = caml_alloc(3, 0);
  Store_field(res, 0, caml_copy_double(cres[0]));
  Store_field(res, 1, caml_copy_double(cres[1]));
  Store_field(res, 2, caml_copy_double(cres[2]));

  CAMLreturn(res);
}

CAMLprim value
caml_al_get_source_i(value src, value prop)
{
  CAMLparam2(src,prop);

  int cres;
  alGetSourcei(SOURCE(src), ALSourcePropertyi_val(prop), &cres);

  CAMLreturn(Val_int(cres));
}

CAMLprim value
caml_al_source_playing(value src)
{
  CAMLparam1(src);

  int alres;
  alGetSourcei(SOURCE(src), AL_SOURCE_STATE, &alres);

  CAMLreturn(Val_bool(alres == AL_PLAYING));
}

CAMLprim value
caml_al_play_source(value src)
{
  CAMLparam1(src);

  alSourcePlay(SOURCE(src));

  CAMLreturn(Val_unit);
}

CAMLprim value
caml_al_pause_source(value src)
{
  CAMLparam1(src);

  alSourcePause(SOURCE(src));

  CAMLreturn(Val_unit);
}

CAMLprim value
caml_al_stop_source(value src)
{
  CAMLparam1(src);

  alSourceStop(SOURCE(src));

  CAMLreturn(Val_unit);
}

CAMLprim value
caml_al_rewind_source(value src)
{
  CAMLparam1(src);

  alSourceRewind(SOURCE(src));

  CAMLreturn(Val_unit);
}

CAMLprim value
caml_al_queue_buffers(value src, value n, value bufs)
{
  CAMLparam3(src,n,bufs);

  ALuint* buffers = malloc(Int_val(n) * sizeof(ALuint));
  int i = 0;

  for(i = 0; i < Int_val(n); i++) {
    buffers[i] = BUFFER(Field(bufs,i));
  }

  alSourceQueueBuffers(SOURCE(src), Int_val(n), buffers);

  free(buffers);

  CAMLreturn(Val_unit);
}

CAMLprim value
caml_al_unqueue_buffer(value src)
{
  CAMLparam1(src);
  CAMLlocal1(res);

  ALuint buf[1];
  alGenBuffers(1, buf);

  alSourceUnqueueBuffers(SOURCE(src), 1, buf);

  res = caml_alloc_custom( &buffer_custom_ops, sizeof(ALuint), 0, 1);
  memcpy( Data_custom_val(res), buf, sizeof(ALuint) );

  CAMLreturn(res);
}

