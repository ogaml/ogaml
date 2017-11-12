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
#include "stb_vorbis.h"


#define VORBIS(_a) (*(stb_vorbis**) Data_custom_val(_a))

void finalise_vorbis(value v)
{
  stb_vorbis_close(VORBIS(v));
}

static struct custom_operations stb_vorbis_custom_ops = {
  identifier  : "stb_vorbis GC handling",
  finalize    : finalise_vorbis,
  compare     : custom_compare_default,
  hash        : custom_hash_default,
  serialize   : custom_serialize_default,
  deserialize : custom_deserialize_default
};


CAMLprim value
caml_stb_decode_file(value filename)
{
  CAMLparam1(filename);
  CAMLlocal1(res);

  long dims[1];
  short* data;
  int channels;
  int sample_rate;

  dims[0] = stb_vorbis_decode_filename(String_val(filename), &channels, &sample_rate, &data);

  res = caml_alloc(3,0);
  Store_field(res, 0, Val_int(channels));
  Store_field(res, 1, Val_int(sample_rate));
  Store_field(res, 2, caml_ba_alloc(CAML_BA_SINT16 | CAML_BA_C_LAYOUT, 1, data, dims));

  CAMLreturn(res);
}

CAMLprim value
caml_stb_free_data(value data)
{
  CAMLparam1(data);

  free((short*)Caml_ba_data_val(data));

  CAMLreturn(Val_unit);
}

CAMLprim value
caml_stb_vorbis_open_filename(value filename)
{
  CAMLparam1(filename);
  CAMLlocal2(res,v);

  int err;
  stb_vorbis* vorbis = stb_vorbis_open_filename(String_val(filename), &err, NULL);

  if (vorbis != NULL) {
    res = caml_alloc(1,0);
    v = caml_alloc_custom(&stb_vorbis_custom_ops, sizeof(stb_vorbis*), 0, 1);
    memcpy(Data_custom_val(v), vorbis, sizeof(stb_vorbis*));
    Store_field(res, 0, v);
  } 
  else {
    res = caml_alloc(1,1);
    Store_field(res, 0, Val_int(err));
  }

  CAMLreturn(res);
}
