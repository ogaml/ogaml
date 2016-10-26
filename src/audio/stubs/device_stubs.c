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
caml_alc_open_device(value dev_name)
{
  CAMLparam1(dev_name);

  ALCchar* devicename;

  if(dev_name == Val_int(0))
    devicename = NULL;
  else
    devicename = String_val(Field(dev_name,0));

  CAMLreturn((value)alcOpenDevice(devicename));
}

CAMLprim value
caml_alc_close_device(value device)
{
  CAMLparam1(device);

  ALCboolean result = alcCloseDevice((ALCdevice*)device);

  CAMLreturn(Val_bool(result == ALC_TRUE));
}
