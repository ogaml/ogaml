#include <X11/Xlib.h>
#include "utils.h"


Display* current_display = NULL;

// INPUT   string option
// OUTPUT  display 
CAMLprim value
caml_xopen_display(value name)
{
  CAMLparam1(name);
  if(current_display != NULL)
    CAMLreturn((value)current_display);
  else if(name == Val_none) {
    current_display = XOpenDisplay(NULL);
    CAMLreturn((value)current_display);
  }
  else {
    current_display = XOpenDisplay(String_val(Some_val(name)));
    CAMLreturn((value)current_display);
  }
}


// INPUT   display, screen n°
// OUTPUT  int * int (size in px)
CAMLprim value
caml_xscreen_size(value disp, value screen)
{
  CAMLparam2(disp, screen);

  int w = XDisplayWidth ((Display*) disp, Int_val(screen));
  int h = XDisplayHeight((Display*) disp, Int_val(screen));

  CAMLreturn(Int_pair(w,h));
}


// INPUT   display, screen n°
// OUTPUT  int * int (size in mm)
CAMLprim value
caml_xscreen_sizemm(value disp, value screen)
{
  CAMLparam2(disp, screen);

  int w = XDisplayWidthMM ((Display*) disp, Int_val(screen));
  int h = XDisplayHeightMM ((Display*) disp, Int_val(screen));

  CAMLreturn(Int_pair(w,h));
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

