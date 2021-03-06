#define CAML_NAME_SPACE

#include "utils.h"

struct custom_operations empty_custom_opts = {
  "obj_st handling",
  custom_finalize_default,
  custom_compare_default,
  custom_hash_default,
  custom_serialize_default,
  custom_deserialize_default
};

value Val_some(value v)
{
  CAMLparam1(v);
  CAMLlocal1(some);
  some = caml_alloc(1, 0);
  Store_field( some, 0, v );
  CAMLreturn(some);
}

value Int_pair(int a, int b)
{
  CAMLparam0();
  CAMLlocal1(pair);
  pair = caml_alloc(2, 0);
  Store_field(pair, 0, Val_int(a));
  Store_field(pair, 1, Val_int(b));
  CAMLreturn(pair);
}
