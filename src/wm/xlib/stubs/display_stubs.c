#include <X11/Xlib.h>
#include <stdio.h>
#include <caml/memory.h>
#include <caml/alloc.h>
#include <caml/mlvalues.h>


// INPUT   string option
// OUTPUT  display 
CAMLprim value
caml_xopen_display(value name)
{
  CAMLparam1(name);
  if(name == Val_int(0)) 
    CAMLreturn( (value) XOpenDisplay(NULL));
  else
    CAMLreturn( (value) XOpenDisplay(String_val(Field(name,0))));
}


// INPUT   display, screen n°
// OUTPUT  int * int (size in px)
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


// INPUT   display, screen n°
// OUTPUT  int * int (size in mm)
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


// INPUT   display
// OUTPUT  int (nb of screens)
CAMLprim value
caml_xscreen_count(value disp)
{
  CAMLparam1(disp);
  CAMLreturn(Val_int(XScreenCount((Display*) disp)));
}


// INPUT   display
// OUTPUT  int (default screen)
CAMLprim value
caml_xdefault_screen(value disp)
{
  CAMLparam1(disp);
  CAMLreturn(Val_int(XDefaultScreen((Display*) disp)));
}


// INPUT   display
// OUTPUT  nothing, flushes display
CAMLprim value
caml_xflush(value disp)
{
  CAMLparam1(disp);
  XFlush((Display*) disp);
  CAMLreturn(Val_unit);
}

