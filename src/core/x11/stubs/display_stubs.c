#include <X11/Xlib.h>
#include "utils.h"


Display* current_display = NULL;

// INPUT   string option
// OUTPUT  display 
CAMLprim value
caml_xopen_display(value name)
{
  CAMLparam1(name);
  if(current_display != NULL) {}
  else if(name == Val_none) {
    current_display = XOpenDisplay(NULL);
  }
  else {
    current_display = XOpenDisplay(String_val(Some_val(name)));
  }
  CAMLreturn(Val_Display(current_display));
}


// INPUT   display, screen n°
// OUTPUT  int * int (size in px)
CAMLprim value
caml_xscreen_size(value disp, value screen)
{
  CAMLparam2(disp, screen);

  Display* dpy = Display_val(disp);
  int w = XDisplayWidth (dpy, Int_val(screen));
  int h = XDisplayHeight(dpy, Int_val(screen));

  CAMLreturn(Int_pair(w,h));
}


// INPUT   display, screen n°
// OUTPUT  int * int (size in mm)
CAMLprim value
caml_xscreen_sizemm(value disp, value screen)
{
  CAMLparam2(disp, screen);

  Display* dpy = Display_val(disp);
  int w = XDisplayWidthMM (dpy, Int_val(screen));
  int h = XDisplayHeightMM (dpy, Int_val(screen));

  CAMLreturn(Int_pair(w,h));
}


// INPUT   display
// OUTPUT  int (nb of screens)
CAMLprim value
caml_xscreen_count(value disp)
{
  CAMLparam1(disp);
  Display* dpy = Display_val(disp);
  CAMLreturn(Val_int(XScreenCount(dpy)));
}


// INPUT   display
// OUTPUT  int (default screen)
CAMLprim value
caml_xdefault_screen(value disp)
{
  CAMLparam1(disp);
  Display* dpy = Display_val(disp);
  CAMLreturn(Val_int(XDefaultScreen(dpy)));
}


// INPUT   display
// OUTPUT  nothing, flushes display
CAMLprim value
caml_xflush(value disp)
{
  CAMLparam1(disp);
  Display* dpy = Display_val(disp);
  XFlush(dpy);
  CAMLreturn(Val_unit);
}

