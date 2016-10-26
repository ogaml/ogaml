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
caml_alc_create_context(value device)
{
  CAMLparam1(device);

  CAMLreturn((value)alcCreateContext((ALCdevice*)device,NULL));
}

CAMLprim value
caml_alc_make_current_context(value context)
{
  CAMLparam1(context);

  ALCboolean res;

  res = alcMakeContextCurrent((ALCcontext*)context);

  CAMLreturn(Val_bool(res == ALC_TRUE));
}

CAMLprim value
caml_alc_remove_current_context(value unit)
{
  CAMLparam0();

  ALCboolean res;

  res = alcMakeContextCurrent(NULL);

  CAMLreturn(Val_bool(res == ALC_TRUE));
}

CAMLprim value
caml_alc_process_context(value context)
{
  CAMLparam1(context);

  alcProcessContext((ALCcontext*)context);

  CAMLreturn(Val_unit);
}

CAMLprim value
caml_alc_suspend_context(value context)
{
  CAMLparam1(context);

  alcSuspendContext((ALCcontext*)context);

  CAMLreturn(Val_unit);
}

CAMLprim value
caml_alc_destroy_context(value context)
{
  CAMLparam1(context);

  alcDestroyContext((ALCcontext*)context);

  CAMLreturn(Val_unit);
}
