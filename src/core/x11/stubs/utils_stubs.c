#include "utils.h"

CAMLprim value
caml_realpath(value path)
{
  CAMLparam1(path);
  CAMLlocal1(res);

  char* res_ptr = realpath(String_val(path), NULL);

  res = caml_copy_string(res_ptr);

  free(res_ptr);

  CAMLreturn(res);
}
