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

CAMLprim value
caml_stb_decode_file(value filename)
{
  CAMLparam1(filename);
  CAMLlocal1(res);

  long dims[1];
  short* data;
  int channels;
  int sample_rate;

  dims[0] = stb_vorbis_decode_filename(filename, &channels, &sample_rate, &data);

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
