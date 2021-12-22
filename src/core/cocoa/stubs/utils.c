#define CAML_NAME_SPACE

#include "utils.h"

static struct custom_operations NSRect_custom_ops = {
  identifier  : "NSRect handling",
  finalize    : custom_finalize_default,
  compare     : custom_compare_default,
  hash        : custom_hash_default,
  serialize   : custom_serialize_default,
  deserialize : custom_deserialize_default
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
