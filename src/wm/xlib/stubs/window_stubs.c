#include <X11/Xlib.h>
#include <stdio.h>
#include <caml/memory.h>
#include <caml/alloc.h>
#include <caml/mlvalues.h>


// INPUT   display, parent window, origin, size, border width, 
//         border value, bg value
// OUTPUT  new window 
CAMLprim value
caml_xcreate_simple_window(
    value disp, value parent, value origin, value size, value bg
  )
{
  CAMLparam5(disp, parent, origin, size, bg);
  CAMLreturn((value) XCreateSimpleWindow(
        (Display*) disp, 
        (Window) parent,
        Int_val(Field(origin,0)),
        Int_val(Field(origin,1)),
        Int_val(Field(size,0)),
        Int_val(Field(size,1)),
        0, 0,
        Int_val(bg)
    )
  );
}


// INPUT   display, screen
// OUTPUT  window (root of screen)
CAMLprim value
caml_xroot_window(value disp, value screen)
{
  CAMLparam2(disp, screen);
  CAMLreturn((value) XRootWindow((Display*) disp, Int_val(screen)));
}


// INPUT   display, window
// OUTPUT  nothing, maps the window
CAMLprim value
caml_xmap_window(value disp, value win)
{
  CAMLparam2(disp, win);
  XMapWindow((Display*) disp, (Window) win);
  CAMLreturn(Val_unit);
}

