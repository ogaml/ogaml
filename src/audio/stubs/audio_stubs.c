#include <string.h>
#if defined(__APPLE__)
  #include <OpenAl/al.h>
  #include <OpenAL/alc.h>
#else
  #include <AL/al.h>
  #include <AL/alc.h>
#endif
#include "utils.h"


value Val_alerror(ALenum error)
{
  switch(error)
  {
    case AL_NO_ERROR:          
      return Val_int(0);

    case AL_INVALID_NAME:      
      return Val_int(1);

    case AL_INVALID_ENUM:      
      return Val_int(2);

    case AL_INVALID_VALUE:     
      return Val_int(3);

    case AL_INVALID_OPERATION: 
      return Val_int(4);

    case AL_OUT_OF_MEMORY:     
      return Val_int(5);

    default: 
      return Val_int(0);
  }
}

CAMLprim value
caml_speed_of_sound(value sos)
{
  CAMLparam1(sos);

  alSpeedOfSound(Double_val(sos));

  CAMLreturn(Val_unit);
}

CAMLprim value
caml_doppler_factor(value dp)
{
  CAMLparam1(dp);

  alDopplerFactor(Double_val(dp));

  CAMLreturn(Val_unit);
}

CAMLprim value
caml_al_error(value unit)
{
  CAMLparam0();

  CAMLreturn(Val_alerror(alGetError()));
}
