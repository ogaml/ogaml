#include <X11/Xlib.h>
#include "utils.h"


// INPUT   a display, a window, a position
// OUTPUT  nothing, warps the pointer to the position relatively to the window
CAMLprim value
caml_xwarp_pointer(value disp, value win, value x, value y)
{
  CAMLparam4(disp, win, x, y);
  Display* dpy = Display_val(disp);
  Window w = Window_val(win);
  XWarpPointer(dpy, None, w, 0, 0, 0, 0, Int_val(x), Int_val(y));
  XFlush(dpy);
  CAMLreturn(Val_unit);
}


// INPUT   a display, a window
// OUTPUT  the position of the cursor relatively to the window
CAMLprim value
caml_xquery_pointer_position(value disp, value win)
{
  CAMLparam2(disp, win);
  Display* dpy = Display_val(disp);
  Window w = Window_val(win);
  Window rr, cr;
  int rx, ry, wx, wy;
  unsigned int mask;
  XQueryPointer(dpy, w, &rr, &cr, &rx, &ry, &wx, &wy, &mask);
  CAMLreturn(Int_pair(wx, wy));
}


// INPUT   a display, a window, a button
// OUTPUT  true iff the specified button is pressed 
CAMLprim value
caml_xquery_button_down(value disp, value win, value but)
{
  CAMLparam3(disp, win, but);
  CAMLlocal1(res); res = Val_false;
  Display* dpy = Display_val(disp);
  Window w = Window_val(win);
  Window rr, cr;
  int rx, ry, wx, wy;
  unsigned int mask;
  XQueryPointer(dpy, w, &rr, &cr, &rx, &ry, &wx, &wy, &mask);
  if(Int_val(but) >= 1 && Int_val(but) <= 5) {
    if((1 << (Int_val(but) + 7)) & mask)
      res = Val_true;
  }
  CAMLreturn(res);
}
