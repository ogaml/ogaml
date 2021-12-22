#include <string.h>
#if defined(__APPLE__)
  #include <OpenAl/al.h>
  #include <OpenAL/alc.h>
#else
  #include <AL/al.h>
  #include <AL/alc.h>
#endif
#include "utils.h"


CAMLprim value
caml_alc_set_gain(value v)
{
  CAMLparam1(v);

  alListenerf(AL_GAIN, Double_val(v));

  CAMLreturn(Val_unit);
}

CAMLprim value
caml_alc_set_position(value v)
{
  CAMLparam1(v);

  alListener3f(AL_POSITION, 
               Double_val(Field(v,0)),
               Double_val(Field(v,1)),
               Double_val(Field(v,2)));

  CAMLreturn(Val_unit);
}

CAMLprim value
caml_alc_set_velocity(value v)
{
  CAMLparam1(v);

  alListener3f(AL_VELOCITY, 
               Double_val(Field(v,0)),
               Double_val(Field(v,1)),
               Double_val(Field(v,2)));

  CAMLreturn(Val_unit);
}

CAMLprim value
caml_alc_set_orientation(value at, value up)
{
  CAMLparam2(at, up);

  float data[6];
        data[0] = Double_val(Field(at,0));
        data[1] = Double_val(Field(at,1));
        data[2] = Double_val(Field(at,2));
        data[3] = Double_val(Field(up,0));
        data[4] = Double_val(Field(up,1));
        data[5] = Double_val(Field(up,2));

  alListenerfv(AL_ORIENTATION, data);

  CAMLreturn(Val_unit);
}

CAMLprim value
caml_alc_get_gain(value unit)
{
  CAMLparam0();

  float cres;

  alGetListenerf(AL_GAIN, &cres);

  CAMLreturn(caml_copy_double(cres));
}

CAMLprim value
caml_alc_get_position(value unit)
{
  CAMLparam0();
  CAMLlocal1(res);

  float cres[3];
  res = caml_alloc(3,0);

  alGetListenerfv(AL_POSITION, cres);

  Store_field(res, 0, caml_copy_double(cres[0]));
  Store_field(res, 1, caml_copy_double(cres[1]));
  Store_field(res, 2, caml_copy_double(cres[2]));

  CAMLreturn(res);
}

CAMLprim value
caml_alc_get_velocity(value unit)
{
  CAMLparam0();
  CAMLlocal1(res);

  float cres[3];
  res = caml_alloc(3,0);

  alGetListenerfv(AL_VELOCITY, cres);

  Store_field(res, 0, caml_copy_double(cres[0]));
  Store_field(res, 1, caml_copy_double(cres[1]));
  Store_field(res, 2, caml_copy_double(cres[2]));

  CAMLreturn(res);
}

CAMLprim value
caml_alc_get_orientation(value unit)
{
  CAMLparam0();
  CAMLlocal3(res, resat, resup);

  float cres[6];
  res = caml_alloc(2,0);
  resat = caml_alloc(3,0);
  resup = caml_alloc(3,0);

  alGetListenerfv(AL_ORIENTATION, cres);

  Store_field(resat, 0, caml_copy_double(cres[0]));
  Store_field(resat, 1, caml_copy_double(cres[1]));
  Store_field(resat, 2, caml_copy_double(cres[2]));

  Store_field(resup, 0, caml_copy_double(cres[3]));
  Store_field(resup, 1, caml_copy_double(cres[4]));
  Store_field(resup, 2, caml_copy_double(cres[5]));

  Store_field(res, 0, resat);
  Store_field(res, 1, resup);

  CAMLreturn(res);
}
