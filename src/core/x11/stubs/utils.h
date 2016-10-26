#ifndef CAML_STUBS_HEADER
#define CAML_STUBS_HEADER

#define CAML_NAME_SPACE

#include <caml/custom.h>
#include <caml/fail.h>
#include <caml/callback.h>
#include <caml/memory.h>
#include <caml/alloc.h>
#include <caml/mlvalues.h>
#include <stdio.h>

#define Val_none Val_int(0)

#define Some_val(v) Field(v,0)

static struct custom_operations empty_custom_ops = {
  "default object handling",
  custom_finalize_default,
  custom_compare_default,
  custom_hash_default,
  custom_serialize_default,
  custom_deserialize_default
};

static value Val_some(value v)
{
  CAMLparam1(v);
  CAMLlocal1(some);
  some = caml_alloc(1, 0);
  Store_field( some, 0, v );
  CAMLreturn(some);
}

static value Int_pair(int a, int b)
{
  CAMLparam0();
  CAMLlocal1(pair);
  pair = caml_alloc(2, 0);
  Store_field(pair, 0, Val_int(a));
  Store_field(pair, 1, Val_int(b));
  CAMLreturn(pair);
}

#endif
