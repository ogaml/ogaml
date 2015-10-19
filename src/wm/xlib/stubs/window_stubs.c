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


// INPUT   display, window
// OUTPUT  nothing, unmaps the window
CAMLprim value
caml_xunmap_window(value disp, value win)
{
  CAMLparam2(disp, win);
  XUnmapWindow((Display*) disp, (Window) win);
  CAMLreturn(Val_unit);
}


// INPUT   display, window
// OUTPUT  nothing, destroys the window
CAMLprim value
caml_xdestroy_window(value disp, value win)
{
  CAMLparam2(disp, win);
  XDestroyWindow((Display*) disp, (Window) win);
  CAMLreturn(Val_unit);
}


// INPUT   display, window
// OUTPUT  width and height of window (in pixels)
CAMLprim value
caml_size_window(value disp, value win)
{
  CAMLparam2(disp, win);
  CAMLlocal1(size);
  size = caml_alloc(2, 0);
  XWindowAttributes att;
  XGetWindowAttributes((Display*) disp, (Window) win, &att);
  Store_field(size, 0, att.width);
  Store_field(size, 1, att.height);
  CAMLreturn(size);
}


