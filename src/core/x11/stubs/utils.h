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
#include <string.h>

#define Val_none Val_int(0)

#define Some_val(v) Field(v,0)

static struct custom_operations GLXFBConfig_custom_ops;

#define GLXFBConfig_val(v) (*(GLXFBConfig*) Data_custom_val(v))
#define GLXFBConfig_alloc(a) (a = caml_alloc_custom(&GLXFBConfig_custom_ops, sizeof(GLXFBConfig), 0, 1))
#define GLXFBConfig_copy(a,b) (memcpy(Data_custom_val(a), b, sizeof(GLXFBConfig)))

static struct custom_operations XEvent_custom_ops;

#define XEvent_val(v) (*(XEvent*) Data_custom_val(v))
#define XEvent_alloc(a) (a = caml_alloc_custom(&XEvent_custom_ops, sizeof(XEvent), 0, 1))
#define XEvent_copy(a,b) (memcpy(Data_custom_val(a), b, sizeof(XEvent)))

static struct custom_operations Window_custom_ops;

#define Window_val(v) (*(Window*) Data_custom_val(v))
#define Window_alloc(a) (a = caml_alloc_custom(&Window_custom_ops, sizeof(Window), 0, 1))
#define Window_copy(a,b) (memcpy(Data_custom_val(a), b, sizeof(Window)))

#define Val_Display(v) ((value) v)
#define Display_val(v) ((Display*) v)

#define Val_GLXContext(v) ((value) v)
#define GLXContext_val(v) ((GLXContext) v)

value Val_some(value v);

value Int_pair(int a, int b);

#endif
