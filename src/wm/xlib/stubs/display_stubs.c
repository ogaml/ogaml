#include <X11/Xlib.h>
#include <stdio.h>
#include <caml/memory.h>
#include <caml/alloc.h>
#include <caml/mlvalues.h>

CAMLprim value
caml_xopen_display(value name)
{
  if(name == Val_int(0)) 
    return (value) XOpenDisplay(NULL);
  else
    return (value) XOpenDisplay(String_val(Field(name,0)));
}

CAMLprim value
caml_xscreen_size(value disp, value screen)
{
  CAMLparam2(disp, screen);
  CAMLlocal1(size);

  size = caml_alloc(2,0);

  int w = XDisplayWidth ((Display*) disp, Int_val(screen));
  int h = XDisplayHeight((Display*) disp, Int_val(screen));

  Store_field(size, 0, Val_int(w));
  Store_field(size, 1, Val_int(h));

  CAMLreturn(size);
}

CAMLprim value
caml_xscreen_sizemm(value disp, value screen)
{
  CAMLparam2(disp, screen);
  CAMLlocal1(size);

  size = caml_alloc(2,0);

  int w = XDisplayWidthMM ((Display*) disp, Int_val(screen));
  int h = XDisplayHeightMM ((Display*) disp, Int_val(screen));

  Store_field(size, 0, Val_int(w));
  Store_field(size, 1, Val_int(h));

  CAMLreturn(size);
}

