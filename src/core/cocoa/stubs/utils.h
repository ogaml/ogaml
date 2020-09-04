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

static struct custom_operations NSRect_custom_ops;

#define NSRect_val(v) ((NSRect*) Data_custom_val(v))
#define NSRect_alloc(a) (a = caml_alloc_custom(&NSRect_custom_ops, sizeof(NSRect), 0, 1))
#define NSRect_copy(a,b) (memcpy(Data_custom_val(a), b, sizeof(NSRect)))

value Val_some(value v);

value Int_pair(int a, int b);

#endif
