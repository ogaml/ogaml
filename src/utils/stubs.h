#ifndef CAML_STUBS_HEADER
#define CAML_STUBS_HEADER

#define CAML_NAME_SPACE

#include <caml/custom.h>
#include <caml/fail.h>
#include <caml/callback.h>
#include <caml/memory.h>
#include <caml/alloc.h>
#include <caml/mlvalues.h>
#include <caml/custom.h>

#define Val_none Val_int(0)

#define Some_val(v) Field(v,0)

struct custom_operations empty_custom_opts;

value Val_some(value v);

value Int_pair(int a, int b);

#endif
