#include <X11/Xlib.h>
#include <stdio.h>
#include <caml/memory.h>
#include <caml/alloc.h>
#include <caml/mlvalues.h>

CAMLprim value
caml_xopen_display(value name)
{
  CAMLparam1(name);
  if(name == Val_int(0)) 
    CAMLreturn( (value) XOpenDisplay(NULL));
  else
    CAMLreturn( (value) XOpenDisplay(String_val(Field(name,0))));
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

CAMLprim value
caml_xscreen_count(value disp)
{
  CAMLparam1(disp);
  CAMLreturn(Val_int(XScreenCount((Display*) disp)));
}

CAMLprim value
caml_xdefault_screen(value disp)
{
  CAMLparam1(disp);
  CAMLreturn(Val_int(XDefaultScreen((Display*) disp)));
}

CAMLprim value
caml_xroot_window(value disp, value screen)
{
  CAMLparam2(disp, screen);
  CAMLreturn((value) XRootWindow((Display*) disp, Int_val(screen)));
}

CAMLprim value
caml_xcreate_simple_window(value disp, value parent, value origin, value size)
{
  CAMLparam4(disp, parent, origin, size);
  CAMLreturn((value) XCreateSimpleWindow(
        (Display*) disp, 
        (Window) parent,
        Int_val(Field(origin,0)),
        Int_val(Field(origin,1)),
        Int_val(Field(size,0)),
        Int_val(Field(size,1)),
        3, 3, 0
    )
  );
}

CAMLprim value
caml_xmap_window(value disp, value win)
{
  CAMLparam2(disp, win);
  XMapWindow((Display*) disp, (Window) win);
  CAMLreturn(Val_unit);
}

CAMLprim value
caml_xflush(value disp)
{
  CAMLparam1(disp);
  XFlush((Display*) disp);
  CAMLreturn(Val_unit);
}
